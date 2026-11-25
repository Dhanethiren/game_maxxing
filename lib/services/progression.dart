import 'dart:convert';
import 'dart:math';

import '../game/game_state.dart';

/// Pure rules for coins, levels, daily rewards and daily missions.
/// Kept free of storage and UI so they are easy to test and tune.
class Progression {
  /// Total XP needed to reach [level] (level 1 starts at 0 XP).
  static int xpForLevel(int level) => 250 * (level - 1) * level ~/ 2;

  static int levelForXp(int xp) {
    var level = 1;
    while (xpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  /// Coins granted for reaching [level].
  static int levelUpReward(int level) => 50 + 25 * level;

  /// Coins earned at the end of a game.
  static int coinsForGame(int score, int lines) =>
      max(1, score ~/ 25 + lines ~/ 2);

  /// Coins for completing Journey level [level] with [stars], the first time.
  /// A win streak (consecutive levels won without failing) adds up to +100%.
  static int levelCoins(int level, int stars, int winStreak) {
    final base = 20 + level * 2 + (stars - 1) * 10;
    final streakBonus = 1 + 0.25 * min(winStreak, 4);
    return (base * streakBonus).round();
  }

  /// Coins for replaying a level that was already completed.
  static const replayCoins = 5;

  /// Daily spin wheel prizes (coins) and how likely each is.
  static const spinPrizes = [10, 25, 50, 15, 100, 20, 40, 200];
  static const spinWeights = [20, 16, 9, 18, 4, 18, 12, 1];

  /// Picks a wheel segment index using [spinWeights].
  static int spinSegment(Random r) {
    final total = spinWeights.reduce((a, b) => a + b);
    var roll = r.nextInt(total);
    for (var i = 0; i < spinWeights.length; i++) {
      roll -= spinWeights[i];
      if (roll < 0) return i;
    }
    return 0;
  }

  /// Rewards for day 1..7 of a login streak. Day 7 is the "jackpot".
  static const dailyRewards = [20, 30, 40, 60, 80, 100, 250];

  /// Calendar day as yyyymmdd in the device's local time.
  static int dayKey(DateTime t) => t.year * 10000 + t.month * 100 + t.day;

  static int _previousDay(int key) {
    final d = DateTime(key ~/ 10000, key ~/ 100 % 100, key % 100 - 1);
    return dayKey(d);
  }

  /// Which streak day can be claimed today, or null if already claimed.
  static int? claimableStreakDay({
    required int? lastClaimDay,
    required int streak,
    required DateTime now,
  }) {
    final today = dayKey(now);
    if (lastClaimDay == today) return null;
    if (lastClaimDay != null && lastClaimDay == _previousDay(today)) {
      return streak % dailyRewards.length + 1;
    }
    return 1; // first claim, or the streak was broken
  }
}

enum MissionType {
  clearLines('clearLines'),
  scoreInGame('scoreInGame'),
  comboInGame('comboInGame'),
  playGames('playGames'),
  placePieces('placePieces'),
  perfectClear('perfectClear');

  const MissionType(this.key);

  /// Saved with the mission. Spelled out so obfuscated builds read old saves.
  final String key;

  static MissionType byKey(String key) =>
      values.firstWhere((t) => t.key == key);
}

/// A small daily goal, e.g. "Clear 20 lines".
class Mission {
  Mission(
    this.type,
    this.target,
    this.reward, [
    this.progress = 0,
    this.done = false,
  ]);

  final MissionType type;
  final int target;
  final int reward;
  int progress;
  bool done;

  String get title => switch (type) {
    MissionType.clearLines => 'Clear $target lines',
    MissionType.scoreInGame => 'Score $target in one game',
    MissionType.comboInGame => 'Reach a ×$target combo',
    MissionType.playGames => 'Play $target games',
    MissionType.placePieces => 'Place $target blocks',
    MissionType.perfectClear => 'Clear the whole board',
  };

  double get fraction => (progress / target).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() => {
    't': type.key,
    'g': target,
    'r': reward,
    'p': progress,
    'd': done,
  };

  static Mission fromJson(Map<String, dynamic> j) => Mission(
    MissionType.byKey(j['t'] as String),
    j['g'] as int,
    j['r'] as int,
    j['p'] as int,
    j['d'] as bool,
  );
}

/// Today's three missions and their progress.
class DailyMissions {
  DailyMissions(this.day, this.missions);

  final int day;
  final List<Mission> missions;

  /// Three missions for [day], picked deterministically so they don't change
  /// if the app restarts. Targets grow gently with the player's [level].
  factory DailyMissions.generate(int day, int level) {
    final r = Random(day);
    final scale = 1 + min(level, 20) * 0.08;
    int scaled(int v) => (v * scale / 5).round() * 5;
    final pool = <Mission Function()>[
      () => Mission(MissionType.clearLines, scaled(15 + r.nextInt(3) * 5), 40),
      () => Mission(
        MissionType.scoreInGame,
        scaled(300 + r.nextInt(4) * 100),
        50,
      ),
      () => Mission(MissionType.comboInGame, 3 + r.nextInt(2), 50),
      () => Mission(MissionType.playGames, 3 + r.nextInt(3), 30),
      () =>
          Mission(MissionType.placePieces, scaled(40 + r.nextInt(3) * 20), 30),
      if (level >= 3) () => Mission(MissionType.perfectClear, 1, 80),
    ]..shuffle(r);
    return DailyMissions(day, [for (final make in pool.take(3)) make()]);
  }

  /// Loads saved progress, or makes fresh missions if it's a new day.
  factory DailyMissions.load(String? json, int today, int level) {
    if (json != null) {
      try {
        final j = jsonDecode(json) as Map<String, dynamic>;
        if (j['day'] == today) {
          return DailyMissions(today, [
            for (final m in j['m'] as List)
              Mission.fromJson(m as Map<String, dynamic>),
          ]);
        }
      } catch (_) {}
    }
    return DailyMissions.generate(today, level);
  }

  String toJson() => jsonEncode({
    'day': day,
    'm': [for (final m in missions) m.toJson()],
  });

  /// Updates progress after a placement. Returns missions completed by it.
  List<Mission> onPlace(PlaceEvent e) => _update(
    (m) => switch (m.type) {
      MissionType.clearLines => m.progress + e.lines,
      MissionType.placePieces => m.progress + 1,
      MissionType.comboInGame => max(m.progress, e.combo),
      MissionType.perfectClear => m.progress + (e.perfect ? 1 : 0),
      _ => m.progress,
    },
  );

  /// Updates progress when a game ends. Returns missions completed by it.
  List<Mission> onGameEnd(int score) => _update(
    (m) => switch (m.type) {
      MissionType.scoreInGame => max(m.progress, score),
      MissionType.playGames => m.progress + 1,
      _ => m.progress,
    },
  );

  /// Score progress also counts mid-game so the bar moves while playing.
  List<Mission> onScore(int score) => _update(
    (m) =>
        m.type == MissionType.scoreInGame ? max(m.progress, score) : m.progress,
  );

  List<Mission> _update(int Function(Mission) next) {
    final completed = <Mission>[];
    for (final m in missions) {
      if (m.done) continue;
      m.progress = min(next(m), m.target);
      if (m.progress >= m.target) {
        m.done = true;
        completed.add(m);
      }
    }
    return completed;
  }
}
