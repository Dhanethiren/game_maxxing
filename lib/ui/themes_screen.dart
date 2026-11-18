import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../audio/sound_service.dart';
import 'block_painter.dart';
import 'game_theme.dart';
import 'widgets.dart';

/// Theme shop: spend coins on new colour themes, or watch an ad for coins.
class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  static const freeCoinsAmount = 50;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final s = uiScale(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 900 ? 4 : (width > 560 ? 3 : 2);
    final freeLeft = app.profile.freeCoinAdsLeft;

    return Scaffold(
      body: DecoratedBox(
        decoration: theme.background,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900 * s),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          RoundIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 12 * s),
                          Text(
                            'Themes',
                            style: TextStyle(
                              fontSize: 26 * s,
                              fontWeight: FontWeight.w800,
                              color: theme.text,
                            ),
                          ),
                          const Spacer(),
                          const CoinChip(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(12 * s),
                    sliver: SliverToBoxAdapter(
                      child: Panel(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                freeLeft > 0
                                    ? 'Watch a short ad for $freeCoinsAmount free coins '
                                          '($freeLeft left today)'
                                    : 'Free coins are back tomorrow',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: theme.text,
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            SoftButton(
                              label: '+$freeCoinsAmount',
                              icon: Icons.play_circle_outline_rounded,
                              color: const Color(0xFFE9B53F),
                              onPressed: freeLeft > 0 && app.offers.ads.isReady
                                  ? () async {
                                      final earned = await app.offers.watchAd();
                                      if (earned) {
                                        await app.profile.useFreeCoinAd();
                                        await app.profile.addCoins(
                                          freeCoinsAmount,
                                        );
                                        app.sound.play(Sfx.coin);
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s),
                    sliver: SliverGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12 * s,
                      crossAxisSpacing: 12 * s,
                      childAspectRatio: 0.72,
                      children: [for (final t in GameTheme.all) _ThemeCard(t)],
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24 * s)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard(this.t);
  final GameTheme t;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.profile;
    final s = uiScale(context);
    final owned = p.ownedThemes.contains(t.id);
    final selected = p.selectedTheme == t.id;
    final affordable = p.coins >= t.price;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: selected ? app.theme.accent : Colors.transparent,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17 * s),
        child: DecoratedBox(
          decoration: t.background,
          child: Padding(
            padding: EdgeInsets.all(10 * s),
            child: Column(
              children: [
                Expanded(child: _Preview(t)),
                SizedBox(height: 8 * s),
                Text(
                  t.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                SizedBox(height: 8 * s),
                SizedBox(
                  width: double.infinity,
                  child: selected
                      ? SoftButton(
                          label: 'In use',
                          color: t.accent,
                          onPressed: null,
                        )
                      : owned
                      ? SoftButton(
                          label: 'Use',
                          color: t.accent,
                          onPressed: () => p.selectTheme(t.id),
                        )
                      : SoftButton(
                          label: '${t.price}',
                          icon: Icons.circle,
                          color: t.accent,
                          onPressed: affordable
                              ? () async {
                                  if (await p.buyTheme(t.id, t.price)) {
                                    app.sound.play(Sfx.levelup);
                                    await p.selectTheme(t.id);
                                  }
                                }
                              : null,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview(this.t);
  final GameTheme t;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(painter: _PreviewPainter(t, dpr)),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.t, this.dpr);
  final GameTheme t;
  final double dpr;

  static const _pattern = [
    [0, -1, 2, 2],
    [0, 1, 1, -1],
    [-1, 4, 3, 3],
    [5, 4, -1, 6],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(cell * 0.3)),
      Paint()..color = t.board,
    );
    final gap = cell * 0.08;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final rect = Rect.fromLTWH(
          c * cell + gap / 2,
          r * cell + gap / 2,
          cell - gap,
          cell - gap,
        );
        final k = _pattern[r][c];
        if (k < 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.2)),
            Paint()..color = t.emptyCell,
          );
        } else {
          BlockArt.draw(canvas, rect, t.blocks[k], dpr);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.t != t;
}
