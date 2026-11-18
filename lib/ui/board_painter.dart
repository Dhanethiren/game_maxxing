import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../game/board.dart';
import '../game/piece.dart';
import 'block_painter.dart';
import 'game_theme.dart';

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(cell * 0.35)),
      Paint()..color = theme.board,
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

    final emptyPaint = Paint()..color = theme.emptyCell;
    final emptyRadius = Radius.circular(cell * 0.2);
    final ghostColor = visuals.ghostColor == null
        ? null
        : theme.blocks[visuals.ghostColor!];

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final pos = Cell(r, c);
        final value = board.at(r, c);
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect(r, c), emptyRadius),
          emptyPaint,
        );

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
