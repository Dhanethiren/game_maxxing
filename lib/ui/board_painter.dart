import 'dart:math';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../game/board.dart';
import '../game/piece.dart';
import 'block_painter.dart';
import 'game_theme.dart';
import 'widgets.dart';

/// Everything the board needs to draw one frame.
class BoardVisuals {
  const BoardVisuals({
    this.ghost = const {},
    this.ghostColor,
    this.previewClear = const {},
    this.clearing = const {},
    this.clearOrigin,
    this.clearProgress = 1,
    this.settling = const {},
    this.settleProgress = 1,
    this.gems = const {},
  });

  /// Cells the dragged piece would occupy.
  final Set<Cell> ghost;
  final int? ghostColor;

  /// Cells in lines the dragged piece would complete (highlighted in its colour).
  final Set<Cell> previewClear;

  /// Cells being cleared right now -> their colour.
  final Map<Cell, int> clearing;
  final Cell? clearOrigin;

  /// 0..1 progress of the clear animation.
  final double clearProgress;

  /// Cells that just landed, for a small "settle" bounce.
  final Set<Cell> settling;
  final double settleProgress;

  /// Blocks holding a gem (Journey gem levels).
  final Set<Cell> gems;
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.theme,
    required this.visuals,
    required this.dpr,
  });

  final Board board;
  final GameTheme theme;
  final BoardVisuals visuals;
  final double dpr;

  /// Padding inside the board frame, as a fraction of a cell.
  static const double framePadding = 0.18;

  /// Size of one cell for a board drawn at [side] x [side].
  static double cellSize(double side, int n) => side / (n + framePadding * 2);

  @override
  void paint(Canvas canvas, Size size) {
    final n = board.size;
    final cell = cellSize(size.width, n);
    final pad = cell * framePadding;
    final gap = cell * 0.06;

    // Raised frame + recessed well + sunken empty cells, drawn once per
    // theme and size, then reused every frame.
    final bg = _background(size, n, cell, pad, gap);
    canvas.drawImageRect(
      bg,
      Rect.fromLTWH(0, 0, bg.width.toDouble(), bg.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );

    Rect cellRect(int r, int c, [double scale = 1]) {
      final rect = Rect.fromLTWH(
        pad + c * cell + gap / 2,
        pad + r * cell + gap / 2,
        cell - gap,
        cell - gap,
      );
      if (scale == 1) return rect;
      return Rect.fromCenter(
        center: rect.center,
        width: rect.width * scale,
        height: rect.height * scale,
      );
    }

    final ghostColor = visuals.ghostColor == null
        ? null
        : theme.blocks[visuals.ghostColor!];

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final pos = Cell(r, c);
        final value = board.at(r, c);

        if (ghostColor != null && visuals.previewClear.contains(pos)) {
          // Line about to clear: show it glowing in the dragged piece's colour.
          BlockArt.draw(canvas, cellRect(r, c), ghostColor, dpr);
          if (visuals.gems.contains(pos)) paintGem(canvas, cellRect(r, c));
          continue;
        }
        if (value != null) {
          var scale = 1.0;
          if (visuals.settling.contains(pos) && visuals.settleProgress < 1) {
            final t = visuals.settleProgress;
            scale = 1 + 0.14 * sin(pi * t) * (1 - t);
          }
          BlockArt.draw(
            canvas,
            cellRect(r, c, scale),
            theme.blocks[value],
            dpr,
          );
          if (visuals.gems.contains(pos)) {
            paintGem(canvas, cellRect(r, c, scale));
          }
        } else if (ghostColor != null && visuals.ghost.contains(pos)) {
          BlockArt.draw(canvas, cellRect(r, c), ghostColor, dpr, opacity: 0.45);
        }
      }
    }

    _paintClearing(canvas, cellRect, cell);
  }

  /// Cleared blocks flash bright, then shrink away in a wave spreading out
  /// from where the piece landed.
  void _paintClearing(
    Canvas canvas,
    Rect Function(int, int, [double]) cellRect,
    double cell,
  ) {
    if (visuals.clearing.isEmpty || visuals.clearProgress >= 1) return;
    final origin = visuals.clearOrigin ?? const Cell(0, 0);
    final t = visuals.clearProgress;
    for (final MapEntry(key: pos, value: color) in visuals.clearing.entries) {
      final dist = (pos.row - origin.row).abs() + (pos.col - origin.col).abs();
      final delay = min(dist * 0.04, 0.4);
      final local = ((t - delay) / 0.55).clamp(0.0, 1.0);
      if (local >= 1) continue;
      final ease = Curves.easeInBack.transform(local).clamp(0.0, 1.0);
      final rect = cellRect(pos.row, pos.col, 1 - ease);
      if (rect.width <= 0.5) continue;
      BlockArt.draw(
        canvas,
        rect,
        theme.blocks[color],
        dpr,
        opacity: 1 - local * 0.5,
      );
      final flash = (1 - local * 2.5).clamp(0.0, 1.0);
      if (flash > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.22)),
          Paint()..color = Colors.white.withValues(alpha: 0.75 * flash),
        );
      }
    }
  }

  static final _bgCache = <(String, int, int), ui.Image>{};

  ui.Image _background(Size size, int n, double cell, double pad, double gap) {
    final px = (size.width * dpr).round().clamp(16, 4096);
    return _bgCache.putIfAbsent((theme.id, px, n), () {
      if (_bgCache.length > 12) _bgCache.clear();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(px / size.width);
      final outer = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(cell * 0.35),
      );
      final light = theme.dark ? 0.06 : 0.0;
      // Frame: lit from the top.
      canvas.drawRRect(
        outer,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: theme.dark ? 0.14 : 0.85),
              theme.board.withValues(alpha: theme.dark ? 0.2 : 0.55),
            ],
          ).createShader(outer.outerRect),
      );
      // Well: slightly darker, with an inner shadow along the top edge.
      final well = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pad * 0.55,
          pad * 0.55,
          size.width - pad * 1.1,
          size.height - pad * 1.1,
        ),
        Radius.circular(cell * 0.28),
      );
      canvas.drawRRect(
        well,
        Paint()
          ..color = shiftColor(
            theme.backgroundTop,
            theme.dark ? 0.04 : -0.04,
          ).withValues(alpha: theme.dark ? 0.55 : 0.6),
      );
      canvas
        ..save()
        ..clipRRect(well)
        ..drawRRect(
          well.shift(Offset(0, -cell * 0.08)).inflate(cell * 0.06),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.18
            ..color = Colors.black.withValues(alpha: theme.dark ? 0.35 : 0.08)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.08),
        )
        ..restore();
      // Empty cells: sunken (shadow at the top, light at the bottom).
      final radius = Radius.circular(cell * 0.2);
      for (var r = 0; r < n; r++) {
        for (var c = 0; c < n; c++) {
          final rect = Rect.fromLTWH(
            pad + c * cell + gap / 2,
            pad + r * cell + gap / 2,
            cell - gap,
            cell - gap,
          );
          final rr = RRect.fromRectAndRadius(rect, radius);
          canvas.drawRRect(
            rr.shift(Offset(0, cell * 0.035)),
            Paint()
              ..color = Colors.white.withValues(alpha: theme.dark ? 0.06 : 0.7),
          );
          canvas.drawRRect(rr, Paint()..color = theme.emptyCell);
          // Inner shadow along the top edge: the cell looks pressed in.
          canvas.drawRRect(
            rr,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.45],
                colors: [
                  shiftColor(
                    theme.accent,
                    -0.3,
                  ).withValues(alpha: theme.dark ? 0.35 : 0.13 + light),
                  Colors.transparent,
                ],
              ).createShader(rect),
          );
        }
      }
      return recorder.endRecording().toImageSync(px, px);
    });
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}

/// A small faceted gem drawn on top of a block.
void paintGem(Canvas canvas, Rect cell) {
  final c = cell.center;
  final h = cell.height * 0.24, w = cell.width * 0.2;
  final path = Path()
    ..moveTo(c.dx, c.dy - h)
    ..lineTo(c.dx + w, c.dy)
    ..lineTo(c.dx, c.dy + h)
    ..lineTo(c.dx - w, c.dy)
    ..close();
  canvas.drawPath(
    path.shift(Offset(0, cell.height * 0.03)),
    Paint()..color = Colors.black.withValues(alpha: 0.18),
  );
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6FBFF), Color(0xFF5BC8F5), Color(0xFF2E86DE)],
      ).createShader(Rect.fromCenter(center: c, width: w * 2, height: h * 2)),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell.width * 0.035
      ..color = Colors.white,
  );
}
