import 'dart:math';

import 'piece.dart';

/// What a Journey level asks the player to do.
enum LevelGoal {
  /// Reach a target score.
  score,

  /// Clear the blocks that hold gems.
  gems,
}

/// One Journey level: a starting board (a symmetric "picture" of blocks), a
/// goal, and a par number of moves for the star rating.
///
/// Levels are generated from their number, so they are the same for every
/// player and need no level files.
class LevelSpec {
  LevelSpec._({
    required this.number,
    required this.goal,
    required this.target,
    required this.cells,
    required this.gems,
    required this.par,
  });

  static const boardSize = 8;

  final int number;
  final LevelGoal goal;
  final int target;

  /// Starting board, row-major, `null` = empty.
  final List<int?> cells;
  final Set<Cell> gems;

  /// Moves for 3 stars; 1.5x par for 2 stars; anything more is 1 star.
  final int par;

  int starsFor(int moves) =>
      moves <= par ? 3 : (moves <= (par * 1.5).ceil() ? 2 : 1);

  String get goalText =>
      goal == LevelGoal.score ? 'Score $target' : 'Collect $target gems';

  factory LevelSpec.generate(int number) {
    final n = max(1, number);
    final r = Random(n * 7919 + 13);
    const size = boardSize;

    // Every third level (from 3) is a gem level; the rest are score levels.
    final goal = n >= 3 && n % 3 == 0 ? LevelGoal.gems : LevelGoal.score;

    // Starting fill grows slowly from 10% to about 36%.
    final fill = 0.10 + min(n, 45) * 0.006;
    final cells = List<int?>.filled(size * size, null);
    final palette = [r.nextInt(7), r.nextInt(7), r.nextInt(7)];
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size ~/ 2; col++) {
        if (r.nextDouble() < fill) {
          final color = palette[(row + col) % palette.length];
          cells[row * size + col] = color;
          cells[row * size + (size - 1 - col)] =
              color; // mirror: looks designed
        }
      }
    }
    _breakFullLines(cells, size, r);

    var gems = <Cell>{};
    var target = 0;
    if (goal == LevelGoal.gems) {
      target = min(3 + n ~/ 4, 12);
      final filled = [
        for (var i = 0; i < cells.length; i++)
          if (cells[i] != null) i,
      ]..shuffle(r);
      // Make sure there are enough blocks to hold the gems.
      var i = 0;
      while (filled.length < target) {
        final idx = r.nextInt(cells.length);
        if (cells[idx] == null) {
          cells[idx] = palette[i++ % palette.length];
          filled.add(idx);
        }
      }
      _breakFullLines(cells, size, r);
      gems = {
        for (final idx in filled.where((x) => cells[x] != null).take(target))
          Cell(idx ~/ size, idx % size),
      };
      target = gems.length;
    } else {
      target = (100 + (n - 1) * 45).clamp(100, 2500);
    }

    final par = goal == LevelGoal.gems
        ? 4 + target * 2
        : max(6, (target / 11).round());
    return LevelSpec._(
      number: n,
      goal: goal,
      target: target,
      cells: cells,
      gems: gems,
      par: par,
    );
  }

  /// A level must not start with a full row or column (it would clear itself).
  static void _breakFullLines(List<int?> cells, int size, Random r) {
    for (var row = 0; row < size; row++) {
      if (List.generate(
        size,
        (c) => cells[row * size + c] != null,
      ).every((x) => x)) {
        cells[row * size + r.nextInt(size)] = null;
      }
    }
    for (var col = 0; col < size; col++) {
      if (List.generate(
        size,
        (row) => cells[row * size + col] != null,
      ).every((x) => x)) {
        cells[r.nextInt(size) * size + col] = null;
      }
    }
  }
}
