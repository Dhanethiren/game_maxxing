import 'dart:math';

import 'package:flutter/foundation.dart';

import 'board.dart';
import 'piece.dart';

/// Everything that happened in one placement, so the UI can play the right
/// animation and sound.
class PlaceEvent {
  const PlaceEvent({
    required this.id,
    required this.placedCells,
    required this.colorIndex,
    required this.clearedColors,
    required this.lines,
    required this.combo,
    required this.points,
    required this.perfect,
    required this.origin,
  });

  final int id;
  final Set<Cell> placedCells;
  final int colorIndex;

  /// Cleared cell -> the colour it had.
  final Map<Cell, int> clearedColors;
  final int lines;
  final int combo;
  final int points;

  /// The whole board was emptied.
  final bool perfect;

  /// Where the piece landed (top-left), for effects that radiate outwards.
  final Cell origin;

  /// Short praise shown on screen, or null for a plain placement.
  String? get praise {
    if (perfect) return 'Perfect Clear!';
    return switch (lines) {
      0 => null,
      1 => 'Nice',
      2 => 'Great!',
      3 => 'Excellent!',
      _ => 'Amazing!',
    };
  }
}

/// All game rules and scoring. UI-free so it can be unit tested.
class GameState extends ChangeNotifier {
  GameState({Random? random, this.boardSize = 8})
    : _random = random ?? Random(),
      board = Board(size: boardSize) {
    _generator = PieceGenerator(_random);
    _dealTray();
  }

  static const int traySize = 3;

  /// How many times a player may revive within one game.
  static const int maxRevivesPerGame = 1;

  /// A combo survives this many placements without a clear, so players can
  /// set up the next line without losing their streak.
  static const int comboGraceMoves = 3;

  static const int perfectClearBonus = 300;

  final Random _random;
  final int boardSize;
  late final PieceGenerator _generator;

  final Board board;

  /// Pieces waiting to be placed; `null` once a slot has been used.
  final List<Piece?> tray = List.filled(traySize, null);

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  int linesClearedTotal = 0;
  int movesMade = 0;
  int perfectClears = 0;
  int revivesUsed = 0;
  bool isGameOver = false;
  int _movesSinceClear = 0;
  int _eventId = 0;

  Duration _elapsedBefore = Duration.zero;
  DateTime _segmentStart = DateTime.now();

  PlaceEvent? lastEvent;

  bool get canRevive => isGameOver && revivesUsed < maxRevivesPerGame;

  Duration get elapsed =>
      _elapsedBefore + DateTime.now().difference(_segmentStart);

  /// Points a clear of [lines] lines is worth at combo level [combo].
  static int clearPoints(int lines, int combo) =>
      lines == 0 ? 0 : 10 * lines * (lines + 1) ~/ 2 * max(combo, 1);

  void newGame() {
    board.clear();
    score = 0;
    combo = 0;
    maxCombo = 0;
    linesClearedTotal = 0;
    movesMade = 0;
    perfectClears = 0;
    revivesUsed = 0;
    isGameOver = false;
    _movesSinceClear = 0;
    _elapsedBefore = Duration.zero;
    _segmentStart = DateTime.now();
    lastEvent = null;
    _dealTray();
    notifyListeners();
  }

  bool canPlace(int trayIndex, int row, int col) {
    final piece = tray[trayIndex];
    return piece != null && !isGameOver && board.canPlace(piece, row, col);
  }

  /// Places the tray piece. Returns false if the move is illegal.
  bool place(int trayIndex, int row, int col) {
    if (!canPlace(trayIndex, row, col)) return false;
    final piece = tray[trayIndex]!;
    final result = board.place(piece, row, col);
    tray[trayIndex] = null;
    movesMade++;

    var points = piece.size;
    final lines = result.linesCleared;
    if (lines > 0) {
      combo = (combo > 0 && _movesSinceClear < comboGraceMoves) ? combo + 1 : 1;
      maxCombo = max(maxCombo, combo);
      _movesSinceClear = 0;
      linesClearedTotal += lines;
      points += clearPoints(lines, combo);
    } else {
      _movesSinceClear++;
      if (_movesSinceClear >= comboGraceMoves) combo = 0;
    }
    final perfect = lines > 0 && board.filledCount == 0;
    if (perfect) {
      perfectClears++;
      points += perfectClearBonus;
    }
    score += points;

    lastEvent = PlaceEvent(
      id: ++_eventId,
      placedCells: {
        for (final c in piece.cells) Cell(row + c.row, col + c.col),
      },
      colorIndex: piece.colorIndex,
      clearedColors: result.clearedColors,
      lines: lines,
      combo: lines > 0 ? combo : 0,
      points: points,
      perfect: perfect,
      origin: Cell(row, col),
    );

    if (tray.every((p) => p == null)) _dealTray();
    _checkGameOver();
    notifyListeners();
    return true;
  }

