import 'package:calm_grid/ads/ad_policy.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/piece.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Levels', () {
    test('XP thresholds increase and level lookup matches', () {
      expect(Progression.xpForLevel(1), 0);
      expect(Progression.xpForLevel(2), 250);
      expect(Progression.xpForLevel(3), 750);
      expect(Progression.levelForXp(0), 1);
      expect(Progression.levelForXp(249), 1);
      expect(Progression.levelForXp(250), 2);
      expect(Progression.levelForXp(5000), greaterThan(5));
    });

    test('profile pays level-up coins', () async {
      final p = PlayerProfile(MemoryStore());
      final reached = await p.addXp(800);
      expect(reached, [2, 3]);
      expect(
        p.coins,
        Progression.levelUpReward(2) + Progression.levelUpReward(3),
      );
    });
  });

  group('Daily reward streak', () {
    test(
      'continues on consecutive days, resets after a gap, caps at 7',
      () async {
        final p = PlayerProfile(MemoryStore());
        final d1 = DateTime(2026, 11, 1, 9);
        expect(p.claimableDailyDay(d1), 1);
        expect(await p.claimDaily(now: d1), Progression.dailyRewards[0]);
        expect(
          p.claimableDailyDay(d1),
          isNull,
          reason: 'already claimed today',
        );

        var day = d1;
        for (var i = 2; i <= 7; i++) {
          day = day.add(const Duration(days: 1));
          expect(p.claimableDailyDay(day), i);
          await p.claimDaily(now: day);
        }
        day = day.add(const Duration(days: 1));
        expect(p.claimableDailyDay(day), 1, reason: 'wraps after day 7');

        day = day.add(const Duration(days: 2));
        expect(p.claimableDailyDay(day), 1, reason: 'missed a day');
      },
    );

    test('works across month boundaries', () {
      expect(
        Progression.claimableStreakDay(
          lastClaimDay: 20261130,
          streak: 3,
          now: DateTime(2026, 12, 1),
        ),
        4,
      );
    });

    test('ad doubles the reward', () async {
      final p = PlayerProfile(MemoryStore());
      expect(
        await p.claimDaily(multiplier: 2, now: DateTime(2026, 1, 1)),
        Progression.dailyRewards[0] * 2,
      );
    });
  });

  group('Missions', () {
    test('same missions all day, new ones tomorrow', () {
      final a = DailyMissions.generate(20261118, 3);
      final b = DailyMissions.generate(20261118, 3);
      final c = DailyMissions.generate(20261119, 3);
      expect(
        [for (final m in a.missions) m.title],
        [for (final m in b.missions) m.title],
      );
      expect(a.missions.length, 3);
      expect(c.day, 20261119);
    });

    test('progress, completion and persistence', () {
      final m = DailyMissions(20261118, [
        Mission(MissionType.clearLines, 3, 40),
        Mission(MissionType.playGames, 2, 30),
        Mission(MissionType.comboInGame, 2, 50),
      ]);
      PlaceEvent ev(int lines, int combo) => PlaceEvent(
        id: 1,
        placedCells: const {},
        colorIndex: 0,
        clearedColors: const {},
        lines: lines,
        combo: combo,
        points: 0,
        perfect: false,
        origin: const Cell(0, 0),
      );
      expect(m.onPlace(ev(2, 1)), isEmpty);
      final done = m.onPlace(ev(1, 2));
      expect(done.map((x) => x.type), [
        MissionType.clearLines,
        MissionType.comboInGame,
      ]);
      expect(
        m.onPlace(ev(5, 3)),
        isEmpty,
        reason: 'completed missions do not repeat',
      );
      m.onGameEnd(100);
      expect(m.onGameEnd(100).single.type, MissionType.playGames);

      final restored = DailyMissions.load(m.toJson(), 20261118, 1);
      expect(restored.missions.every((x) => x.done), isTrue);
      final tomorrow = DailyMissions.load(m.toJson(), 20261119, 1);
      expect(tomorrow.missions.every((x) => !x.done), isTrue);
    });
  });

  group('Interstitial policy', () {
    final now = DateTime(2026, 11, 18, 12);
    bool show({
      int lifetime = 10,
      int since = 5,
      DateTime? lastInt,
      DateTime? lastRew,
      int session = 0,
      bool best = false,
      Duration sessionAge = const Duration(minutes: 10),
      InterstitialPolicy policy = const InterstitialPolicy(),
    }) => policy.shouldShow(
      lifetimeGames: lifetime,
      gamesSinceLast: since,
      lastInterstitialAt: lastInt,
      lastRewardedAt: lastRew,
      shownThisSession: session,
      sessionStart: now.subtract(sessionAge),
      justSetNewBest: best,
      now: now,
    );

    test('allowed for an established player at a natural break', () {
      expect(show(), isTrue);
    });

    test('protects new players, recent ads, celebrations and session caps', () {
      expect(show(lifetime: 2), isFalse);
      expect(show(since: 2), isFalse);
      expect(show(lastInt: now.subtract(const Duration(minutes: 2))), isFalse);
      expect(show(lastRew: now.subtract(const Duration(minutes: 1))), isFalse);
      expect(show(session: 4), isFalse);
      expect(show(best: true), isFalse);
      expect(show(sessionAge: const Duration(seconds: 30)), isFalse);
      expect(show(policy: const InterstitialPolicy(enabled: false)), isFalse);
    });
  });
}
