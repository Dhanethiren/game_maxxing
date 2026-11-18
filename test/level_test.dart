import 'dart:math';

import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/level.dart';
import 'package:calm_grid/game/piece.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/progression.dart';
import 'package:calm_grid/ui/spin_wheel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelSpec', () {
    test('is deterministic and well-formed for the first 200 levels', () {
      for (var n = 1; n <= 200; n++) {
        final a = LevelSpec.generate(n), b = LevelSpec.generate(n);
        expect(a.cells, b.cells, reason: 'level $n deterministic');
        expect(a.gems, b.gems);
        const size = LevelSpec.boardSize;
        for (var r = 0; r < size; r++) {
          expect(
            List.generate(size, (c) => a.cells[r * size + c]).contains(null),
            isTrue,
            reason: 'level $n row $r must not start full',
          );
        }
        for (var c = 0; c < size; c++) {
          expect(
            List.generate(size, (r) => a.cells[r * size + c]).contains(null),
            isTrue,
            reason: 'level $n col $c must not start full',
          );
        }
        if (a.goal == LevelGoal.gems) {
          expect(a.gems.length, a.target);
          expect(a.target, greaterThan(0));
          for (final g in a.gems) {
            expect(
              a.cells[g.row * size + g.col],
              isNotNull,
              reason: 'gem sits on a block',
            );
          }
        } else {
          expect(a.gems, isEmpty);
          expect(a.target, greaterThanOrEqualTo(100));
        }
      }
    });

    test('mixes score and gem levels, and gets harder', () {
      final goals = [for (var n = 1; n <= 12; n++) LevelSpec.generate(n).goal];
      expect(goals.where((g) => g == LevelGoal.gems).length, 4);
      expect(LevelSpec.generate(1).goal, LevelGoal.score);
      int filled(LevelSpec l) => l.cells.where((c) => c != null).length;
      expect(
        filled(LevelSpec.generate(40)),
        greaterThan(filled(LevelSpec.generate(2))),
      );
    });

    test('stars reward finishing in fewer moves', () {
      final l = LevelSpec.generate(5);
      expect(l.starsFor(l.par), 3);
      expect(l.starsFor(l.par + 1), 2);
      expect(l.starsFor(l.par * 3), 1);
    });
  });

  group('Gem goal', () {
    test('clearing a gem block collects it and completes the level', () {
      final l = LevelSpec.generate(3);
      expect(l.goal, LevelGoal.gems);
      final g = GameState(random: Random(1), level: l);
      expect(g.gems, l.gems);
      // Fill every empty cell of a gem's row except one, then drop a single.
      final gem = g.gems.first;
      for (var c = 0; c < 8; c++) {
        if (g.board.isEmpty(gem.row, c)) g.board.setCell(gem.row, c, 0);
      }
      g.board.setCell(gem.row, gem.col == 0 ? 1 : 0, null);
      final hole = gem.col == 0 ? 1 : 0;
      g.tray[0] = const Piece([Cell(0, 0)], 1);
      final before = g.gemsCollected;
      expect(g.place(0, gem.row, hole), isTrue);
      expect(g.gemsCollected, greaterThan(before));
      expect(g.lastEvent!.gemsCollected, contains(gem));
      expect(g.gems.contains(gem), isFalse);
    });

    test('newGame restores the level board and gems', () {
      final l = LevelSpec.generate(6);
      final g = GameState(random: Random(2), level: l);
      g.board.clear();
      g.gems.clear();
      g.newGame();
      expect(g.board.cells, l.cells);
      expect(g.gems, l.gems);
      expect(g.gemsCollected, 0);
    });
  });

  group('Journey progress', () {
    test(
      'first clear pays and unlocks; streak boosts; replay pays little',
      () async {
        final p = PlayerProfile(MemoryStore());
        final c1 = await p.completeLevel(1, 3);
        expect(c1, Progression.levelCoins(1, 3, 0));
        expect(p.journeyLevel, 2);
        final c2 = await p.completeLevel(2, 2);
        expect(c2, Progression.levelCoins(2, 2, 1));
        expect(
          c2,
          greaterThan(Progression.levelCoins(2, 2, 0)),
          reason: 'win streak bonus',
        );
        expect(await p.completeLevel(1, 1), Progression.replayCoins);
        expect(p.journeyStars[1], 3, reason: 'best stars kept');
        await p.failLevel();
        expect(p.journeyWinStreak, 0);
      },
    );
  });

  group('Daily spin', () {
    test('wheel lands with the chosen segment under the pointer', () {
      const n = 8;
      final seg = 2 * pi / n;
      for (var i = 0; i < n; i++) {
        final a = spinTargetAngle(i, n);
        final centre = ((i + 0.5) * seg + a) % (2 * pi);
        expect(min(centre, 2 * pi - centre), lessThan(1e-9));
      }
    });

    test('prize odds favour small prizes; jackpot is rare', () {
      final r = Random(1);
      final counts = List.filled(8, 0);
      for (var i = 0; i < 20000; i++) {
        counts[Progression.spinSegment(r)]++;
      }
      final jackpot = Progression.spinPrizes.indexOf(200);
      expect(counts[jackpot] / 20000, lessThan(0.02));
      expect(counts.every((c) => c > 0), isTrue);
    });

    test('one free and one extra spin per day', () async {
      final p = PlayerProfile(MemoryStore());
      expect(p.freeSpinAvailable, isTrue);
      expect(p.extraSpinAvailable, isFalse);
      await p.useSpin(extra: false);
      expect(p.freeSpinAvailable, isFalse);
      expect(p.extraSpinAvailable, isTrue);
      await p.useSpin(extra: true);
      expect(p.extraSpinAvailable, isFalse);
    });
  });
}
