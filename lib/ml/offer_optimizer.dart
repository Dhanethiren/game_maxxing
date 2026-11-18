import 'dart:convert';
import 'dart:math';

/// Where in the game a rewarded-ad offer is shown. The model learns a
/// separate set of weights for every placement automatically.
///
/// To add a new reward: add a value here, call [OfferOptimizer.choose] (or
/// [OfferOptimizer.shouldOffer] for optional pop-ups) where it appears, and
/// record the answer with [OfferOptimizer.record].
enum OfferPlacement {
  /// "Watch an ad to continue" after losing (once per game).
  revive,

  /// "Double the coins you just earned" on the game-over screen.
  doubleCoins,

  /// "Double today's login reward".
  dailyBonus,

  /// "Spin the daily wheel again".
  extraSpin,
}

/// The different ways an offer can be presented. The model learns which one
/// each player is most likely to say yes to, in each situation.
///
/// Each placement words the variants in its own way (see the UI), e.g. for
/// revive: quick = "Continue?", progress = "You're 90% of the way to your
/// best", calm = appears after a short pause with "Take a breath...".
enum OfferVariant {
  /// Short and direct.
  quick,

  /// Emphasises what the player gains or is close to.
  progress,

  /// Soft, low-pressure wording.
  calm,
}

/// What the game knows about the player at the moment an offer could appear.
/// Everything here stays on the device.
class OfferContext {
  const OfferContext({
    required this.score,
    required this.bestScore,
    required this.gameDuration,
    required this.gamesThisSession,
    required this.adsWatchedThisSession,
    required this.timeSinceLastAd,
    required this.lifetimeOffers,
    required this.lifetimeAccepts,
    required this.boardFill,
  });

  final int score;
  final int bestScore;
  final Duration gameDuration;
  final int gamesThisSession;
  final int adsWatchedThisSession;

  /// `null` if the player has never watched an ad.
  final Duration? timeSinceLastAd;
  final int lifetimeOffers;
  final int lifetimeAccepts;

  /// 0..1, how full the board was when the game ended.
  final double boardFill;

  static const int featureCount = 9;

  /// Feature vector, each value scaled to roughly 0..1.
  List<double> toFeatures() {
    double clip(num v, num hi) => (v / hi).clamp(0, 1).toDouble();
    final best = max(bestScore, 1);
    return [
      1.0, // bias
      clip(score / best, 1.5), // how close to a personal best
      score >= best * 0.7 ? 1.0 : 0.0, // near/above best: high stakes
      clip(gameDuration.inSeconds, 600), // time invested in this game
      clip(gamesThisSession, 10), // session depth
      clip(adsWatchedThisSession, 5), // ad fatigue
      timeSinceLastAd == null ? 1.0 : clip(timeSinceLastAd!.inSeconds, 1800),
      (lifetimeAccepts + 1) / (lifetimeOffers + 2), // smoothed accept rate
      boardFill.clamp(0, 1).toDouble(),
    ];
  }
}

/// A decision made by the optimizer, kept so the outcome can be recorded.
class OfferDecision {
  const OfferDecision({
    required this.placement,
    required this.variant,
    required this.features,
    required this.predictedAcceptance,
  });

  final OfferPlacement placement;
  final OfferVariant variant;
  final List<double> features;

  /// The model's estimate (0..1) that the player taps "Watch ad".
  final double predictedAcceptance;
}

/// One LinUCB arm: a linear model with an exploration bonus.
class _Arm {
  _Arm(int d, double prior)
    : aInv = List.generate(
        d,
        (i) => List.generate(d, (j) => i == j ? 1.0 : 0.0),
      ),
      b = List.generate(d, (i) => i == 0 ? prior : 0.0);

  _Arm.fromJson(Map<String, dynamic> json)
    : aInv = [
        for (final row in json['aInv'] as List)
          [for (final v in row as List) (v as num).toDouble()],
      ],
      b = [for (final v in json['b'] as List) (v as num).toDouble()],
      pulls = json['pulls'] as int? ?? 0,
      rewards = json['rewards'] as int? ?? 0;

  /// Inverse of A = I + sum(x x^T), kept up to date with Sherman–Morrison.
  final List<List<double>> aInv;

  /// Sum of reward * x (plus a small prior on the bias term).
  final List<double> b;
  int pulls = 0;
  int rewards = 0;

  List<double> get theta => _matVec(aInv, b);

  double mean(List<double> x) => _dot(theta, x);

  double uncertainty(List<double> x) => sqrt(max(0, _dot(x, _matVec(aInv, x))));

  void update(List<double> x, double reward) {
    final ax = _matVec(aInv, x);
    final denom = 1 + _dot(x, ax);
    for (var i = 0; i < ax.length; i++) {
      for (var j = 0; j < ax.length; j++) {
        aInv[i][j] -= ax[i] * ax[j] / denom;
      }
    }
    for (var i = 0; i < b.length; i++) {
      b[i] += reward * x[i];
    }
    pulls++;
    if (reward > 0) rewards++;
  }

