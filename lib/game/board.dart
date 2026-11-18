import 'piece.dart';

/// Result of placing a piece.
class PlaceResult {
  const PlaceResult({
    required this.clearedRows,
    required this.clearedCols,
    required this.clearedCells,
  });

  final List<int> clearedRows;
  final List<int> clearedCols;
  final Set<Cell> clearedCells;

  int get linesCleared => clearedRows.length + clearedCols.length;
}

/// The square play grid. `null` = empty, otherwise the colour index of a block.
class Board {
  Board({this.size = 8}) : _cells = List.filled(size * size, null);

  Board.fromCells(this.size, List<int?> cells) : _cells = List.of(cells);

  final int size;
  final List<int?> _cells;

  List<int?> get cells => List.unmodifiable(_cells);

  int? at(int row, int col) => _cells[row * size + col];

  bool isEmpty(int row, int col) => at(row, col) == null;

  int get filledCount => _cells.where((c) => c != null).length;

  double get fillRatio => filledCount / (size * size);

  bool canPlace(Piece piece, int row, int col) {
    for (final c in piece.cells) {
      final r = row + c.row, k = col + c.col;
      if (r < 0 || k < 0 || r >= size || k >= size) return false;
      if (!isEmpty(r, k)) return false;
    }
    return true;
  }

  /// True if [piece] fits anywhere on the board.
  bool fitsAnywhere(Piece piece) {
    for (var r = 0; r <= size - piece.rows; r++) {
      for (var c = 0; c <= size - piece.cols; c++) {
        if (canPlace(piece, r, c)) return true;
      }
    }
    return false;
  }

  /// Places [piece] with its top-left at ([row], [col]) and clears any full
  /// rows and columns. Callers must check [canPlace] first.
  PlaceResult place(Piece piece, int row, int col) {
    assert(canPlace(piece, row, col));
    for (final c in piece.cells) {
      _cells[(row + c.row) * size + col + c.col] = piece.colorIndex;
    }

    final fullRows = [
      for (var r = 0; r < size; r++)
        if (List.generate(size, (c) => !isEmpty(r, c)).every((x) => x)) r,
    ];
    final fullCols = [
      for (var c = 0; c < size; c++)
        if (List.generate(size, (r) => !isEmpty(r, c)).every((x) => x)) c,
    ];

    final cleared = <Cell>{
      for (final r in fullRows)
        for (var c = 0; c < size; c++) Cell(r, c),
      for (final c in fullCols)
        for (var r = 0; r < size; r++) Cell(r, c),
    };
    for (final cell in cleared) {
      _cells[cell.row * size + cell.col] = null;
    }
    return PlaceResult(
      clearedRows: fullRows,
      clearedCols: fullCols,
      clearedCells: cleared,
    );
  }

  /// Empties the [count] fullest rows. Used by the "revive" reward to give the
  /// player room to keep going.
  Set<Cell> clearFullestRows(int count) {
    final order = List.generate(size, (r) => r)
      ..sort((a, b) => _rowFill(b).compareTo(_rowFill(a)));
    final cleared = <Cell>{};
    for (final r in order.take(count)) {
      for (var c = 0; c < size; c++) {
        if (!isEmpty(r, c)) cleared.add(Cell(r, c));
        _cells[r * size + c] = null;
      }
    }
    return cleared;
  }

  int _rowFill(int r) =>
      List.generate(size, (c) => isEmpty(r, c) ? 0 : 1).fold(0, (a, b) => a + b);

  void clear() => _cells.fillRange(0, _cells.length, null);
}
