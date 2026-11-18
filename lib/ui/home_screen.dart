import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import 'block_painter.dart';
import 'dialogs.dart';
import 'game_screen.dart';
import 'journey_screen.dart';
import 'spin_wheel.dart';
import 'themes_screen.dart';
import 'widgets.dart';

/// Main menu, laid out like the genre leaders: brand on top, the two mode
/// buttons as the only big actions (in the thumb zone), and everything else as
/// small icons along the bottom. It always fits on one screen, with sizes
/// taken from the screen's own proportions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dailyPromptShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Returning players get the daily reward pop-up once per session. Brand
    // new players don't: their first session should be pure play.
    if (_dailyPromptShown) return;
    _dailyPromptShown = true;
    final app = AppScope.read(context);
    if (app.profile.gamesPlayed > 0 &&
        app.profile.claimableDailyDay() != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showDailyReward(context);
      });
    }
  }

  Future<void> _play({required bool resume}) async {
    final app = AppScope.read(context);
    if (!resume) await app.profile.clearSavedGame();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => GameScreen(resume: resume),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              // In very short windows (e.g. split screen) lay out as if the
              // screen were 520 tall and let it scroll, instead of squashing.
              const minHeight = 520.0;
              if (box.maxHeight < minHeight) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: minHeight,
                    child: _menu(context, box.maxWidth, minHeight),
                  ),
                );
              }
              return _menu(context, box.maxWidth, box.maxHeight);
            },
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, double maxWidth, double h) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final p = app.profile;
    final s = uiScale(context);
    final w = min(maxWidth, 440 * s);
    // Proportions from the screen itself, clamped for tiny phones
    // and tablets.
    final logo = (h * 0.16).clamp(64.0, 150.0);
    final title = (w * 0.11).clamp(30.0, 50.0);
    final buttonWidth = min(w - 48, 340 * s);

    return Center(
      child: SizedBox(
        width: w,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10 * s, 16, 0),
              child: Row(
                children: [
                  const CoinChip(),
                  const Spacer(),
                  RoundIconButton(
                    icon: Icons.settings_rounded,
                    tooltip: 'Settings',
                    onPressed: () => showSettings(context),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            _Logo(size: logo),
            SizedBox(height: h * 0.025),
            Text(
              'Calm Grid',
              style: TextStyle(
                fontSize: title,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: theme.text,
                shadows: titleShadows(theme),
              ),
            ),
            SizedBox(height: h * 0.014),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFFF2C14E),
                  size: 20 * s,
                ),
                SizedBox(width: 6 * s),
                Text(
                  '${p.bestScore}',
                  style: TextStyle(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w700,
                    color: theme.textSoft,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 4),
            SizedBox(
              width: buttonWidth,
              child: SoftButton(
                label: p.hasSavedGame ? 'Continue Classic' : 'Classic',
                icon: Icons.play_arrow_rounded,
                large: true,
                onPressed: () => _play(resume: p.hasSavedGame),
              ),
            ),
            SizedBox(height: h * 0.02),
            SizedBox(
              width: buttonWidth,
              child: SoftButton(
                label: 'Journey · Level ${p.journeyLevel}',
                icon: Icons.map_rounded,
                large: true,
                outlined: true,
                onPressed: () => _open(const JourneyScreen()),
              ),
            ),
            SizedBox(
              height: 40 * s,
              child: p.hasSavedGame
                  ? TextButton(
                      onPressed: () => _play(resume: false),
                      child: Text(
                        'New Classic game',
                        style: TextStyle(
                          color: theme.textSoft,
                          fontSize: 14 * s,
                        ),
                      ),
                    )
                  : null,
            ),
            const Spacer(flex: 2),
            Row(
              children: [
                Expanded(
                  child: _FeatureIcon(
                    icon: Icons.redeem_rounded,
                    label: 'Daily',
                    badge: p.claimableDailyDay() != null,
                    onTap: () => showDailyReward(context),
                  ),
                ),
                Expanded(
                  child: _FeatureIcon(
                    icon: Icons.donut_large_rounded,
                    label: 'Spin',
                    badge: p.freeSpinAvailable,
                    onTap: () => showDailySpin(context),
                  ),
                ),
                Expanded(
                  child: _FeatureIcon(
                    icon: Icons.flag_rounded,
                    label: 'Goals',
                    badge: false,
                    onTap: () => showGoals(context),
                  ),
                ),
                Expanded(
                  child: _FeatureIcon(
                    icon: Icons.palette_rounded,
                    label: 'Themes',
                    badge: false,
                    onTap: () => _open(const ThemesScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.03),
          ],
        ),
      ),
    );
  }
}

/// Small raised round icon with a label and an optional "ready" dot.
class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({
    required this.icon,
    required this.label,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final s = uiScale(context);
    final size = 54 * s;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          app.tap();
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(
                          alpha: theme.dark ? 0.18 : 0.98,
                        ),
                        theme.card.withValues(alpha: theme.dark ? 0.6 : 0.85),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    boxShadow: liftShadow(theme.accent, strength: 0.6),
                  ),
                  child: Icon(icon, color: theme.accent, size: 26 * s),
                ),
                if (badge)
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 13 * s,
                      height: 13 * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE6C4D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6 * s),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.5 * s,
                  fontWeight: FontWeight.w700,
                  color: theme.textSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small cluster of blocks that gently bobs: the game's logo.
class _Logo extends StatefulWidget {
  const _Logo({required this.size});
  final double size;

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    const cells = [
      (0, 0, 0),
      (0, 1, 0),
      (1, 1, 4),
      (1, 2, 2),
      (2, 0, 1),
      (2, 1, 3),
      (2, 2, 6),
    ];
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _LogoPainter(cells, theme.blocks, _c.value, dpr),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.cells, this.colors, this.t, this.dpr);
  final List<(int, int, int)> cells;
  final List<Color> colors;
  final double t;
  final double dpr;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 3;
    for (final (i, (r, c, k)) in cells.indexed) {
      final bob = sin((t + i * 0.13) * 2 * pi) * cell * 0.05;
      final gap = cell * 0.08;
      BlockArt.draw(
        canvas,
        Rect.fromLTWH(
          c * cell + gap / 2,
          r * cell + gap / 2 + bob,
          cell - gap,
          cell - gap,
        ),
        colors[k],
        dpr,
        variant: i,
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t || old.colors != colors;
}