  /// Gives the player a second chance: empties the fullest rows and deals a
  /// fresh tray that is guaranteed to fit.
  Set<Cell> revive() {
    if (!canRevive) return {};
    revivesUsed++;
    final cleared = board.clearFullestRows(3);
    isGameOver = false;
    combo = 0;
    _movesSinceClear = 0;
    _dealTray();
    _checkGameOver();
    notifyListeners();
    return cleared;
  }

  /// Deals 3 new pieces. The dealer is *fair, never cruel*: it never
  /// deliberately deals an unplayable hand (a known trick for selling revive
  /// ads, which we refuse to use), and when the board gets crowded it leans
  /// towards smaller and line-completing pieces so the game stays relaxing.
  void _dealTray() {
    final fill = board.fillRatio;
    final crowded = fill > 0.55;
    for (var attempt = 0; attempt < 30; attempt++) {
      for (var i = 0; i < traySize; i++) {
        final maxSize = attempt >= 20 ? 3 : (crowded && i == 0 ? 4 : 99);
        tray[i] = _generator.next(maxSize: maxSize);
      }
      // Sometimes swap one piece for one that can finish a line right now.
      if (fill > 0.25 && _random.nextDouble() < (crowded ? 0.6 : 0.3)) {
        final helpful = _findHelpfulPiece();
        if (helpful != null) tray[_random.nextInt(traySize)] = helpful;
      }
      if (tray.any((p) => board.fitsAnywhere(p!))) return;
    }
    tray[0] = const Piece([Cell(0, 0)], 0);
  }

  Piece? _findHelpfulPiece() {
    for (var i = 0; i < 10; i++) {
      final candidate = _generator.next();
      for (var r = 0; r <= boardSize - candidate.rows; r++) {
        for (var c = 0; c <= boardSize - candidate.cols; c++) {
          if (board.linesIfPlaced(candidate, r, c) > 0) return candidate;
        }
      }
    }
    return null;
  }

  void _checkGameOver() {
    final remaining = tray.whereType<Piece>();
    isGameOver = remaining.isNotEmpty && !remaining.any(board.fitsAnywhere);
  }

  // ------------------------------------------------------------ save/restore

  Map<String, dynamic> toJson() => {
    'v': 1,
    'size': boardSize,
    'board': board.cells,
    'tray': [for (final p in tray) p?.toJson()],
    'score': score,
    'combo': combo,
    'maxCombo': maxCombo,
    'lines': linesClearedTotal,
    'moves': movesMade,
    'perfect': perfectClears,
    'revives': revivesUsed,
    'sinceClear': _movesSinceClear,
    'elapsedMs': elapsed.inMilliseconds,
  };

  /// Restores a saved game. Returns null if the data is missing or invalid.
  static GameState? fromJson(Map<String, dynamic>? json, {Random? random}) {
    if (json == null || json['v'] != 1) return null;
    try {
      final size = json['size'] as int;
      final g = GameState(random: random, boardSize: size);
      final cells = [for (final v in json['board'] as List) v as int?];
      if (cells.length != size * size) return null;
      for (var i = 0; i < cells.length; i++) {
        g.board.setCell(i ~/ size, i % size, cells[i]);
      }
      final tray = json['tray'] as List;
      for (var i = 0; i < traySize; i++) {
        g.tray[i] = tray[i] == null
            ? null
            : Piece.fromJson(tray[i] as Map<String, dynamic>);
      }
      if (g.tray.every((p) => p == null)) g._dealTray();
      g
        ..score = json['score'] as int
        ..combo = json['combo'] as int
        ..maxCombo = json['maxCombo'] as int
        ..linesClearedTotal = json['lines'] as int
        ..movesMade = json['moves'] as int
        ..perfectClears = json['perfect'] as int
        ..revivesUsed = json['revives'] as int
        .._movesSinceClear = json['sinceClear'] as int
        .._elapsedBefore = Duration(milliseconds: json['elapsedMs'] as int);
      g._checkGameOver();
      return g;
    } catch (_) {
      return null;
    }
  }
}
