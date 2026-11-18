import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

class _Particle {
  _Particle(this.pos, this.vel, this.color, this.size, this.life, this.spin);
  Offset pos;
  Offset vel;
  final Color color;
  final double size;
  final double life;
  final double spin;
  double age = 0;
}

class _FloatingText {
  _FloatingText(this.text, this.pos, this.color, this.fontSize);
  final String text;
  final Offset pos;
  final Color color;
  final double fontSize;
  double age = 0;
  static const life = 1.0;
}

/// Lightweight particle bursts and floating "+score" texts drawn above the
/// board. Particle counts are capped so low-end phones stay smooth.
class EffectsController extends ChangeNotifier {
  final _particles = <_Particle>[];
  final _texts = <_FloatingText>[];
  final _random = Random();
  static const maxParticles = 160;

  bool get isIdle => _particles.isEmpty && _texts.isEmpty;

  /// Burst of small blocks flying out from [center] in [color].
  void burst(Offset center, Color color, {int count = 4, double speed = 220}) {
    for (var i = 0; i < count && _particles.length < maxParticles; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final v = speed * (0.4 + _random.nextDouble() * 0.8);
      _particles.add(
        _Particle(
          center,
          Offset(cos(angle) * v, sin(angle) * v - speed * 0.6),
          color,
          5 + _random.nextDouble() * 6,
          0.55 + _random.nextDouble() * 0.4,
          (_random.nextDouble() - 0.5) * 10,
        ),
      );
    }
    notifyListeners();
  }

  void floatText(String text, Offset pos, Color color, double fontSize) {
    _texts.add(_FloatingText(text, pos, color, fontSize));
    notifyListeners();
  }

  void tick(double dt) {
    if (isIdle) return;
    for (final p in _particles) {
      p.age += dt;
      p.vel += Offset(0, 900 * dt);
      p.pos += p.vel * dt;
    }
    _particles.removeWhere((p) => p.age >= p.life);
    for (final t in _texts) {
      t.age += dt;
    }
    _texts.removeWhere((t) => t.age >= _FloatingText.life);
    notifyListeners();
  }
}

/// Paints an [EffectsController]; runs its own ticker only while busy.
class EffectsLayer extends StatefulWidget {
  const EffectsLayer({super.key, required this.controller});

  final EffectsController controller;

  @override
  State<EffectsLayer> createState() => _EffectsLayerState();
}

class _EffectsLayerState extends State<EffectsLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_wake);
  }

  void _wake() {
    if (!_ticker.isActive && !widget.controller.isIdle) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    widget.controller.tick(dt.clamp(0, 0.05));
    if (widget.controller.isIdle) _ticker.stop();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_wake);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _EffectsPainter(widget.controller),
        size: Size.infinite,
      ),
    ),
  );
}

class _EffectsPainter extends CustomPainter {
  _EffectsPainter(this.c) : super(repaint: c);
  final EffectsController c;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in c._particles) {
      final t = p.age / p.life;
      paint.color = p.color.withValues(alpha: (1 - t).clamp(0, 1));
      final s = p.size * (1 - t * 0.6);
      canvas
        ..save()
        ..translate(p.pos.dx, p.pos.dy)
        ..rotate(p.age * p.spin)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: s, height: s),
            Radius.circular(s * 0.3),
          ),
          paint,
        )
        ..restore();
    }
    for (final t in c._texts) {
      final k = t.age / _FloatingText.life;
      final rise = Curves.easeOut.transform(k) * 46;
      final alpha = k < 0.7 ? 1.0 : (1 - (k - 0.7) / 0.3);
      final pop = k < 0.15 ? 0.7 + k / 0.15 * 0.3 : 1.0;
      final tp = TextPainter(
        text: TextSpan(
          text: t.text,
          style: TextStyle(
            fontSize: t.fontSize * pop,
            fontWeight: FontWeight.w800,
            color: t.color.withValues(alpha: alpha.clamp(0, 1)),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.18 * alpha.clamp(0, 1)),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, t.pos - Offset(tp.width / 2, tp.height / 2 + rise));
    }
  }

  @override
  bool shouldRepaint(_EffectsPainter old) => true;
}

/// Big praise word ("Great!", "Perfect Clear!") that pops in and fades out.
/// Give it a new [Key] for each event to replay the animation.
class PraiseBanner extends StatefulWidget {
  const PraiseBanner({
    super.key,
    required this.text,
    this.sub,
    required this.color,
    required this.fontSize,
  });

  final String text;
  final String? sub;
  final Color color;
  final double fontSize;

  @override
  State<PraiseBanner> createState() => _PraiseBannerState();
}

class _PraiseBannerState extends State<PraiseBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final scale =
              Curves.elasticOut.transform((t / 0.45).clamp(0, 1)) * 0.6 + 0.4;
          final opacity = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
          return Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _outlined(widget.text, widget.fontSize),
                  if (widget.sub != null)
                    _outlined(widget.sub!, widget.fontSize * 0.55),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _outlined(String text, double size) => Stack(
    children: [
      Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size * 0.14
            ..color = Colors.white,
        ),
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          color: widget.color,
        ),
      ),
    ],
  );
}
