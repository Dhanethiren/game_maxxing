import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../game/level.dart';
import 'board_painter.dart';
import 'game_screen.dart';
import 'widgets.dart';

/// The Journey map: a winding path of levels, like the level maps in the
/// biggest casual games. Completed levels show their stars; the next level
/// pulses; later ones are locked.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  final _scroll = ScrollController();
  bool _scrolled = false;

  static const _rowHeight = 96.0;

  @override
  void dispose() {
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _open(int number) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => GameScreen(level: LevelSpec.generate(number)),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final p = app.profile;
    final s = uiScale(context);
    final current = p.journeyLevel;
    final stars = p.journeyStars;
    final count = current + 12;
    final row = _rowHeight * s;

    if (!_scrolled) {
      _scrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        final target =
            (current - 1) * row - _scroll.position.viewportDimension / 2 + row;
        _scroll.jumpTo(target.clamp(0, _scroll.position.maxScrollExtent));
      });
    }

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520 * s),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12 * s),
                    child: Row(
                      children: [
                        RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: Text(
                            'Journey',
                            style: TextStyle(
                              fontSize: 26 * s,
                              fontWeight: FontWeight.w800,
                              color: theme.text,
                            ),
                          ),
                        ),
                        const CoinChip(),
                      ],
                    ),
                  ),
                  if (p.journeyWinStreak > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * s),
                      child: Panel(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * s,
                          vertical: 10 * s,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: const Color(0xFFF08A5D),
                              size: 24 * s,
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: Text(
                                'Win streak ${p.journeyWinStreak}: '
                                '+${(25 * min(p.journeyWinStreak, 4))}% coins on your next win',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: theme.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.symmetric(vertical: 16 * s),
                      itemCount: count,
                      itemExtent: row,
                      itemBuilder: (context, i) {
                        final number = i + 1;
                        final x = sin(i * 0.9) * 0.55;
                        return Align(
                          alignment: Alignment(x, 0),
                          child: _LevelNode(
                            number: number,
                            stars: stars[number] ?? 0,
                            state: number < current
                                ? _NodeState.done
                                : (number == current
                                      ? _NodeState.current
                                      : _NodeState.locked),
                            pulse: _pulse,
                            onTap: number <= current
                                ? () => _open(number)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12 * s),
                    child: SizedBox(
                      width: double.infinity,
                      child: SoftButton(
                        label: 'Play level $current',
                        icon: Icons.play_arrow_rounded,
                        large: true,
                        onPressed: () => _open(current),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _NodeState { done, current, locked }

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.number,
    required this.stars,
    required this.state,
    required this.pulse,
    required this.onTap,
  });

  final int number;
  final int stars;
  final _NodeState state;
  final Animation<double> pulse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final s = uiScale(context);
    final size = 58.0 * s;
    final isGem = LevelSpec.generate(number).goal == LevelGoal.gems;
    final color = switch (state) {
      _NodeState.done => theme.accent,
      _NodeState.current => theme.blocks[number % theme.blocks.length],
      _NodeState.locked => theme.emptyCell,
    };

    final locked = state == _NodeState.locked;
    Widget node = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Raised "coin": lit from the top with a solid darker edge below,
        // matching the 3D buttons.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: locked
              ? [Colors.white.withValues(alpha: 0.9), theme.emptyCell]
              : [shiftColor(color, 0.1), color],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3 * s),
        boxShadow: [
          BoxShadow(
            color: locked
                ? theme.textSoft.withValues(alpha: 0.25)
                : shiftColor(color, -0.18),
            offset: Offset(0, 4 * s),
          ),
          BoxShadow(
            color: (locked ? theme.textSoft : color).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 7 * s),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: state == _NodeState.locked
          ? Icon(Icons.lock_rounded, color: theme.textSoft, size: 22 * s)
          : Text(
              '$number',
              style: TextStyle(
                fontSize: 22 * s,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
    );
    if (state == _NodeState.current) {
      node = ScaleTransition(
        scale: Tween(
          begin: 0.94,
          end: 1.08,
        ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut)),
        child: node,
      );
    }

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              app.tap();
              onTap!();
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              node,
              if (isGem && state != _NodeState.locked)
                Positioned(
                  right: -4 * s,
                  top: -4 * s,
                  child: CustomPaint(
                    size: Size.square(22 * s),
                    painter: _GemBadge(),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2 * s),
          if (state == _NodeState.done)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    Icons.star_rounded,
                    size: 16 * s,
                    color: i < stars
                        ? const Color(0xFFF2C14E)
                        : theme.emptyCell,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GemBadge extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => paintGem(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(_GemBadge old) => false;
}
