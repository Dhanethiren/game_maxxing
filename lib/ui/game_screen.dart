import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../audio/sound_service.dart';
import '../game/board.dart';
import '../game/game_state.dart';
import '../game/piece.dart';
import '../ml/offer_optimizer.dart';
import '../services/progression.dart';
import 'block_painter.dart';
import 'board_painter.dart';
import 'dialogs.dart';
import 'effects.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.game, this.resume = false});

  /// Injected in tests.
  final GameState? game;

  /// Continue the saved game instead of starting a new one.
  final bool resume;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AppServices app;
  late GameState game;
  bool _initialised = false;

  final _stackKey = GlobalKey();
  final _boardKey = GlobalKey();
  final _effects = EffectsController();

  // Dragging.
  int? _dragIndex;
  Offset? _dragPointer; // global
  int? _hoverRow, _hoverCol;
  Set<Cell> _previewClear = {};

  // Animations.
  late final _clearAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final _settleAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final _shakeAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Map<Cell, int> _clearing = {};
  Cell? _clearOrigin;
  Set<Cell> _settling = {};
  double _shakeAmp = 0;
  PlaceEvent? _praise;
  int _lastEventId = 0;

  // Game over.
  bool _busy = false;
  bool _showGameOver = false;
  bool _newBest = false;
  int _coinsEarned = 0;
  bool _coinsDoubled = false;
  List<int> _levelsReached = [];
  OfferDecision? _doubleDecision;
  bool _doubleAnswered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    app = AppScope.read(context);
    game =
        widget.game ??
        (widget.resume ? GameState.fromJson(app.profile.savedGame) : null) ??
        GameState();
    _lastEventId = game.lastEvent?.id ?? 0;
    game.addListener(_onGameChanged);
    app.profile.onGameStarted();
    for (final c in [_clearAnim, _settleAnim, _shakeAnim]) {
      c.addListener(() => setState(() {}));
    }
    if (game.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleGameOver());
    }
  }

  @override
  void dispose() {
    game.removeListener(_onGameChanged);
    _clearAnim.dispose();
    _settleAnim.dispose();
    _shakeAnim.dispose();
    _effects.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    final e = game.lastEvent;
    if (e != null && e.id != _lastEventId) {
      _lastEventId = e.id;
      _onPlaced(e);
    }
    setState(() {});
    if (game.isGameOver && !_busy && !_showGameOver) _handleGameOver();
  }

  // ------------------------------------------------------------ placement fx

  void _onPlaced(PlaceEvent e) {
    app.sound.place();
    app.lightHaptic();
    _settling = e.placedCells;
    _settleAnim.forward(from: 0);

    if (e.lines > 0) {
      _clearing = e.clearedColors;
      _clearOrigin = e.origin;
      _clearAnim.forward(from: 0);
      app.sound.clear(lines: e.lines, combo: e.combo);
      if (e.perfect) {
        app.sound.play(Sfx.perfect);
        app.heavyHaptic();
      } else {
        app.mediumHaptic();
      }
      _praise = e;
      if (e.lines >= 2 || e.perfect) {
        _shakeAmp = e.perfect ? 7 : min(3.0 + (e.lines - 2) * 1.5, 6);
        _shakeAnim.forward(from: 0);
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _spawnClearEffects(e),
      );
    }

    final missions = app.profile.missions();
    final done = [...missions.onPlace(e), ...missions.onScore(game.score)];
    app.profile.commitMissions(done);
    _announceMissions(done);

    if (!app.profile.tutorialDone) app.profile.setTutorialDone();
    if (!game.isGameOver) app.profile.saveGame(game.toJson());
  }

  void _spawnClearEffects(PlaceEvent e) {
    final cellCenter = _cellCenterInStack();
    if (cellCenter == null) return;
    final theme = app.theme;
    final perCell = e.clearedColors.length > 14 ? 2 : 3;
    var sum = Offset.zero;
    for (final MapEntry(key: cell, value: color) in e.clearedColors.entries) {
      final center = cellCenter(cell);
      sum += center;
      _effects.burst(center, theme.blocks[color], count: perCell);
    }
    if (e.perfect) {
      final board = _boardRectInStack();
      if (board != null) {
        for (var i = 0; i < 36; i++) {
          _effects.burst(
            board.center,
            theme.blocks[i % theme.blocks.length],
            count: 1,
            speed: 420,
          );
        }
      }
    }
    final centroid = sum / e.clearedColors.length.toDouble();
    _effects.floatText(
      '+${e.points}',
      centroid,
      theme.accent,
      26 * uiScale(context),
    );
  }

  void _announceMissions(List<Mission> done) {
    for (final m in done) {
      app.sound.play(Sfx.coin);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: app.theme.accent,
          duration: const Duration(seconds: 2),
          content: Text(
            'Mission complete: ${m.title}  +${m.reward} coins',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  // ----------------------------------------------------------- geometry

  RenderBox? _box(GlobalKey key) =>
      key.currentContext?.findRenderObject() as RenderBox?;

  Rect? _boardRectInStack() {
    final board = _box(_boardKey), stack = _box(_stackKey);
    if (board == null || stack == null || !board.hasSize) return null;
    final topLeft = stack.globalToLocal(board.localToGlobal(Offset.zero));
    return topLeft & board.size;
  }

  double get _boardCell {
    final board = _box(_boardKey);
    if (board == null || !board.hasSize) return 40;
    return BoardPainter.cellSize(board.size.width, game.boardSize);
  }

  Offset Function(Cell)? _cellCenterInStack() {
    final rect = _boardRectInStack();
    if (rect == null) return null;
    final cell = BoardPainter.cellSize(rect.width, game.boardSize);
    final pad = cell * BoardPainter.framePadding;
    return (c) =>
        rect.topLeft +
        Offset(pad + (c.col + 0.5) * cell, pad + (c.row + 0.5) * cell);
  }

  /// Top-left of the dragged piece, in global coordinates. The piece floats
  /// above the finger so the player can see where it will land.
  Offset _dragTopLeft(Piece piece, Offset pointer) {
    final cell = _boardCell;
    final lift = cell * 0.9;
    return pointer - Offset(piece.cols * cell / 2, piece.rows * cell + lift);
  }

  // ------------------------------------------------------------- dragging

  void _dragStart(int index, Offset pointer) {
    if (_busy || _dragIndex != null || game.tray[index] == null) return;
    app.sound.play(Sfx.pickup);
    app.lightHaptic();
    setState(() {
      _dragIndex = index;
      _dragPointer = pointer;
    });
    _updateHover();
  }

  void _dragMove(int index, Offset pointer) {
    if (_dragIndex != index) return;
    _dragPointer = pointer;
    _updateHover();
  }

  void _updateHover() {
    final index = _dragIndex, pointer = _dragPointer;
    final board = _box(_boardKey);
    if (index == null || pointer == null || board == null) return;
    final piece = game.tray[index]!;
    final cell = _boardCell;
    final pad = cell * BoardPainter.framePadding;
    final local =
        board.globalToLocal(_dragTopLeft(piece, pointer)) - Offset(pad, pad);
    final rf = local.dy / cell, cf = local.dx / cell;

    // Forgiving snap: try the nearest grid positions, closest first.
    final candidates =
        <(int, int)>{
          (rf.floor(), cf.floor()),
          (rf.floor(), cf.ceil()),
          (rf.ceil(), cf.floor()),
          (rf.ceil(), cf.ceil()),
        }.toList()..sort(
          (a, b) => (pow(a.$1 - rf, 2) + pow(a.$2 - cf, 2)).compareTo(
            pow(b.$1 - rf, 2) + pow(b.$2 - cf, 2),
          ),
        );
    int? row, col;
    for (final (r, c) in candidates) {
      if ((r - rf).abs() < 0.8 &&
          (c - cf).abs() < 0.8 &&
          game.canPlace(index, r, c)) {
        row = r;
        col = c;
        break;
      }
    }

    var preview = <Cell>{};
    if (row != null && col != null && (row != _hoverRow || col != _hoverCol)) {
      preview = Board.fromCells(
        game.boardSize,
        game.board.cells,
      ).place(piece, row, col).clearedCells;
    } else if (row != null) {
      preview = _previewClear;
    }
    setState(() {
      _hoverRow = row;
      _hoverCol = col;
      _previewClear = preview;
    });
  }

  void _dragEnd(int index) {
    if (_dragIndex != index) return;
    final row = _hoverRow, col = _hoverCol;
    final overBoard = _isPointerOverBoard();
    setState(() {
      _dragIndex = null;
      _dragPointer = null;
      _hoverRow = _hoverCol = null;
      _previewClear = {};
    });
    if (row != null && col != null) {
      game.place(index, row, col);
    } else if (overBoard) {
      app.sound.play(Sfx.invalid);
    }
  }

  bool _isPointerOverBoard() {
    final pointer = _dragPointer, board = _box(_boardKey), index = _dragIndex;
    if (pointer == null || board == null || index == null) return false;
    final topLeft = board.globalToLocal(
      _dragTopLeft(game.tray[index]!, pointer),
    );
    return (Offset.zero & board.size).inflate(_boardCell).contains(topLeft);
  }

  // ------------------------------------------------------ game over / revive

  Future<void> _handleGameOver() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    if (game.canRevive && app.offers.ads.isReady) {
      final decision = app.offers.decide(OfferPlacement.revive, game);
      if (decision.variant == OfferVariant.calm) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
      }
      final accepted = await showReviveOffer(
        context,
        variant: decision.variant,
        score: game.score,
        bestScore: app.profile.bestScore,
      );
      await app.offers.recordAnswer(decision, accepted: accepted);
      if (accepted) {
        final earned = await app.offers.watchAd();
        if (!mounted) return;
        if (earned) {
          _revive();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The ad didn\'t finish, so no revive this time.'),
          ),
        );
      }
    }
    await _finishGame();
  }

  void _revive() {
    final before = game.board.cells;
    final cleared = game.revive();
    _clearing = {
      for (final c in cleared) c: before[c.row * game.boardSize + c.col] ?? 0,
    };
    _clearOrigin = Cell(game.boardSize ~/ 2, game.boardSize ~/ 2);
    _clearAnim.forward(from: 0);
    app.sound.play(Sfx.revive);
    app.mediumHaptic();
    app.profile.saveGame(game.toJson());
    setState(() => _busy = false);
  }

  Future<void> _finishGame() async {
    app.sound.play(Sfx.gameover);
    final p = app.profile;
    await p.clearSavedGame();
    _newBest = await p.submitScore(game.score);
    _coinsEarned = Progression.coinsForGame(game.score, game.linesClearedTotal);
    await p.addCoins(_coinsEarned);
    _levelsReached = await p.addXp(game.score);
    final missions = p.missions();
    final done = missions.onGameEnd(game.score);
    await p.commitMissions(done);
    _announceMissions(done);
    await p.onGameFinished();
    _doubleDecision = app.offers.decide(OfferPlacement.doubleCoins, game);
    _doubleAnswered = false;
    _coinsDoubled = false;
    if (_levelsReached.isNotEmpty) {
      Future<void>.delayed(
        const Duration(milliseconds: 900),
        () => app.sound.play(Sfx.levelup),
      );
    }
    if (!mounted) return;
    setState(() {
      _showGameOver = true;
      _busy = false;
    });
  }

  Future<void> _doubleCoins() async {
    final decision = _doubleDecision;
    if (decision == null || _doubleAnswered) return;
    _doubleAnswered = true;
    await app.offers.recordAnswer(decision, accepted: true);
    final earned = await app.offers.watchAd();
    if (earned) {
      await app.profile.addCoins(_coinsEarned);
      app.sound.play(Sfx.coin);
    }
    if (mounted) setState(() => _coinsDoubled = earned);
  }

  /// Leaving the game-over screen is a natural break, the only place an
  /// interstitial may appear (and only if the policy allows it).
  Future<void> _leaveGameOver() async {
    final decision = _doubleDecision;
    if (decision != null && !_doubleAnswered && app.offers.ads.isReady) {
      _doubleAnswered = true;
      await app.offers.recordAnswer(decision, accepted: false);
    }
    await app.offers.maybeShowInterstitial(justSetNewBest: _newBest);
  }

  Future<void> _playAgain() async {
    await _leaveGameOver();
    if (!mounted) return;
    app.profile.onGameStarted();
    setState(() {
      _showGameOver = false;
      _newBest = false;
      _praise = null;
    });
    game.newGame();
  }

  Future<void> _goHome() async {
    if (_showGameOver) await _leaveGameOver();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pause() async {
    if (_busy || _showGameOver) return;
    final choice = await showPauseMenu(context);
    if (!mounted) return;
    switch (choice) {
      case PauseChoice.resume:
        break;
      case PauseChoice.restart:
        await app.profile.clearSavedGame();
        app.profile.onGameStarted();
        setState(() => _praise = null);
        game.newGame();
      case PauseChoice.home:
        if (!game.isGameOver) await app.profile.saveGame(game.toJson());
        if (mounted) Navigator.of(context).pop();
    }
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showGameOver ? _goHome() : _pause();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: theme.background,
          child: SafeArea(
            child: Stack(
              key: _stackKey,
              children: [
                LayoutBuilder(builder: (context, c) => _layout(c)),
                Positioned.fill(child: EffectsLayer(controller: _effects)),
                if (_dragIndex != null) _draggedPiece(),
                if (_showGameOver) Positioned.fill(child: _gameOverPanel()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _layout(BoxConstraints c) {
    final s = uiScale(context);
    final w = c.maxWidth, h = c.maxHeight;
    final topBar = 72.0 * s;
    final wide = w > h * 0.95;

    final shake = _shakeAnim.isAnimating
        ? Offset(
            sin(_shakeAnim.value * pi * 10) *
                _shakeAmp *
                (1 - _shakeAnim.value),
            0,
          )
        : Offset.zero;

    if (!wide) {
      // Portrait phone / tablet. Budget the height so everything always fits,
      // from 320x568 phones up to tablets.
      final hint = _hintVisible ? 30.0 * s : 0.0;
      final minTray = 92.0 * s;
      final boardSide = max(
        160.0,
        min(min(w - 24 * s, h - topBar - minTray - hint - 12 * s), 620.0),
      );
      final cell = BoardPainter.cellSize(boardSide, game.boardSize);
      final trayHeight = max(
        60.0,
        min(cell * 3.6, h - topBar - boardSide - hint - 12 * s),
      );
      return Column(
        children: [
          SizedBox(height: topBar, child: _topBar()),
          const Spacer(),
          Transform.translate(offset: shake, child: _boardArea(boardSide)),
          const Spacer(),
          SizedBox(
            height: trayHeight,
            width: min(w, boardSide + 48 * s),
            child: _tray(Axis.horizontal, cell),
          ),
          SizedBox(height: hint, child: _tutorialHint()),
          const Spacer(),
        ],
      );
    }

    // Landscape: tablets, foldables and large screens (Android 16 ignores
    // portrait-only locks on big screens, so this must work too).
    final boardSide = min(min(h - 24 * s, w * 0.6), 620.0);
    final cell = BoardPainter.cellSize(boardSide, game.boardSize);
    return Row(
      children: [
        const Spacer(),
        Transform.translate(offset: shake, child: _boardArea(boardSide)),
        SizedBox(width: 24 * s),
        SizedBox(
          width: min(w - boardSide - 48 * s, cell * 4.5),
          child: Column(
            children: [
              SizedBox(height: topBar, child: _topBar()),
              Expanded(child: _tray(Axis.vertical, cell)),
              if (_hintVisible)
                SizedBox(height: 30 * s, child: _tutorialHint()),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _topBar() {
    final theme = app.theme;
    final s = uiScale(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.pause_rounded,
            tooltip: 'Pause',
            onPressed: _pause,
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: game.score.toDouble()),
                    duration: const Duration(milliseconds: 450),
                    builder: (context, v, _) => Text(
                      '${v.round()}',
                      style: TextStyle(
                        fontSize: 38 * s,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: theme.text,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 15 * s,
                        color: const Color(0xFFF2C14E),
                      ),
                      SizedBox(width: 4 * s),
                      Text(
                        '${max(app.profile.bestScore, game.score)}',
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: theme.textSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 48 * s,
            child: game.combo >= 2
                ? Text(
                    '×${game.combo}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w900,
                      color: theme.accent,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _boardArea(double side) {
    final hoverPiece = _dragIndex == null ? null : game.tray[_dragIndex!];
    final ghost = <Cell>{
      if (hoverPiece != null && _hoverRow != null)
        for (final c in hoverPiece.cells)
          Cell(_hoverRow! + c.row, _hoverCol! + c.col),
    };
    final praise = _praise;
    final s = uiScale(context);
    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              key: _boardKey,
              size: Size.square(side),
              painter: BoardPainter(
                board: game.board,
                theme: app.theme,
                dpr: MediaQuery.devicePixelRatioOf(context),
                visuals: BoardVisuals(
                  ghost: ghost,
                  ghostColor: ghost.isEmpty ? null : hoverPiece!.colorIndex,
                  previewClear: ghost.isEmpty ? const {} : _previewClear,
                  clearing: _clearing,
                  clearOrigin: _clearOrigin,
                  clearProgress: _clearAnim.isAnimating ? _clearAnim.value : 1,
                  settling: _settling,
                  settleProgress: _settleAnim.isAnimating
                      ? _settleAnim.value
                      : 1,
                ),
              ),
            ),
          ),
          if (praise?.praise != null)
            PraiseBanner(
              key: ValueKey(praise!.id),
              text: praise.praise!,
              sub: praise.combo >= 2 ? 'Combo ×${praise.combo}' : null,
              color: app.theme.accent,
              fontSize: (praise.perfect ? 40 : 34) * s,
            ),
        ],
      ),
    );
  }

  Widget _tray(Axis axis, double boardCell) {
    return LayoutBuilder(
      builder: (context, c) {
        final slots = GameState.traySize;
        final slotW = axis == Axis.horizontal ? c.maxWidth / slots : c.maxWidth;
        final slotH = axis == Axis.horizontal
            ? c.maxHeight
            : c.maxHeight / slots;
        final trayCell = min(boardCell * 0.62, min(slotW, slotH) / 5.4);
        final children = [
          for (var i = 0; i < slots; i++)
            SizedBox(
              width: slotW,
              height: slotH,
              child: _traySlot(i, trayCell),
            ),
        ];
        return axis == Axis.horizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }

  Widget _traySlot(int index, double trayCell) {
    final piece = game.tray[index];
    final dragging = _dragIndex == index;
    final fits = piece != null && game.board.fitsAnywhere(piece);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _dragStart(index, e.position),
      onPointerMove: (e) => _dragMove(index, e.position),
      onPointerUp: (_) => _dragEnd(index),
      onPointerCancel: (_) => _dragEnd(index),
      child: Center(
        child: piece == null || dragging
            ? const SizedBox.shrink()
            : AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: fits ? 1 : 0.35,
                child: PieceArt(
                  cells: [for (final c in piece.cells) (c.row, c.col)],
                  color: app.theme.blocks[piece.colorIndex],
                  cellSize: trayCell,
                ),
              ),
      ),
    );
  }

  Widget _draggedPiece() {
    final piece = game.tray[_dragIndex!];
    final pointer = _dragPointer;
    final stack = _box(_stackKey);
    if (piece == null || pointer == null || stack == null) {
      return const SizedBox.shrink();
    }
    final topLeft = stack.globalToLocal(_dragTopLeft(piece, pointer));
    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: IgnorePointer(
        child: Opacity(
          opacity: _hoverRow == null ? 0.85 : 1,
          child: PieceArt(
            cells: [for (final c in piece.cells) (c.row, c.col)],
            color: app.theme.blocks[piece.colorIndex],
            cellSize: _boardCell,
          ),
        ),
      ),
    );
  }

  bool get _hintVisible =>
      !app.profile.tutorialDone && game.movesMade == 0 && !_showGameOver;

  Widget _tutorialHint() {
    if (!_hintVisible) return const SizedBox.shrink();
    final s = uiScale(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, v, child) => Opacity(opacity: v, child: child),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Drag a block onto the board',
          style: TextStyle(
            fontSize: 16 * s,
            color: app.theme.textSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _gameOverPanel() {
    final theme = app.theme;
    final s = uiScale(context);
    final decision = _doubleDecision;
    final doubleLabel = switch (decision?.variant) {
      OfferVariant.progress => 'Get +$_coinsEarned more coins',
      OfferVariant.calm => 'Double coins with a short ad',
      _ => '×2 coins',
    };
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20 * s),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400 * s),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Panel(
                padding: EdgeInsets.fromLTRB(22 * s, 26 * s, 22 * s, 20 * s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _newBest ? 'New best!' : 'Well played',
                      style: TextStyle(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: theme.text,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      '${game.score}',
                      style: TextStyle(
                        fontSize: 54 * s,
                        fontWeight: FontWeight.w900,
                        color: theme.accent,
                      ),
                    ),
                    Text(
                      'Best ${app.profile.bestScore}  ·  ${game.linesClearedTotal} lines'
                      '${game.maxCombo >= 2 ? '  ·  ×${game.maxCombo} combo' : ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14 * s, color: theme.textSoft),
                    ),
                    SizedBox(height: 14 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: const Color(0xFFF2C14E),
                          size: 20 * s,
                        ),
                        SizedBox(width: 6 * s),
                        Text(
                          '+${_coinsDoubled ? _coinsEarned * 2 : _coinsEarned}',
                          style: TextStyle(
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w800,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                    if (_levelsReached.isNotEmpty) ...[
                      SizedBox(height: 6 * s),
                      Text(
                        'Level up! Level ${_levelsReached.last}  '
                        '(+${_levelsReached.map(Progression.levelUpReward).reduce((a, b) => a + b)} coins)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w700,
                          color: theme.accent,
                        ),
                      ),
                    ],
                    SizedBox(height: 18 * s),
                    if (!_coinsDoubled &&
                        !_doubleAnswered &&
                        app.offers.ads.isReady) ...[
                      SoftButton(
                        label: doubleLabel,
                        icon: Icons.play_circle_outline_rounded,
                        color: const Color(0xFFE9B53F),
                        onPressed: _doubleCoins,
                      ),
                      SizedBox(height: 10 * s),
                    ],
                    SoftButton(
                      label: 'Play again',
                      icon: Icons.replay_rounded,
                      large: true,
                      onPressed: _playAgain,
                    ),
                    SizedBox(height: 10 * s),
                    SoftButton(
                      label: 'Home',
                      icon: Icons.home_rounded,
                      outlined: true,
                      onPressed: _goHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
