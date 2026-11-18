import 'package:material_ui/material_ui.dart';

/// A colour theme for the whole game. Themes are the main thing players
/// unlock with coins (a long-term goal that keeps them coming back).
class GameTheme {
  const GameTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.board,
    required this.emptyCell,
    required this.text,
    required this.textSoft,
    required this.accent,
    required this.blocks,
    this.dark = false,
  });

  final String id;
  final String name;
  final int price;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color board;
  final Color emptyCell;
  final Color text;
  final Color textSoft;
  final Color accent;
  final List<Color> blocks;
  final bool dark;

  /// Surface colour for cards and dialogs.
  Color get card => dark ? const Color(0xFF2C2F55) : const Color(0xFFFBFAFF);

  BoxDecoration get background => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backgroundTop, backgroundBottom],
    ),
  );

  ThemeData toThemeData() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: dark ? Brightness.dark : Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundTop,
    textTheme:
        (dark
                ? Typography.material2021().white
                : Typography.material2021().black)
            .apply(bodyColor: text, displayColor: text),
    dialogTheme: DialogThemeData(backgroundColor: card),
  );

  static GameTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);

  static const all = <GameTheme>[
    GameTheme(
      id: 'dawn',
      name: 'Lavender Dawn',
      price: 0,
      backgroundTop: Color(0xFFE9E4F7),
      backgroundBottom: Color(0xFFDDF1EC),
      board: Color(0x66FFFFFF),
      emptyCell: Color(0x8CFFFFFF),
      text: Color(0xFF4A4A68),
      textSoft: Color(0xFF8A8AA6),
      accent: Color(0xFF8E7CC3),
      blocks: [
        Color(0xFF7FB7E8),
        Color(0xFF8FCB9E),
        Color(0xFFF4B183),
        Color(0xFFE8A0BF),
        Color(0xFFB2A1E6),
        Color(0xFFF0CD6E),
        Color(0xFF72CCC3),
      ],
    ),
    GameTheme(
      id: 'ocean',
      name: 'Ocean Calm',
      price: 300,
      backgroundTop: Color(0xFFDFF3FB),
      backgroundBottom: Color(0xFFE6ECFA),
      board: Color(0x55FFFFFF),
      emptyCell: Color(0x80FFFFFF),
      text: Color(0xFF2F4A63),
      textSoft: Color(0xFF7890A6),
      accent: Color(0xFF3D8FC6),
      blocks: [
        Color(0xFF5DADE2),
        Color(0xFF48C9B0),
        Color(0xFF7FB3D5),
        Color(0xFF76D7C4),
        Color(0xFF85C1E9),
        Color(0xFFA3E4D7),
        Color(0xFF5499C7),
      ],
    ),
    GameTheme(
      id: 'forest',
      name: 'Forest Moss',
      price: 500,
      backgroundTop: Color(0xFFEAF2E3),
      backgroundBottom: Color(0xFFF4EFE1),
      board: Color(0x55FFFFFF),
      emptyCell: Color(0x80FFFFFF),
      text: Color(0xFF3E4A3A),
      textSoft: Color(0xFF7F8C78),
      accent: Color(0xFF6B9B5E),
      blocks: [
        Color(0xFF8DB580),
        Color(0xFFC9A66B),
        Color(0xFF7FA88F),
        Color(0xFFD4B483),
        Color(0xFFA3C585),
        Color(0xFFB59B7A),
        Color(0xFF6E9E7E),
      ],
    ),
    GameTheme(
      id: 'sunset',
      name: 'Sunset Glow',
      price: 800,
      backgroundTop: Color(0xFFFDE8D7),
      backgroundBottom: Color(0xFFF9D7E0),
      board: Color(0x55FFFFFF),
      emptyCell: Color(0x80FFFFFF),
      text: Color(0xFF5A3D4A),
      textSoft: Color(0xFF9C7F8A),
      accent: Color(0xFFE07A5F),
      blocks: [
        Color(0xFFF2A65A),
        Color(0xFFEE6C4D),
        Color(0xFFF7C59F),
        Color(0xFFE58FA9),
        Color(0xFFF4D06F),
        Color(0xFFD97B93),
        Color(0xFFF08A5D),
      ],
    ),
    GameTheme(
      id: 'night',
      name: 'Midnight Stars',
      price: 1200,
      dark: true,
      backgroundTop: Color(0xFF1B1F3B),
      backgroundBottom: Color(0xFF2A2350),
      board: Color(0x22FFFFFF),
      emptyCell: Color(0x16FFFFFF),
      text: Color(0xFFE8E6F5),
      textSoft: Color(0xFFA9A6C9),
      accent: Color(0xFFB9A6FF),
      blocks: [
        Color(0xFF7FD1FF),
        Color(0xFF9EF0C1),
        Color(0xFFFFB38A),
        Color(0xFFFF9EC7),
        Color(0xFFC3A6FF),
        Color(0xFFFFE08A),
        Color(0xFF7FF0E5),
      ],
    ),
    GameTheme(
      id: 'sakura',
      name: 'Sakura Breeze',
      price: 1500,
      backgroundTop: Color(0xFFFCEFF3),
      backgroundBottom: Color(0xFFF3F0FA),
      board: Color(0x55FFFFFF),
      emptyCell: Color(0x80FFFFFF),
      text: Color(0xFF5B4452),
      textSoft: Color(0xFF9E8794),
      accent: Color(0xFFE48AAE),
      blocks: [
        Color(0xFFF4A7C0),
        Color(0xFFEFB8CC),
        Color(0xFFE58FB0),
        Color(0xFFC9A7E8),
        Color(0xFFF9C9A4),
        Color(0xFFA9CDE3),
        Color(0xFFDDA0C8),
      ],
    ),
  ];
}
