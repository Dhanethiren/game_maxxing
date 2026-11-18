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
}
