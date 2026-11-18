import '../game/game_state.dart';

/// Lifetime achievements. Google Play Games "Level Up" asks games for at least
/// 10 Play Games achievements (they surface in Play search filters, the You
/// tab and Play Points quests), so each one has a stable [id] ready to map to
/// a Play Games Services achievement ID in Play Console.
enum Achievement {
  firstBlock('first_block', 'First steps', 'Place your first block'),
  firstLine('first_line', 'Line up', 'Clear your first line'),
  double('double', 'Double up', 'Clear 2 lines with one block'),
  triple('triple', 'Triple treat', 'Clear 3 lines with one block'),
  combo3('combo3', 'In the flow', 'Reach a ×3 combo'),
  combo6('combo6', 'Combo master', 'Reach a ×6 combo'),
  perfect('perfect', 'Clean slate', 'Clear the whole board'),
  score1k('score1k', 'Thousand club', 'Score 1,000 in one game'),
  score5k('score5k', 'High flyer', 'Score 5,000 in one game'),
  lines500('lines500', 'Line collector', 'Clear 500 lines in total'),
  journey5('journey5', 'On the path', 'Complete Journey level 5'),
  journey25('journey25', 'Wayfarer', 'Complete Journey level 25'),
  stars30('stars30', 'Star gazer', 'Earn 30 stars in Journey'),
  gems50('gems50', 'Gem hunter', 'Collect 50 gems in total'),
  streak7('streak7', 'Daily habit', 'Reach a 7-day login streak');

  const Achievement(this.id, this.title, this.description);

  final String id;
  final String title;
  final String description;

  /// Coins paid when unlocked.
  static const reward = 25;
}

/// Lifetime totals the achievements need.
class AchievementStats {
  const AchievementStats({
    required this.lifetimeLines,
    required this.lifetimeGems,
    required this.journeyLevelsDone,
    required this.journeyStars,
    required this.dailyStreak,
  });

  final int lifetimeLines;
  final int lifetimeGems;

  /// Highest Journey level completed.
  final int journeyLevelsDone;
  final int journeyStars;
  final int dailyStreak;
}

/// Pure rules: which achievements a moment earns.
class AchievementRules {
  static Set<Achievement> onPlace(PlaceEvent e, int score) => {
    Achievement.firstBlock,
    if (e.lines >= 1) Achievement.firstLine,
    if (e.lines >= 2) Achievement.double,
    if (e.lines >= 3) Achievement.triple,
    if (e.combo >= 3) Achievement.combo3,
    if (e.combo >= 6) Achievement.combo6,
    if (e.perfect) Achievement.perfect,
    if (score >= 1000) Achievement.score1k,
    if (score >= 5000) Achievement.score5k,
  };

  static Set<Achievement> fromStats(AchievementStats s) => {
    if (s.lifetimeLines >= 500) Achievement.lines500,
    if (s.journeyLevelsDone >= 5) Achievement.journey5,
    if (s.journeyLevelsDone >= 25) Achievement.journey25,
    if (s.journeyStars >= 30) Achievement.stars30,
    if (s.lifetimeGems >= 50) Achievement.gems50,
    if (s.dailyStreak >= 7) Achievement.streak7,
  };
}
