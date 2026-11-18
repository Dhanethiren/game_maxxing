import 'package:material_ui/material_ui.dart';

import '../game/piece.dart';
import 'theme.dart';

/// Draws a [Piece] with square cells of [cellSize].
class PieceView extends StatelessWidget {
  const PieceView({super.key, required this.piece, required this.cellSize, this.gap = 3});

  final Piece piece;
  final double cellSize;
  final double gap;

  double get width => piece.cols * cellSize;
  double get height => piece.rows * cellSize;

  @override
  Widget build(BuildContext context) {
    final color = CalmPalette.blocks[piece.colorIndex];
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (final c in piece.cells)
            Positioned(
              left: c.col * cellSize + gap / 2,
              top: c.row * cellSize + gap / 2,
              child: BlockTile(color: color, size: cellSize - gap),
            ),
        ],
      ),
    );
  }
}
