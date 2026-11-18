import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../audio/sound_service.dart';
import '../ml/offer_optimizer.dart';
import '../services/progression.dart';
import 'widgets.dart';

/// Daily prize wheel: one free spin a day, plus one extra spin for watching
/// an ad. Prizes and odds are in [Progression.spinPrizes] / [spinWeights].
Future<void> showDailySpin(BuildContext context) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Close',
  barrierColor: Colors.black.withValues(alpha: 0.35),
  transitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (_, _, _) => const _SpinDialog(),
  transitionBuilder: (context, anim, _, child) => FadeTransition(
    opacity: anim,
    child: ScaleTransition(
      scale: Tween(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
      child: child,
    ),
  ),
);

/// Wheel angle (radians, clockwise) that puts the middle of [segment] under
/// the pointer at the top, after [turns] full rotations.
double spinTargetAngle(int segment, int segments, {int turns = 5}) {
  final seg = 2 * pi / segments;
  return turns * 2 * pi - (segment + 0.5) * seg;
}

class _SpinDialog extends StatefulWidget {
  const _SpinDialog();

  @override
  State<_SpinDialog> createState() => _SpinDialogState();
}

class _SpinDialogState extends State<_SpinDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  );
  final _random = Random();
  double _from = 0, _to = 0;
  int? _prize;
  bool _spinning = false;
  int _lastTick = 0;

  static const _segments = 8;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _angle =>
      _from + (_to - _from) * Curves.easeOutCubic.transform(_c.value);

  void _onTick() {
    // A soft tick each time a segment passes the pointer.
    final tick = (_angle / (2 * pi / _segments)).floor();
    if (tick != _lastTick) {
      _lastTick = tick;
      AppScope.read(context).sound.play(Sfx.pickup);
    }
    setState(() {});
  }

  Future<void> _spin({required bool extra}) async {
    final app = AppScope.read(context);
    if (_spinning) return;
    if (extra) {
      final decision = app.offers.decide(OfferPlacement.extraSpin);
      await app.offers.recordAnswer(decision, accepted: true);
      final earned = await app.offers.watchAd();
      if (!earned || !mounted) return;
    }
    final segment = Progression.spinSegment(_random);
    await app.profile.useSpin(extra: extra);
    setState(() {
      _spinning = true;
      _prize = null;
      _from = _angle % (2 * pi);
      _to = spinTargetAngle(segment, _segments);
    });
    await _c.forward(from: 0);
    if (!mounted) return;
    final coins = Progression.spinPrizes[segment];
    await app.profile.addCoins(coins);
    app.sound.play(coins >= 100 ? Sfx.levelup : Sfx.coin);
    app.mediumHaptic();
    setState(() {
      _spinning = false;
      _prize = coins;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final p = app.profile;
    final s = uiScale(context);
    final screen = MediaQuery.sizeOf(context);
    // Fit the wheel to both width and height so the dialog fits short phones.
    final wheel = min(min(300 * s, screen.width - 96), screen.height * 0.4);

    final Widget action;
    if (_spinning) {
      action = const SoftButton(label: 'Spinning…', onPressed: null);
    } else if (p.freeSpinAvailable) {
      action = SoftButton(
        label: 'Spin',
        icon: Icons.refresh_rounded,
        large: true,
        onPressed: () => _spin(extra: false),
      );
    } else if (p.extraSpinAvailable && app.offers.ads.isReady) {
      // AdMob policy: random rewards must say so before the ad plays.
      action = Column(
        children: [
          Text(
            'Watch a short ad for one more spin.\n'
            'Prize is random: 10 to 200 coins.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13 * s, color: theme.textSoft),
          ),
          SizedBox(height: 8 * s),
          SoftButton(
            label: 'Watch ad & spin',
            icon: Icons.play_circle_outline_rounded,
            color: const Color(0xFFE9B53F),
            onPressed: () => _spin(extra: true),
          ),
        ],
      );
    } else {
      action = SoftButton(
        label: 'Come back tomorrow',
        outlined: true,
        onPressed: () => Navigator.pop(context),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380 * s),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            color: theme.card,
            borderRadius: BorderRadius.circular(28 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 22 * s, 20 * s, 16 * s),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Daily spin',
                      style: TextStyle(
                        fontSize: 26 * s,
                        fontWeight: FontWeight.w800,
                        color: theme.text,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      _prize != null
                          ? 'You won $_prize coins!'
                          : 'Free daily spin: 10 to 200 coins',
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: _prize != null
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _prize != null ? theme.accent : theme.textSoft,
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    SizedBox(
                      width: wheel,
                      height: wheel + 14 * s,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 14 * s,
                            child: Transform.rotate(
                              angle: _angle,
                              child: CustomPaint(
                                size: Size.square(wheel),
                                painter: _WheelPainter(
                                  theme.blocks,
                                  theme.text,
                                ),
                              ),
                            ),
                          ),
                          CustomPaint(
                            size: Size(26 * s, 30 * s),
                            painter: _PointerPainter(theme.text),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    action,
                    if (!_spinning)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(color: theme.textSoft),
                        ),
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

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.colors, this.textColor);
  final List<Color> colors;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final n = Progression.spinPrizes.length;
    final seg = 2 * pi / n;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    for (var i = 0; i < n; i++) {
      // Segment i is centred at angle (i + 0.5) * seg clockwise from the top.
      final start = -pi / 2 + i * seg;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 6),
        start,
        seg,
        true,
        Paint()..color = colors[i % colors.length],
      );
      final mid = start + seg / 2;
      final label = TextPainter(
        text: TextSpan(
          text: '${Progression.spinPrizes[i]}',
          style: TextStyle(
            fontSize: r * 0.15,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x55000000), blurRadius: 3)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas
        ..save()
        ..translate(c.dx + cos(mid) * r * 0.66, c.dy + sin(mid) * r * 0.66)
        ..rotate(mid + pi / 2);
      label.paint(canvas, Offset(-label.width / 2, -label.height / 2));
      canvas.restore();
    }
    for (var i = 0; i < n; i++) {
      final a = -pi / 2 + i * seg;
      canvas.drawCircle(
        c + Offset(cos(a), sin(a)) * (r - 3),
        3,
        Paint()..color = const Color(0xFFF2C14E),
      );
    }
    canvas.drawCircle(c, r * 0.16, Paint()..color = Colors.white);
    canvas.drawCircle(c, r * 0.1, Paint()..color = const Color(0xFFF2C14E));
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.colors != colors;
}

class _PointerPainter extends CustomPainter {
  _PointerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()..color = Colors.black26,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}
