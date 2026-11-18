import 'package:material_ui/material_ui.dart';

/// Soft, low-contrast palette chosen to feel relaxing.
class CalmPalette {
  static const backgroundTop = Color(0xFFE9E4F7);
  static const backgroundBottom = Color(0xFFDDF1EC);
  static const boardBackground = Color(0x66FFFFFF);
  static const emptyCell = Color(0x8CFFFFFF);
  static const text = Color(0xFF4A4A68);
  static const textSoft = Color(0xFF8A8AA6);
  static const accent = Color(0xFF8E7CC3);

  static const blocks = <Color>[
    Color(0xFF7FB7E8), // sky
    Color(0xFF8FCB9E), // sage
    Color(0xFFF4B183), // peach
    Color(0xFFE8A0BF), // rose
    Color(0xFFB2A1E6), // lavender
    Color(0xFFF0CD6E), // butter
    Color(0xFF72CCC3), // teal
  ];

  static ThemeData theme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: accent),
        scaffoldBackgroundColor: backgroundTop,
        textTheme: const TextTheme().apply(
          bodyColor: text,
          displayColor: text,
        ),
      );

  static const backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backgroundTop, backgroundBottom],
    ),
  );
}

/// One rounded block square.
class BlockTile extends StatelessWidget {
  const BlockTile({super.key, required this.color, required this.size, this.glow = false});

  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: glow ? Colors.white : color,
        borderRadius: radius,
        boxShadow: color.a > 0.9 || glow
            ? [
                BoxShadow(
                  color: (glow ? Colors.white : color).withValues(alpha: 0.45),
                  blurRadius: glow ? 10 : 3,
                  offset: const Offset(0, 1.5),
                ),
              ]
            : null,
      ),
    );
  }
}
