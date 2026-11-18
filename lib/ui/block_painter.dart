import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Draws the soft, glossy "jelly" blocks.
///
/// Each block is drawn once per colour and size into an image and then reused,
/// so the board stays smooth even on low-end phones.
class BlockArt {
  static final _cache = <(int, int), ui.Image>{};

  static Color _shift(Color c, double lightness) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0))
        .toColor();
  }

  /// Paints one block filling [rect].
  static void paint(Canvas canvas, Rect rect, Color color) {
    final w = rect.width;
    final radius = Radius.circular(w * 0.22);
    // Darker base gives a soft bevel along the bottom edge.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = _shift(color, -0.12),
    );
    // Main face, lit from the top.
    final face = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom - w * 0.09,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(face, radius),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_shift(color, 0.08), color],
        ).createShader(face),
    );
    // Glossy highlight.
    final gloss = Rect.fromLTWH(
      rect.left + w * 0.16,
      rect.top + w * 0.1,
      w * 0.68,
      w * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gloss, Radius.circular(w * 0.1)),
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );
  }

  /// Cached image of a block of [color] at [size] logical pixels times [dpr].
  static ui.Image image(Color color, double size, double dpr) {
    final px = (size * dpr).round().clamp(4, 512);
    return _cache.putIfAbsent((color.toARGB32(), px), () {
      if (_cache.length > 200) _cache.clear();
      final recorder = ui.PictureRecorder();
      paint(
        Canvas(recorder),
        Rect.fromLTWH(0, 0, px.toDouble(), px.toDouble()),
        color,
      );
      return recorder.endRecording().toImageSync(px, px);
    });
  }

  /// Draws a cached block into [rect] with optional [opacity].
  static void draw(
    Canvas canvas,
    Rect rect,
    Color color,
    double dpr, {
    double opacity = 1,
  }) {
    final img = image(color, rect.width, dpr);
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
