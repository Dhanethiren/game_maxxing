import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/piece.dart';
import 'package:calm_grid/services/achievements.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/review_prompter.dart';
import 'package:flutter_test/flutter_test.dart';

PlaceEvent ev({int lines = 0, int combo = 0, bool perfect = false}) =>
    PlaceEvent(
      id: 1,
      placedCells: const {},
      colorIndex: 0,
      clearedColors: const {},
      lines: lines,
      combo: combo,
      points: 0,
      perfect: perfect,
      origin: const Cell(0, 0),
    );

void main() {
  group('Review policy (Google In-App Review guidance)', () {
    final now = DateTime(2026, 11, 18);
    bool ask({
      bool happy = true,
      int games = 10,
      Duration age = const Duration(days: 5),
      DateTime? last,
    }) => ReviewPolicy.shouldAsk(
      happyMoment: happy,
      gamesPlayed: games,
      firstOpenAt: now.subtract(age),
      lastPromptAt: last,
      now: now,
    );

    test('asks a settled player at a happy moment', () {
      expect(ask(), isTrue);
    });

    test('never on a bad moment, too early, or too often', () {
      expect(ask(happy: false), isFalse);
      expect(ask(games: 2), isFalse);
      expect(ask(age: const Duration(hours: 10)), isFalse);
      expect(ask(last: now.subtract(const Duration(days: 30))), isFalse);
      expect(ask(last: now.subtract(const Duration(days: 200))), isTrue);
    });
  });

  group('Achievements', () {
    test('there are at least 10 (Play Games Level Up minimum), ids unique', () {
      expect(Achievement.values.length, greaterThanOrEqualTo(10));
      final ids = Achievement.values.map((a) => a.id).toSet();
      expect(ids.length, Achievement.values.length);
    });

    test('moves earn the right achievements', () {
      expect(AchievementRules.onPlace(ev(), 10), {Achievement.firstBlock});
      expect(
        AchievementRules.onPlace(ev(lines: 3, combo: 6, perfect: true), 5200),
        containsAll([
          Achievement.firstLine,
          Achievement.double,
          Achievement.triple,
          Achievement.combo3,
          Achievement.combo6,
          Achievement.perfect,
          Achievement.score1k,
          Achievement.score5k,
        ]),
      );
    });

    test('unlocking pays once and is remembered', () async {
      final p = PlayerProfile(MemoryStore());
      final first = await p.unlock([
        Achievement.firstBlock,
        Achievement.firstLine,
      ]);
      expect(first.length, 2);
      expect(p.coins, Achievement.reward * 2);
      final again = await p.unlock([Achievement.firstBlock]);
      expect(again, isEmpty);
      expect(p.coins, Achievement.reward * 2);
    });

    test('lifetime stats unlock long-term achievements', () async {
      final p = PlayerProfile(MemoryStore());
      await p.addLifetime(lines: 499, gems: 50);
      expect(AchievementRules.fromStats(p.achievementStats), {
        Achievement.gems50,
      });
      await p.addLifetime(lines: 1);
      expect(
        AchievementRules.fromStats(p.achievementStats),
        containsAll([Achievement.lines500, Achievement.gems50]),
      );
    });
  });
}
