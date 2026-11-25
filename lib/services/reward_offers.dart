import '../ads/ad_policy.dart';
import '../ads/ad_service.dart';
import '../game/game_state.dart';
import 'pacing.dart';
import 'player_profile.dart';

/// Where in the game an optional "watch an ad for a reward" offer appears.
enum OfferPlacement {
  /// "Watch an ad to continue" after losing (at most once per game).
  revive,

  /// "Double the coins you just earned" on the game-over screen.
  doubleCoins,

  /// "Double today's login reward".
  dailyBonus,
}

/// Ways an offer can be worded. Each placement words them in its own way
/// (see the UI), e.g. for revive: quick = "Continue?", progress = "You're
/// 90% of the way to your best", calm = a short pause, then "Take a breath".
enum OfferVariant { quick, progress, calm }

/// An offer as it was shown, kept so the player's answer can be recorded.
class OfferDecision {
  const OfferDecision(this.placement, this.variant, this.mood);

  final OfferPlacement placement;
  final OfferVariant variant;

  /// The situation it was shown in (see [RewardOffers.moodFor]).
  final int mood;
}

/// Glue between the game, the player's profile and the ad network. The UI
/// only needs this class to run ads.
///
/// Every offer is optional and says what it gives before an ad plays. The
/// wording adapts on the device to what each player tends to accept, and a
/// player who keeps declining the revive pop-up sees it less often.
class RewardOffers {
  RewardOffers({
    required this.ads,
    required this.profile,
    Pacer? pacer,
    this.interstitialPolicy = const InterstitialPolicy(),
  }) : _pacer = pacer ?? Pacer() {
    _pacer.load(profile.pacing);
    profile.forgetLegacyOfferData();
  }

  final AdService ads;
  final PlayerProfile profile;
  final InterstitialPolicy interstitialPolicy;
  final Pacer _pacer;

  /// Two coarse facts about the moment, packed into 0..3:
  /// * bit 1: high stakes, i.e. this run is at 60%+ of the best score;
  /// * bit 2: fresh, i.e. no rewarded ad in the last 10 minutes.
  int moodFor(GameState? game, {DateTime? now}) {
    final best = profile.bestScore;
    final high = game != null && best > 0 && game.score >= best * 0.6;
    final last = profile.lastAdAt;
    final fresh =
        last == null ||
        (now ?? DateTime.now()).difference(last) > const Duration(minutes: 10);
    return (high ? 1 : 0) | (fresh ? 2 : 0);
  }

  /// Picks the wording most likely to be accepted, with some exploration.
  OfferDecision decide(OfferPlacement placement, [GameState? game]) {
    final mood = moodFor(game);
    final style = _pacer.pick(placement.index, mood);
    return OfferDecision(placement, OfferVariant.values[style], mood);
  }

  /// Whether to show the revive pop-up for this game over. It always appears
  /// at high-stakes moments; for a player who keeps declining it sits out up
  /// to two low-stakes game overs in a row.
  bool shouldOfferRevive(GameState game) {
    final mood = moodFor(game);
    final rest = _pacer.rest(
      OfferPlacement.revive.index,
      mood,
      highStakes: (mood & 1) == 1,
    );
    if (rest) profile.savePacing(_pacer.save());
    return !rest;
  }

  /// The expected chance (0..1) that the player accepts [variant] at
  /// [placement] in [mood].
  double chance(OfferPlacement placement, OfferVariant variant, int mood) =>
      _pacer.chance(placement.index, variant.index, mood);

  /// Call once the player has answered (or ignored) the offer.
  Future<void> recordAnswer(
    OfferDecision decision, {
    required bool accepted,
  }) async {
    _pacer.learn(
      decision.placement.index,
      decision.variant.index,
      decision.mood,
      yes: accepted,
    );
    await profile.savePacing(_pacer.save());
  }

  /// Shows a rewarded ad. Returns true if the reward should be granted.
  Future<bool> watchAd() async {
    final earned = await ads.showRewarded();
    if (earned) await profile.onAdWatched();
    return earned;
  }

  /// Shows an interstitial if the [interstitialPolicy] allows it right now.
  /// Call only at a natural break (leaving the game-over screen).
  Future<bool> maybeShowInterstitial({required bool justSetNewBest}) async {
    final allowed = interstitialPolicy.shouldShow(
      lifetimeGames: profile.gamesPlayed,
      gamesSinceLast: profile.gamesSinceInterstitial,
      lastInterstitialAt: profile.lastInterstitialAt,
      lastRewardedAt: profile.lastAdAt,
      shownThisSession: profile.interstitialsThisSession,
      sessionStart: profile.sessionStart,
      justSetNewBest: justSetNewBest,
      now: DateTime.now(),
    );
    if (!allowed || !ads.interstitialReady) return false;
    await ads.showInterstitial();
    await profile.onInterstitialShown();
    return true;
  }
}
