import 'dart:math';

import 'package:calm_grid/ads/ad_service.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/services/pacing.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/reward_offers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [n] answers from a simulated player who says yes to style s with
/// probability rates[s]. Returns the share of yes answers.
double simulate(
  Pacer p,
  List<double> rates,
  int n,
  Random rnd, {
  int mood = 2,
}) {
  var yes = 0;
  for (var i = 0; i < n; i++) {
    final s = p.pick(0, mood);
    final ok = rnd.nextDouble() < rates[s];
    if (ok) yes++;
    p.learn(0, s, mood, yes: ok);
  }
  return yes / n;
}

GameState gameWithScore(int score) {
  final g = GameState(random: Random(1));
  return GameState.fromJson({...g.toJson(), 'score': score})!;
}

void main() {
  test('learns the style a simulated player prefers', () {
    final rnd = Random(42);
    final p = Pacer(random: rnd);
    simulate(p, [0.2, 0.6, 0.3], 400, rnd);
    var picks = 0;
    for (var i = 0; i < 200; i++) {
      if (p.pick(0, 2) == 1) picks++;
    }
    expect(picks, greaterThan(150));
    expect(p.chance(0, 1, 2), closeTo(0.6, 0.12));
  });

  test('beats picking the wording at random by a wide margin', () {
    const rates = [0.2, 0.6, 0.3]; // random choice averages 0.37
    var learned = 0.0;
    var random = 0.0;
    for (var seed = 0; seed < 20; seed++) {
      final rnd = Random(seed);
      learned += simulate(Pacer(random: rnd), rates, 300, rnd);
      for (var i = 0; i < 300; i++) {
        if (rnd.nextDouble() < rates[rnd.nextInt(3)]) random++;
      }
    }
    learned /= 20;
    random /= 20 * 300;
    expect(random, closeTo(0.37, 0.03));
    expect(learned, greaterThan(0.5));
  });

  test('learns that a style works in one situation but not another', () {
    // Style 1 is great at high stakes (mood 3) and poor at low stakes (mood
    // 2); the others are middling in both. Checked over many players.
    var s1High = 0;
    var s1Low = 0;
    var late = 0;
    for (var seed = 0; seed < 40; seed++) {
      final rnd = Random(seed);
      final p = Pacer(random: rnd);
      for (var i = 0; i < 400; i++) {
        final mood = i.isEven ? 3 : 2;
        final s = p.pick(0, mood);
        final rate = s == 1 ? (mood == 3 ? 0.8 : 0.1) : 0.35;
        p.learn(0, s, mood, yes: rnd.nextDouble() < rate);
        if (i >= 300 && s == 1) mood == 3 ? s1High++ : s1Low++;
        if (i >= 300 && mood == 3) late++;
      }
    }
    expect(s1High / late, greaterThan(0.85)); // picks it when it works
    expect(s1Low / late, lessThan(0.1)); // and avoids it when it doesn't
  });

  test('state is tiny and survives a save/load round trip', () {
    final rnd = Random(7);
    final p = Pacer(random: rnd);
    simulate(p, [0.3, 0.5, 0.2], 120, rnd);
    final state = p.save();
    expect(state.length, lessThan(260));
    final q = Pacer()..load(state);
    for (var s = 0; s < Pacer.styles; s++) {
      for (var m = 0; m < Pacer.moods; m++) {
        expect(q.chance(0, s, m), closeTo(p.chance(0, s, m), 0.005));
      }
    }
    expect(q.save(), state);
  });

  test('damaged or unknown state starts fresh', () {
    final fresh = Pacer().chance(0, 0, 0);
    for (final bad in ['', 'not base64 !!', 'AAAA', 'Ag${'A' * 300}']) {
      expect((Pacer()..load(bad)).chance(0, 0, 0), fresh, reason: bad);
    }
  });

  group('rest', () {
    test('a player who keeps saying no is asked less, never not at all', () {
      final p = Pacer(random: Random(3));
      expect(p.rest(0, 2, highStakes: false), isFalse); // new player
      for (var i = 0; i < 12; i++) {
        p.learn(0, i % 3, 2, yes: false);
      }
      final shown = <bool>[];
      for (var i = 0; i < 9; i++) {
        final rested = p.rest(0, 2, highStakes: false);
        shown.add(!rested);
        if (!rested) p.learn(0, i % 3, 2, yes: false);
      }
      // Rests at most twice in a row, so 1 in 3 is still shown.
      expect(shown, [
        false,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        true,
      ]);
    });

    test('never rests at high stakes, and a yes resets it', () {
      final p = Pacer(random: Random(3));
      for (var i = 0; i < 12; i++) {
        p.learn(0, i % 3, 2, yes: false);
      }
      expect(p.rest(0, 3, highStakes: true), isFalse);
      p.learn(0, 1, 2, yes: true);
      expect(p.rest(0, 2, highStakes: false), isFalse);
    });
  });

  group('RewardOffers', () {
    late PlayerProfile profile;
    late RewardOffers offers;

    setUp(() {
      profile = PlayerProfile(MemoryStore({'bestScore': 1000}));
      offers = RewardOffers(ads: SimulatedAdService(), profile: profile);
    });

    test('reads the situation from the run and recent ads', () async {
      expect(offers.moodFor(null), 2); // fresh, low stakes
      expect(offers.moodFor(gameWithScore(700)), 3); // fresh, high stakes
      expect(offers.moodFor(gameWithScore(100)), 2);
      await profile.onAdWatched();
      expect(offers.moodFor(gameWithScore(700)), 1); // just watched an ad
    });

    test('records answers in compact saved state', () async {
      final d = offers.decide(OfferPlacement.revive, gameWithScore(900));
      await offers.recordAnswer(d, accepted: true);
      expect(profile.pacing, isNotNull);
      expect(profile.pacing!.length, lessThan(260));
      final again = RewardOffers(ads: SimulatedAdService(), profile: profile);
      expect(
        again.chance(d.placement, d.variant, d.mood),
        closeTo(offers.chance(d.placement, d.variant, d.mood), 0.005),
      );
    });

    test('removes data written by older versions', () async {
      final store = MemoryStore({'offerOptimizer': 'x', 'lifetimeOffers': 3});
      RewardOffers(ads: SimulatedAdService(), profile: PlayerProfile(store));
      await Future<void>.delayed(Duration.zero);
      expect(store.get('offerOptimizer'), isNull);
      expect(store.get('lifetimeOffers'), isNull);
    });
  });
}
