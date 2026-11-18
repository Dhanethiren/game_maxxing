import 'dart:math';

import 'package:flutter/foundation.dart';

/// A cell offset inside a piece, relative to the piece's top-left corner.
@immutable
class Cell {
  const Cell(this.row, this.col);
  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}

/// A block shape the player drags onto the board.
@immutable
class Piece {
  const Piece(this.cells, this.colorIndex);

  final List<Cell> cells;

  /// Index into [CalmPalette.blocks].
  final int colorIndex;

  int get rows => cells.map((c) => c.row).reduce(max) + 1;
  int get cols => cells.map((c) => c.col).reduce(max) + 1;
  int get size => cells.length;

  Map<String, dynamic> toJson() => {
    'c': [
      for (final c in cells) [c.row, c.col],
    ],
    'k': colorIndex,
  };

  static Piece fromJson(Map<String, dynamic> json) => Piece([
    for (final c in json['c'] as List) Cell((c as List)[0] as int, c[1] as int),
  ], json['k'] as int);
}

/// Builds a shape from an ASCII drawing, e.g. `['##', '#.']`.
List<Cell> _shape(List<String> rows) => [
  for (var r = 0; r < rows.length; r++)
    for (var c = 0; c < rows[r].length; c++)
      if (rows[r][c] == '#') Cell(r, c),
];

/// Every shape the game can deal, with a relative weight.
///
/// Small shapes are a little more common so the board rarely feels hopeless,
/// which keeps the game relaxing rather than punishing.
final List<(List<Cell>, int)> kShapes = [
  (_shape(['#']), 3),
  (_shape(['##']), 4),
  (_shape(['#', '#']), 4),
  (_shape(['###']), 4),
  (_shape(['#', '#', '#']), 4),
  (_shape(['####']), 2),
  (_shape(['#', '#', '#', '#']), 2),
  (_shape(['#####']), 1),
  (_shape(['#', '#', '#', '#', '#']), 1),
  (_shape(['##', '##']), 4),
  (_shape(['###', '###', '###']), 1),
  (_shape(['##', '#.']), 3),
  (_shape(['##', '.#']), 3),
  (_shape(['#.', '##']), 3),
  (_shape(['.#', '##']), 3),
  (_shape(['#..', '###']), 2),
  (_shape(['..#', '###']), 2),
  (_shape(['###', '#..']), 2),
  (_shape(['###', '..#']), 2),
  (_shape(['#.', '#.', '##']), 2),
  (_shape(['.#', '.#', '##']), 2),
  (_shape(['###', '.#.']), 2),
  (_shape(['.#.', '###']), 2),
  (_shape(['##.', '.##']), 1),
  (_shape(['.##', '##.']), 1),
];

/// Deals random pieces using [kShapes] weights.
class PieceGenerator {
  PieceGenerator([Random? random]) : _random = random ?? Random();

  final Random _random;
  late final int _totalWeight = kShapes.fold(0, (sum, s) => sum + s.$2);

  Piece next({int maxSize = 99}) {
    while (true) {
      var roll = _random.nextInt(_totalWeight);
      for (final (cells, weight) in kShapes) {
        roll -= weight;
        if (roll < 0) {
          if (cells.length <= maxSize) {
            return Piece(cells, _random.nextInt(7));
          }
          break;
        }
      }
    }
  }
}
