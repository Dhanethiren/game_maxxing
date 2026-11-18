import 'dart:math';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Draws the blocks as hand-crafted tiles: bevelled edges lit from the top
/// left, a flat inset face, fine grain and hairline scratches, and small
/// per-tile differences (tone, grain, bevel) so no two neighbours look
/// machine-identical.
///
/// Each (colour, size, variant) is drawn once into an image and reused, so
/// the board stays smooth even on low-end phones.
class BlockArt {
  static final _cache = <(int, int, int), ui.Image>{};

  /// Number of hand-made variations per colour.
  static const variants = 4;

  static Color _shift(Color c, double lightness) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0))
        .toColor();
  }

  /// Paints one tile filling [rect]. [variant] seeds its small imperfections.
  static void paint(Canvas canvas, Rect rect, Color base, [int variant = 0]) {
    final r = Random(variant * 7919 + base.toARGB32());
    final w = rect.width;
    // Each variant has a slightly different tone and bevel depth.
    final color = _shift(base, (r.nextDouble() - 0.5) * 0.045);
    final bevel = w * (0.11 + r.nextDouble() * 0.025);
    final outer = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.15));

    canvas
      ..save()
      ..clipRRect(outer);
    canvas.drawRect(rect, Paint()..color = _shift(color, -0.10));

    // Four bevel faces, lit from the top left.
    final l = rect.left, t = rect.top, rr = rect.right, b = rect.bottom;
    void face(List<Offset> pts, double light) => canvas.drawPath(
      Path()..addPolygon(pts, true),
      Paint()..color = _shift(color, light),
    );
    face([
      Offset(l, t),
      Offset(rr, t),
      Offset(rr - bevel, t + bevel),
      Offset(l + bevel, t + bevel),
    ], 0.12);
    face([
      Offset(l, t),
      Offset(l + bevel, t + bevel),
      Offset(l + bevel, b - bevel),
      Offset(l, b),
    ], 0.06);
    face([
      Offset(rr, t),
      Offset(rr, b),
      Offset(rr - bevel, b - bevel),
      Offset(rr - bevel, t + bevel),
    ], -0.07);
    face([
      Offset(l, b),
      Offset(l + bevel, b - bevel),
      Offset(rr - bevel, b - bevel),
      Offset(rr, b),
    ], -0.15);

    // Flat inset face with a very gentle top-to-bottom shade.
    final inner = rect.deflate(bevel);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, Radius.circular(w * 0.06)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_shift(color, 0.035), _shift(color, -0.02)],
        ).createShader(inner),
    );

    // Grain: fine light and dark speckles, like glazed clay.
    final speck = Paint();
    final count = (w * w / 18).clamp(40, 900).toInt();
    for (var i = 0; i < count; i++) {
      final dark = r.nextBool();
      speck.color = (dark ? Colors.black : Colors.white).withValues(
        alpha: 0.025 + r.nextDouble() * (dark ? 0.04 : 0.06),
      );
      final size = w * (0.006 + r.nextDouble() * 0.012);
      canvas.drawRect(
        Rect.fromLTWH(
          l + r.nextDouble() * w,
          t + r.nextDouble() * w,
          size,
          size,
        ),
        speck,
      );
    }
    // A couple of faint hairline scratches on the face.
    final scratch = Paint()
      ..strokeWidth = w * 0.008
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.10);
    for (var i = 0; i < 2; i++) {
      final start =
          inner.topLeft +
          Offset(r.nextDouble() * inner.width, r.nextDouble() * inner.height);
      final len = w * (0.08 + r.nextDouble() * 0.12);
      final angle = -0.6 + r.nextDouble() * 0.5;
      canvas.drawLine(
        start,
        start + Offset(cos(angle), sin(angle)) * len,
        scratch,
      );
    }
    canvas.restore();

    // Thin darker outline so tiles read crisply on light backgrounds.
    canvas.drawRRect(
      outer.deflate(w * 0.006),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = _shift(color, -0.22).withValues(alpha: 0.35),
    );
  }

  /// Cached tile image of [color] at [size] logical pixels times [dpr].
  static ui.Image image(
    Color color,
    double size,
    double dpr, [
    int variant = 0,
  ]) {
    final px = (size * dpr).round().clamp(4, 512);
    final v = variant % variants;
    return _cache.putIfAbsent((color.toARGB32(), px, v), () {
      if (_cache.length > 400) _cache.clear();
      final recorder = ui.PictureRecorder();
      paint(
        Canvas(recorder),
        Rect.fromLTWH(0, 0, px.toDouble(), px.toDouble()),
        color,
        v,
      );
      return recorder.endRecording().toImageSync(px, px);
    });
  }

  /// Draws a cached tile into [rect] with optional [opacity]. Pass a
  /// [variant] (e.g. from the cell position) so neighbours differ slightly.
  static void draw(
    Canvas canvas,
    Rect rect,
    Color color,
    double dpr, {
    double opacity = 1,
    int variant = 0,
  }) {
    final img = image(color, rect.width, dpr, variant);
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Colors.white.withValues(alpha: opacity.clamp(0, 1));
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      rect,
      paint,
    );
  }

  /// Stable variant for a board cell.
  static int variantFor(int row, int col) =>
      (row * 3 + col * 5 + row * col) % variants;
}

/// A block shape drawn with [BlockArt], used in the tray and while dragging.
class PieceArt extends StatelessWidget {
  const PieceArt({
    super.key,
    required this.cells,
    required this.color,
    required this.cellSize,
    this.opacity = 1,
    this.lift = 1,
  });

  final List<(int, int)> cells;
  final Color color;
  final double cellSize;
  final double opacity;

  /// Height of the soft shadow under the piece: 0 = none, 1 = resting in the
  /// tray, 2 = picked up.
  final double lift;

  @override
  Widget build(BuildContext context) {
    var rows = 0, cols = 0;
    for (final (r, c) in cells) {
      if (r + 1 > rows) rows = r + 1;
      if (c + 1 > cols) cols = c + 1;
    }
    return CustomPaint(
      size: Size(cols * cellSize, rows * cellSize),
      painter: _PiecePainter(
        cells,
        color,
        cellSize,
        opacity,
        MediaQuery.devicePixelRatioOf(context),
        lift,
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter(
    this.cells,
    this.color,
    this.cell,
    this.opacity,
    this.dpr,
    this.lift,
  );

  final List<(int, int)> cells;
  final Color color;
  final double cell;
  final double opacity;
  final double dpr;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = cell * 0.06;
    if (lift > 0) {
      final shadow = Paint()
        ..color = Colors.black.withValues(alpha: (0.08 + 0.05 * lift) * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.09 * lift);
      for (final (r, c) in cells) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              c * cell + gap / 2,
              r * cell + gap / 2 + cell * 0.1 * lift,
              cell - gap,
              cell - gap,
            ),
            Radius.circular(cell * 0.22),
          ),
          shadow,
        );
      }
    }
    for (final (r, c) in cells) {
      BlockArt.draw(
        canvas,
        Rect.fromLTWH(
          c * cell + gap / 2,
          r * cell + gap / 2,
          cell - gap,
          cell - gap,
        ),
        color,
        dpr,
        opacity: opacity,
        variant: BlockArt.variantFor(r, c),
      );
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.color != color ||
      old.cell != cell ||
      old.opacity != opacity ||
      old.lift != lift ||
      old.cells != cells;
}
