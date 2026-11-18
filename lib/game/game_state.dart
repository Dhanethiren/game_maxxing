import 'dart:math';

import 'package:flutter/foundation.dart';

import 'board.dart';
import 'piece.dart';

/// All game rules and scoring. UI-free so it can be unit tested.
class GameState extends ChangeNotifier {
  GameState({Random? random, this.boardSize = 8})
      : _random = random ?? Random(),
        board = Board(size: boardSize) {
    _generator = PieceGenerator(_random);
    _dealTray();
    startedAt = DateTime.now();
  }

  static const int traySize = 3;

  /// How many times a player may revive within one game.
  static const int maxRevivesPerGame = 1;

  final Random _random;
  final int boardSize;
  late final PieceGenerator _generator;

  final Board board;

  /// Pieces waiting to be placed; `null` once a slot has been used.
  final List<Piece?> tray = List.filled(traySize, null);

  int score = 0;
  int combo = 0;
  int linesClearedTotal = 0;
  int movesMade = 0;
  int revivesUsed = 0;
  bool isGameOver = false;
  late DateTime startedAt;

  /// Cells that were just cleared, so the UI can animate them.
  Set<Cell> lastCleared = {};

  /// A short calm message to show after a good move.
  String? cheer;

  bool get canRevive => isGameOver && revivesUsed < maxRevivesPerGame;

  Duration get elapsed => DateTime.now().difference(startedAt);

  void newGame() {
    board.clear();
    score = 0;
    combo = 0;
    linesClearedTotal = 0;
    movesMade = 0;
    revivesUsed = 0;
    isGameOver = false;
    lastCleared = {};
    cheer = null;
    startedAt = DateTime.now();
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

    score += piece.size;
    if (result.linesCleared > 0) {
      combo++;
      linesClearedTotal += result.linesCleared;
      // 10 points per line, bonus for clearing several at once, and a gentle
      // streak multiplier for clearing on consecutive moves.
      final lines = result.linesCleared;
      score += lines * 10 * lines * combo;
      cheer = _cheers[_random.nextInt(_cheers.length)];
    } else {
      combo = 0;
      cheer = null;
    }
    lastCleared = result.clearedCells;

    if (tray.every((p) => p == null)) _dealTray();
    _checkGameOver();
    notifyListeners();
    return true;
  }

  /// Gives the player a second chance: empties the fullest rows and deals a
  /// fresh tray that is guaranteed to fit.
  void revive() {
    if (!canRevive) return;
    revivesUsed++;
    lastCleared = board.clearFullestRows(3);
    isGameOver = false;
    combo = 0;
    cheer = 'Fresh start. Breathe.';
    _dealTray();
    _checkGameOver();
    notifyListeners();
  }

  void _dealTray() {
    // Deal pieces, but make sure at least one of them fits so the player is
    // never handed an instantly lost position. Up to 30 attempts, then fall back
    // to small pieces.
    for (var attempt = 0; attempt < 30; attempt++) {
      final maxSize = attempt < 20 ? 99 : 3;
      for (var i = 0; i < traySize; i++) {
        tray[i] = _generator.next(maxSize: maxSize);
      }
      if (tray.any((p) => board.fitsAnywhere(p!))) return;
    }
    tray[0] = Piece(const [Cell(0, 0)], 0);
  }

  void _checkGameOver() {
    final remaining = tray.whereType<Piece>();
    isGameOver = remaining.isNotEmpty && !remaining.any(board.fitsAnywhere);
  }

  static const _cheers = [
    'Nice.',
    'Smooth.',
    'Lovely.',
    'So calm.',
    'Clean!',
    'Flowing.',
    'Easy does it.',
  ];
}
