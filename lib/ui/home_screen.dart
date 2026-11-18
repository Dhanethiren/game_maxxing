import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../services/progression.dart';
import 'block_painter.dart';
import 'dialogs.dart';
import 'game_screen.dart';
import 'themes_screen.dart';
import 'widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final p = app.profile;
    final s = uiScale(context);
    final compact = MediaQuery.sizeOf(context).height < 720;
    final daily = p.claimableDailyDay();
    final missions = p.missions();
    final level = p.level;
    final levelStart = Progression.xpForLevel(level);
    final levelEnd = Progression.xpForLevel(level + 1);

    return Scaffold(
      body: DecoratedBox(
        decoration: theme.background,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520 * s),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 18 * s,
                  vertical: 12 * s,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                InfoChip(
                                  icon: Icons.star_rounded,
                                  text: 'Lv $level',
                                ),
                                SizedBox(width: 8 * s),
                                const CoinChip(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        RoundIconButton(
                          icon: Icons.settings_rounded,
                          tooltip: 'Settings',
                          onPressed: () => showSettings(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            (p.xp - levelStart) / max(1, levelEnd - levelStart),
                        minHeight: 5 * s,
                        backgroundColor: theme.emptyCell,
                        color: theme.accent,
                      ),
                    ),
                    SizedBox(height: (compact ? 12 : 22) * s),
                    if (compact)
                      // Short screens: logo beside the title so Play stays visible.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Logo(size: 56 * s),
                          SizedBox(width: 12 * s),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Calm Grid',
                                style: TextStyle(
                                  fontSize: 32 * s,
                                  fontWeight: FontWeight.w900,
                                  color: theme.text,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _Logo(size: 120 * s),
                      SizedBox(height: 12 * s),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Calm Grid',
                          style: TextStyle(
                            fontSize: 40 * s,
                            fontWeight: FontWeight.w900,
                            color: theme.text,
                          ),
                        ),
                      ),
                      Text(
                        'Relax. Place. Clear.',
                        style: TextStyle(
                          fontSize: 16 * s,
                          color: theme.textSoft,
                        ),
                      ),
                    ],
                    SizedBox(height: 10 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: const Color(0xFFF2C14E),
                          size: 22 * s,
                        ),
                        SizedBox(width: 6 * s),
                        Text(
                          'Best ${p.bestScore}',
                          style: TextStyle(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (compact ? 14 : 24) * s),
                    if (p.hasSavedGame) ...[
                      SizedBox(
                        width: double.infinity,
                        child: SoftButton(
                          label: 'Continue',
                          icon: Icons.play_arrow_rounded,
                          large: true,
                          onPressed: () => _play(resume: true),
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      SizedBox(
                        width: double.infinity,
                        child: SoftButton(
                          label: 'New game',
                          outlined: true,
                          onPressed: () => _play(resume: false),
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: SoftButton(
                          label: 'Play',
                          icon: Icons.play_arrow_rounded,
                          large: true,
                          onPressed: () => _play(resume: false),
                        ),
                      ),
                    SizedBox(height: 20 * s),
                    Panel(
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final info = Row(
                            children: [
                              Icon(
                                daily != null
                                    ? Icons.redeem_rounded
                                    : Icons.local_fire_department_rounded,
                                color: daily != null
                                    ? theme.accent
                                    : const Color(0xFFF08A5D),
                                size: 32 * s,
                              ),
                              SizedBox(width: 12 * s),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      daily != null
                                          ? 'Daily reward ready'
                                          : '${p.dailyStreak}-day streak',
                                      style: TextStyle(
                                        fontSize: 16 * s,
                                        fontWeight: FontWeight.w700,
                                        color: theme.text,
                                      ),
                                    ),
                                    Text(
                                      daily != null
                                          ? 'Day $daily: ${Progression.dailyRewards[daily - 1]} coins'
                                          : 'Come back tomorrow for more coins',
                                      style: TextStyle(
                                        fontSize: 13 * s,
                                        color: theme.textSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                          if (daily == null) return info;
                          final claim = SoftButton(
                            label: 'Claim',
                            onPressed: () => showDailyReward(context),
                          );
                          // Narrow phones: button under the text, not beside it.
                          if (box.maxWidth < 300) {
                            return Column(
                              children: [
                                info,
                                SizedBox(height: 10 * s),
                                SizedBox(width: double.infinity, child: claim),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: info),
                              SizedBox(width: 8 * s),
                              claim,
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's goals",
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: theme.text,
                            ),
                          ),
                          SizedBox(height: 10 * s),
                          for (final m in missions.missions) _MissionRow(m),
                        ],
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    SizedBox(
                      width: double.infinity,
                      child: SoftButton(
                        label: 'Themes',
                        icon: Icons.palette_rounded,
                        outlined: true,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ThemesScreen(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
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

class _MissionRow extends StatelessWidget {
  const _MissionRow(this.mission);
  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * s),
      child: Row(
        children: [
          Icon(
            mission.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: mission.done ? theme.accent : theme.textSoft,
            size: 22 * s,
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(fontSize: 14 * s, color: theme.text),
                ),
                SizedBox(height: 4 * s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.fraction,
                    minHeight: 5 * s,
                    backgroundColor: theme.emptyCell,
                    color: theme.accent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          Icon(Icons.circle, color: const Color(0xFFF2C14E), size: 14 * s),
          SizedBox(width: 4 * s),
          Text(
            '${mission.reward}',
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
        ],
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
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t || old.colors != colors;
}