  Map<String, dynamic> toJson() => {
    'aInv': aInv,
    'b': b,
    'pulls': pulls,
    'rewards': rewards,
  };
}

/// On-device contextual bandit (LinUCB) that learns when and how to present
/// "watch an ad for a reward" offers so the player is most likely to accept.
///
/// * It learns online from each tap: there is no training step and no server.
/// * [alpha] controls exploration: higher tries less-proven variants more often.
/// * Guardrails in [shouldOffer] stop optional offers from being spammy,
///   because annoyed players uninstall, which costs more than one ad.
class OfferOptimizer {
  OfferOptimizer({this.alpha = 0.5, this.prior = 0.3, Random? random})
    : _random = random ?? Random();

  final double alpha;
  final double prior;
  final Random _random;
  final Map<String, _Arm> _arms = {};

  /// Minimum gap between two optional (non-revive) offers.
  static const Duration minGapBetweenOptionalOffers = Duration(seconds: 90);

  /// Max optional offers per app session.
  static const int maxOptionalOffersPerSession = 4;

  DateTime? _lastOptionalOfferAt;
  int _optionalOffersThisSession = 0;

  _Arm _arm(OfferPlacement p, OfferVariant v) => _arms.putIfAbsent(
    '${p.name}:${v.name}',
    () => _Arm(OfferContext.featureCount, prior),
  );

  /// Picks the presentation most likely to be accepted, with some exploration.
  OfferDecision choose(
    OfferPlacement placement,
    OfferContext context, {
    List<OfferVariant> allowed = OfferVariant.values,
  }) {
    final x = context.toFeatures();
    OfferVariant? best;
    var bestScore = double.negativeInfinity;
    for (final v in allowed) {
      final arm = _arm(placement, v);
      // Tiny random jitter breaks ties between untouched arms.
      final ucb =
          arm.mean(x) +
          alpha * arm.uncertainty(x) +
          _random.nextDouble() * 1e-6;
      if (ucb > bestScore) {
        bestScore = ucb;
        best = v;
      }
    }
    return OfferDecision(
      placement: placement,
      variant: best!,
      features: x,
      predictedAcceptance: predict(placement, best, context),
    );
  }

  /// The model's best guess (0..1) that the player accepts this offer.
  double predict(
    OfferPlacement placement,
    OfferVariant variant,
    OfferContext context,
  ) => _arm(placement, variant).mean(context.toFeatures()).clamp(0.0, 1.0);

  /// For optional rewards (not revive): should an offer be shown at all right now?
  ///
  /// Shows it only if the best variant's predicted acceptance clears
  /// [threshold] and the frequency caps allow it.
  bool shouldOffer(
    OfferPlacement placement,
    OfferContext context, {
    double threshold = 0.25,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    if (_optionalOffersThisSession >= maxOptionalOffersPerSession) return false;
    final last = _lastOptionalOfferAt;
    if (last != null && now.difference(last) < minGapBetweenOptionalOffers) {
      return false;
    }
    final x = context.toFeatures();
    final bestUcb = OfferVariant.values
        .map((v) => _arm(placement, v))
        .map((a) => a.mean(x) + alpha * a.uncertainty(x))
        .reduce(max);
    if (bestUcb < threshold) return false;
    _lastOptionalOfferAt = now;
    _optionalOffersThisSession++;
    return true;
  }

  /// Teaches the model what happened. [accepted] = the player tapped "Watch ad".
  void record(OfferDecision decision, {required bool accepted}) {
    _arm(
      decision.placement,
      decision.variant,
    ).update(decision.features, accepted ? 1.0 : 0.0);
  }

  /// Per-variant stats, handy for a debug screen.
  Map<String, ({int shown, int accepted})> stats() => {
    for (final e in _arms.entries)
      e.key: (shown: e.value.pulls, accepted: e.value.rewards),
  };

  String toJson() => jsonEncode({
    'v': 1,
    'arms': {for (final e in _arms.entries) e.key: e.value.toJson()},
  });

  /// Restores learned weights. Silently starts fresh on bad or old data.
  void loadJson(String? json) {
    if (json == null) return;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      if (data['v'] != 1) return;
      final arms = data['arms'] as Map<String, dynamic>;
      _arms.clear();
      for (final e in arms.entries) {
        final arm = _Arm.fromJson(e.value as Map<String, dynamic>);
        if (arm.b.length == OfferContext.featureCount) _arms[e.key] = arm;
      }
    } catch (_) {
      _arms.clear();
    }
  }
}

double _dot(List<double> a, List<double> b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

List<double> _matVec(List<List<double>> m, List<double> v) => [
  for (final row in m) _dot(row, v),
];
