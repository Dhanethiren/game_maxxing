import 'dart:math';

import 'package:calm_grid/ml/offer_optimizer.dart';
import 'package:flutter_test/flutter_test.dart';

OfferContext ctx({int score = 100, int best = 200, int adsWatched = 0}) =>
    OfferContext(
      score: score,
      bestScore: best,
      gameDuration: const Duration(minutes: 3),
      gamesThisSession: 2,
      adsWatchedThisSession: adsWatched,
      timeSinceLastAd: null,
      lifetimeOffers: 0,
      lifetimeAccepts: 0,
      boardFill: 0.6,
    );

void main() {
  test('features are bounded and the right length', () {
    final x = ctx(score: 99999, best: 1, adsWatched: 99).toFeatures();
    expect(x.length, OfferContext.featureCount);
    for (final v in x) {
      expect(v, inInclusiveRange(0, 1));
    }
  });

  test('learns the variant a simulated player prefers', () {
    final rnd = Random(42);
    final opt = OfferOptimizer(random: rnd);
    // Simulated player: accepts "progress" 70% of the time, others 20%.
    var progressPicks = 0;
    for (var i = 0; i < 600; i++) {
      final d = opt.choose(OfferPlacement.revive, ctx());
      final p = d.variant == OfferVariant.progress ? 0.7 : 0.2;
      opt.record(d, accepted: rnd.nextDouble() < p);
      if (i >= 400 && d.variant == OfferVariant.progress) progressPicks++;
    }
    // Over the last 200 offers it should mostly pick the winner.
    expect(progressPicks, greaterThan(150));
    expect(
      opt.predict(OfferPlacement.revive, OfferVariant.progress, ctx()),
      closeTo(0.7, 0.15),
    );
  });

  test('learns context: near a personal best vs far from it', () {
    final rnd = Random(1);
    final opt = OfferOptimizer(random: rnd);
    final near = ctx(score: 190, best: 200);
    final far = ctx(score: 20, best: 200);
    // "progress" only works when the player is close to their best.
    for (var i = 0; i < 800; i++) {
      final c = i.isEven ? near : far;
      final d = opt.choose(OfferPlacement.revive, c);
      final p = switch (d.variant) {
        OfferVariant.progress => identical(c, near) ? 0.8 : 0.1,
        _ => 0.35,
      };
      opt.record(d, accepted: rnd.nextDouble() < p);
    }
    expect(
      opt.choose(OfferPlacement.revive, near).variant,
      OfferVariant.progress,
    );
    expect(
      opt.choose(OfferPlacement.revive, far).variant,
      isNot(OfferVariant.progress),
    );
  });

  test('state survives a save/load round trip', () {
    final opt = OfferOptimizer(random: Random(0));
    for (var i = 0; i < 20; i++) {
      final d = opt.choose(OfferPlacement.revive, ctx());
      opt.record(d, accepted: d.variant == OfferVariant.calm);
    }
    final restored = OfferOptimizer()..loadJson(opt.toJson());
    for (final v in OfferVariant.values) {
      expect(
        restored.predict(OfferPlacement.revive, v, ctx()),
        closeTo(opt.predict(OfferPlacement.revive, v, ctx()), 1e-9),
      );
    }
    expect(restored.stats(), opt.stats());
  });

  test('corrupt saved state is ignored', () {
    final opt = OfferOptimizer()..loadJson('{not json');
    expect(opt.stats(), isEmpty);
  });

  test('optional offers respect frequency caps', () {
    final opt = OfferOptimizer(random: Random(0));
    final t0 = DateTime(2026);
    expect(opt.shouldOffer(OfferPlacement.revive, ctx(), now: t0), isTrue);
    expect(
      opt.shouldOffer(
        OfferPlacement.revive,
        ctx(),
        now: t0.add(const Duration(seconds: 30)),
      ),
      isFalse,
    );
    var shown = 1;
    for (var i = 1; i < 20; i++) {
      if (opt.shouldOffer(
        OfferPlacement.revive,
        ctx(),
        now: t0.add(Duration(minutes: 2 * i)),
      )) {
        shown++;
      }
    }
    expect(shown, OfferOptimizer.maxOptionalOffersPerSession);
  });
}
