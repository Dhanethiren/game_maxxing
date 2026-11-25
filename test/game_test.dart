import 'dart:math';

import 'package:calm_grid/game/board.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/piece.dart';
import 'package:flutter_test/flutter_test.dart';

const single = Piece([Cell(0, 0)], 0);
const bar8 = Piece([
  Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(0, 3), //
  Cell(0, 4), Cell(0, 5), Cell(0, 6), Cell(0, 7),
], 1);

void main() {
  group('Board', () {
    test('rejects out-of-bounds and overlapping placements', () {
      final b = Board();
      expect(b.canPlace(single, 0, 0), isTrue);
      expect(b.canPlace(single, 8, 0), isFalse);
      expect(b.canPlace(single, -1, 0), isFalse);
      b.place(single, 0, 0);
      expect(b.canPlace(single, 0, 0), isFalse);
    });

    test('clears a full row', () {
      final b = Board();
      final r = b.place(bar8, 3, 0);
      expect(r.clearedRows, [3]);
      expect(r.clearedCells.length, 8);
      expect(b.filledCount, 0);
    });

    test('clears a row and a column at once', () {
      final b = Board();
      for (var c = 0; c < 7; c++) {
        b.place(single, 0, c);
      }
      for (var r = 1; r < 8; r++) {
        b.place(single, r, 7);
      }
      final res = b.place(single, 0, 7);
      expect(res.clearedRows, [0]);
      expect(res.clearedCols, [7]);
      expect(res.clearedCells.length, 15);
      expect(b.filledCount, 0);
    });

    test('clearFullestRows empties the busiest rows', () {
      final b = Board();
      for (var c = 0; c < 7; c++) {
        b.place(single, 5, c);
      }
      b.place(single, 2, 0);
      b.clearFullestRows(1);
      expect(b.filledCount, 1);
      expect(b.isEmpty(2, 0), isFalse);
    });
  });

  group('GameState', () {
    test('always deals a tray with at least one playable piece', () {
      for (var seed = 0; seed < 50; seed++) {
        final g = GameState(random: Random(seed));
        expect(g.tray.whereType<Piece>().any(g.board.fitsAnywhere), isTrue);
      }
    });

    test('random play eventually ends, and revive works once', () {
      final rnd = Random(7);
      final g = GameState(random: Random(1));
      var safety = 0;
      while (!g.isGameOver && safety++ < 5000) {
        final moves = [
          for (var i = 0; i < GameState.traySize; i++)
            for (var r = 0; r < 8; r++)
              for (var c = 0; c < 8; c++)
                if (g.canPlace(i, r, c)) (i, r, c),
        ];
        final (i, r, c) = moves[rnd.nextInt(moves.length)];
        expect(g.place(i, r, c), isTrue);
      }
      expect(g.isGameOver, isTrue);
      expect(g.score, greaterThan(0));
      expect(g.canRevive, isTrue);

      final filledBefore = g.board.filledCount;
      g.revive();
      expect(g.isGameOver, isFalse);
      expect(g.board.filledCount, lessThan(filledBefore));
      expect(g.revivesUsed, 1);
    });

    test('newGame resets everything', () {
      final g = GameState(random: Random(3));
      final i = g.tray.indexWhere((p) => p != null);
      g.place(i, 0, 0);
      g.newGame();
      expect(g.score, 0);
      expect(g.board.filledCount, 0);
      expect(g.tray.every((p) => p != null), isTrue);
    });
  });

  group('Scoring & combos', () {
    GameState emptyGame() {
      final g = GameState(random: Random(5));
      g.board.clear();
      return g;
    }

    test('combo survives up to 2 non-clearing moves, then resets', () {
      final g = emptyGame();
      // Fill rows 0..2 except the last cell, so singles can clear them.
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 7; c++) {
          g.board.setCell(r, c, 0);
        }
      }
      void put(int r, int c) {
        g.tray[0] = single;
        expect(g.place(0, r, c), isTrue);
      }

      put(0, 7);
      expect(g.combo, 1);
      put(7, 0); // no clear
      put(7, 2); // no clear
      put(1, 7); // clear within grace -> combo 2
      expect(g.combo, 2);
      expect(g.lastEvent!.points, 1 + GameState.clearPoints(1, 2));
      put(7, 4);
      put(7, 6);
      put(6, 0); // 3rd non-clearing move: combo lost
      expect(g.combo, 0);
      put(2, 7);
      expect(g.combo, 1);
    });

    test('perfect clear gives a bonus and praise', () {
      final g = emptyGame();
      for (var c = 0; c < 7; c++) {
        g.board.setCell(4, c, 2);
      }
      g.tray[0] = single;
      g.place(0, 4, 7);
      final e = g.lastEvent!;
      expect(e.perfect, isTrue);
      expect(e.praise, 'Perfect Clear!');
      expect(
        e.points,
        1 + GameState.clearPoints(1, 1) + GameState.perfectClearBonus,
      );
      expect(e.clearedColors.length, 8);
    });

    test('praise grows with lines cleared', () {
      PlaceEvent ev(int lines) => PlaceEvent(
        id: 1,
        placedCells: const {},
        colorIndex: 0,
        clearedColors: const {},
        lines: lines,
        combo: 1,
        points: 0,
        perfect: false,
        origin: const Cell(0, 0),
      );
      expect(ev(0).praise, isNull);
      expect(ev(1).praise, 'Nice');
      expect(ev(2).praise, 'Great!');
      expect(ev(3).praise, 'Excellent!');
      expect(ev(4).praise, 'Amazing!');
      expect(ev(5).praise, 'Incredible!');
      expect(ev(6).praise, 'Legendary!');
    });

    test('save and restore round-trips the whole game', () {
      final g = GameState(random: Random(9));
      final i = g.tray.indexWhere((p) => p != null);
      g.place(i, 0, 0);
      final copy = GameState.fromJson(g.toJson())!;
      expect(copy.board.cells, g.board.cells);
      expect(copy.score, g.score);
      expect(
        [for (final p in copy.tray) p?.cells],
        [for (final p in g.tray) p?.cells],
      );
      expect(GameState.fromJson({'v': 99}), isNull);
      expect(GameState.fromJson({'v': 1, 'size': 8, 'board': []}), isNull);
    });
  });
}
