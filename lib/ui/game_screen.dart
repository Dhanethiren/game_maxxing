import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../game/board.dart';
import '../game/game_state.dart';
import '../game/piece.dart';
import '../ml/offer_optimizer.dart';
import '../services/reward_offers.dart';
import 'piece_view.dart';
import 'revive_dialog.dart';
import 'theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.offers, this.game});

  final RewardOffers offers;

  /// Injected in tests; a fresh game otherwise.
  final GameState? game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState game = widget.game ?? GameState();
  final _gridKey = GlobalKey();

  int? _hoverTray, _hoverRow, _hoverCol;
  Set<Cell> _previewClear = {};
  Set<Cell> _flash = {};
  Timer? _flashTimer;
  bool _busy = false;
  bool _showGameOver = false;
  bool _newBest = false;
  bool _privacyRequired = false;

  RewardOffers get offers => widget.offers;

  @override
  void initState() {
    super.initState();
    game.addListener(_onGameChanged);
    offers.profile.onGameStarted();
    // Ads (and the consent form) start after the first frame is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await offers.ads.init();
      final required = await offers.ads.privacyOptionsRequired();
      if (mounted) setState(() => _privacyRequired = required);
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    game.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    setState(() {});
    if (game.isGameOver && !_busy && !_showGameOver) _handleGameOver();
  }

  // ---------------------------------------------------------------- dragging

  void _updateHover(int trayIndex, Offset globalTopLeft, double cell) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalTopLeft);
    final row = (local.dy / cell).round();
    final col = (local.dx / cell).round();
    if (row == _hoverRow && col == _hoverCol && trayIndex == _hoverTray) return;

    var preview = <Cell>{};
    final valid = game.canPlace(trayIndex, row, col);
    if (valid) {
      // Simulate the move on a copy to highlight the lines it would clear.
      final copy = Board.fromCells(game.board.size, game.board.cells);
      preview = copy.place(game.tray[trayIndex]!, row, col).clearedCells;
    }
    setState(() {
      _hoverTray = valid ? trayIndex : null;
      _hoverRow = valid ? row : null;
      _hoverCol = valid ? col : null;
      _previewClear = preview;
    });
  }

  void _clearHover() => setState(() {
        _hoverTray = _hoverRow = _hoverCol = null;
        _previewClear = {};
      });

  void _drop(int trayIndex) {
    final row = _hoverRow, col = _hoverCol;
    _clearHover();
    if (row == null || col == null || _busy) return;
    if (!game.place(trayIndex, row, col)) return;

    if (game.lastCleared.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _flashCells(game.lastCleared);
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _flashCells(Set<Cell> cells) {
    _flashTimer?.cancel();
    setState(() => _flash = cells);
    _flashTimer = Timer(const Duration(milliseconds: 320), () {
      if (mounted) setState(() => _flash = {});
    });
  }

  // ---------------------------------------------------- game over & revive

  Future<void> _handleGameOver() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    if (game.canRevive && offers.ads.isReady) {
      final decision = offers.decideRevive(game);
      if (decision.variant == OfferVariant.calm) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
      }
      final accepted = await showReviveOffer(
        context,
        variant: decision.variant,
        score: game.score,
        bestScore: offers.profile.bestScore,
      );
      await offers.recordAnswer(decision, accepted: accepted);

      if (accepted) {
        final earned = await offers.watchAd();
        if (!mounted) return;
        if (earned) {
          game.revive();
          _flashCells(game.lastCleared);
          setState(() => _busy = false);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The ad didn\'t finish, so no revive this time.')),
        );
      }
    }

    final newBest = await offers.profile.submitScore(game.score);
    if (!mounted) return;
    setState(() {
      _newBest = newBest;
      _showGameOver = true;
      _busy = false;
    });
  }

  void _playAgain() {
    offers.profile.onGameStarted();
    setState(() {
      _showGameOver = false;
      _newBest = false;
    });
    game.newGame();
  }

  void _showModelStats() {
    final stats = offers.optimizer.stats();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ad-offer model (debug)'),
        content: Text(
          stats.isEmpty
              ? 'No offers recorded yet.'
              : stats.entries
                  .map((e) => '${e.key}: ${e.value.accepted}/${e.value.shown} accepted')
                  .join('\n'),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: CalmPalette.backgroundGradient,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final boardSide = (constraints.maxWidth - 32)
                .clamp(0.0, constraints.maxHeight * 0.58)
                .clamp(0.0, 520.0);
            final cell = boardSide / game.boardSize;
            return Column(
              children: [
                _header(),
                const SizedBox(height: 4),
                SizedBox(height: 28, child: _cheer()),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: boardSide,
                    height: boardSide,
                    child: Stack(
                      children: [
                        _board(cell),
                        if (_showGameOver) _gameOverPanel(),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _tray(cell, constraints.maxWidth),
                const Spacer(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: kDebugMode ? _showModelStats : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BEST',
                      style: TextStyle(
                          fontSize: 12, letterSpacing: 2, color: CalmPalette.textSoft)),
                  Text('${offers.profile.bestScore}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(end: game.score.toDouble()),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) => Text(
              '${value.round()}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_privacyRequired)
                  IconButton(
                    tooltip: 'Privacy options',
                    icon: const Icon(Icons.privacy_tip_outlined, color: CalmPalette.textSoft),
                    onPressed: offers.ads.showPrivacyOptions,
                  ),
                IconButton(
                  tooltip: 'Restart',
                  icon: const Icon(Icons.refresh_rounded, color: CalmPalette.textSoft),
                  onPressed: _busy ? null : _playAgain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cheer() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          game.combo > 1 ? '${game.cheer}  ×${game.combo}' : (game.cheer ?? ''),
          key: ValueKey('${game.cheer}${game.movesMade}'),
          style: const TextStyle(
              fontSize: 18, color: CalmPalette.accent, fontWeight: FontWeight.w600),
        ),
      );

  Widget _board(double cell) {
    final hoverPiece = _hoverTray == null ? null : game.tray[_hoverTray!];
    final ghost = <Cell>{
      if (hoverPiece != null)
        for (final c in hoverPiece.cells) Cell(_hoverRow! + c.row, _hoverCol! + c.col),
    };
    final size = game.boardSize;

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_busy,
      onMove: (d) => _updateHover(d.data, d.offset, cell),
      onLeave: (_) => _clearHover(),
      onAcceptWithDetails: (d) => _drop(d.data),
      builder: (context, _, _) => Container(
        decoration: BoxDecoration(
          color: CalmPalette.boardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          key: _gridKey,
          width: cell * size,
          height: cell * size,
          child: Stack(
            children: [
              for (var r = 0; r < size; r++)
                for (var c = 0; c < size; c++)
                  Positioned(
                    left: c * cell + 1.5,
                    top: r * cell + 1.5,
                    child: _cellTile(r, c, cell - 3, ghost, hoverPiece),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellTile(int r, int c, double size, Set<Cell> ghost, Piece? hoverPiece) {
    final cell = Cell(r, c);
    final value = game.board.at(r, c);
    Color color;
    if (_previewClear.contains(cell) && hoverPiece != null) {
      color = CalmPalette.blocks[hoverPiece.colorIndex];
    } else if (value != null) {
      color = CalmPalette.blocks[value];
    } else if (ghost.contains(cell)) {
      color = CalmPalette.blocks[hoverPiece!.colorIndex].withValues(alpha: 0.45);
    } else {
      color = CalmPalette.emptyCell;
    }
    return BlockTile(color: color, size: size, glow: _flash.contains(cell));
  }

  Widget _tray(double boardCell, double width) {
    final slotWidth = (width - 32) / GameState.traySize;
    final trayCell = (boardCell * 0.55).clamp(0.0, slotWidth / 5.5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < GameState.traySize; i++)
            SizedBox(
              width: slotWidth,
              height: trayCell * 5.5,
              child: Center(child: _trayPiece(i, boardCell, trayCell)),
            ),
        ],
      ),
    );
  }

  Widget _trayPiece(int index, double boardCell, double trayCell) {
    final piece = game.tray[index];
    if (piece == null) return const SizedBox.shrink();
    final fits = game.board.fitsAnywhere(piece);
    final small = PieceView(piece: piece, cellSize: trayCell);
    final big = PieceView(piece: piece, cellSize: boardCell);
    // The dragged piece floats above the finger so it isn't hidden by it.
    final lift = boardCell * 1.4;

    return Draggable<int>(
      data: index,
      maxSimultaneousDrags: (_busy || !fits) ? 0 : 1,
      dragAnchorStrategy: (_, _, _) => Offset(big.width / 2, big.height + lift),
      feedback: Opacity(opacity: 0.92, child: big),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: HapticFeedback.selectionClick,
      onDraggableCanceled: (_, _) => _clearHover(),
      // A generous invisible hit area makes small pieces easy to pick up.
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(trayCell),
        child: Opacity(opacity: fits ? 1 : 0.35, child: small),
      ),
    );
  }

  Widget _gameOverPanel() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_newBest ? 'New best!' : 'Well played',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${game.score} points',
                style: const TextStyle(fontSize: 20, color: CalmPalette.textSoft)),
            const SizedBox(height: 4),
            Text('${game.linesClearedTotal} lines cleared',
                style: const TextStyle(color: CalmPalette.textSoft)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _playAgain,
              style: FilledButton.styleFrom(
                backgroundColor: CalmPalette.accent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Play again', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
