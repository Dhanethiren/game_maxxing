import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'progression.dart';

/// Minimal key-value storage used by [PlayerProfile].
abstract class KeyValueStore {
  Object? get(String key);
  Future<void> set(String key, Object value);
  Future<void> remove(String key);
}

class _PrefsStore implements KeyValueStore {
  _PrefsStore(this._p);
  final SharedPreferences _p;

  @override
  Object? get(String key) => _p.get(key);

  @override
  Future<void> set(String key, Object value) => switch (value) {
    int v => _p.setInt(key, v),
    bool v => _p.setBool(key, v),
    String v => _p.setString(key, v),
    _ => throw ArgumentError('Unsupported type for $key'),
  };

  @override
  Future<void> remove(String key) => _p.remove(key);
}

/// Fallback when device storage is unavailable (and for tests): works, but
/// forgets everything when the app closes.
class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, Object>? initial]) : _data = {...?initial};
  final Map<String, Object> _data;

  @override
  Object? get(String key) => _data[key];

  @override
  Future<void> set(String key, Object value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

/// Everything the game remembers about the player, all stored on the device.
class PlayerProfile extends ChangeNotifier {
  PlayerProfile(this._store);

  static Future<PlayerProfile> load() async =>
      PlayerProfile(_PrefsStore(await SharedPreferences.getInstance()));

  final KeyValueStore _store;

  int _int(String k, [int d = 0]) => _store.get(k) as int? ?? d;
  bool _bool(String k, [bool d = false]) => _store.get(k) as bool? ?? d;
  String? _str(String k) => _store.get(k) as String?;

  Future<void> _set(String k, Object v) async {
    await _store.set(k, v);
    notifyListeners();
  }

  // ------------------------------------------------------- session counters
  int gamesThisSession = 0;
  int adsWatchedThisSession = 0;
  int interstitialsThisSession = 0;
  final DateTime sessionStart = DateTime.now();

  // ------------------------------------------------------------------ stats
  int get bestScore => _int('bestScore');
  int get gamesPlayed => _int('gamesPlayed');
  int get lifetimeOffers => _int('lifetimeOffers');
  int get lifetimeAccepts => _int('lifetimeAccepts');

  /// Returns true if [score] is a new best.
  Future<bool> submitScore(int score) async {
    if (score <= bestScore) return false;
    await _set('bestScore', score);
    return true;
  }

  Future<void> onGameStarted() async => gamesThisSession++;

  Future<void> onGameFinished() async {
    await _set('gamesPlayed', gamesPlayed + 1);
    await _set('gamesSinceInterstitial', gamesSinceInterstitial + 1);
  }

  // -------------------------------------------------------------------- ads
  DateTime? _time(String k) {
    final ms = _store.get(k) as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  DateTime? get lastAdAt => _time('lastAdAt');
  DateTime? get lastInterstitialAt => _time('lastInterstitialAt');
  int get gamesSinceInterstitial => _int('gamesSinceInterstitial');
  String? get optimizerState => _str('offerOptimizer');

  Future<void> onOfferShown({required bool accepted}) async {
    await _set('lifetimeOffers', lifetimeOffers + 1);
    if (accepted) await _set('lifetimeAccepts', lifetimeAccepts + 1);
  }

  Future<void> onAdWatched() async {
    adsWatchedThisSession++;
    await _set('lastAdAt', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> onInterstitialShown() async {
    interstitialsThisSession++;
    await _set('lastInterstitialAt', DateTime.now().millisecondsSinceEpoch);
    await _set('gamesSinceInterstitial', 0);
  }

  Future<void> saveOptimizerState(String json) => _set('offerOptimizer', json);

  // ------------------------------------------------------- coins and levels
  int get coins => _int('coins');
  int get xp => _int('xp');
  int get level => Progression.levelForXp(xp);

  Future<void> addCoins(int amount) => _set('coins', coins + amount);

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await _set('coins', coins - amount);
    return true;
  }

  /// Adds XP and pays level-up rewards. Returns the levels reached (if any).
  Future<List<int>> addXp(int amount) async {
    final before = level;
    await _set('xp', xp + amount);
    final reached = [for (var l = before + 1; l <= level; l++) l];
    for (final l in reached) {
      await addCoins(Progression.levelUpReward(l));
    }
    return reached;
  }

  // ---------------------------------------------------------------- settings
  bool get soundOn => _bool('soundOn', true);
  bool get musicOn => _bool('musicOn', true);
  bool get hapticsOn => _bool('hapticsOn', true);
  bool get tutorialDone => _bool('tutorialDone');

  Future<void> setSoundOn(bool v) => _set('soundOn', v);
  Future<void> setMusicOn(bool v) => _set('musicOn', v);
  Future<void> setHapticsOn(bool v) => _set('hapticsOn', v);
  Future<void> setTutorialDone() => _set('tutorialDone', true);

  // ------------------------------------------------------------------ themes
  String get selectedTheme => _str('theme') ?? 'dawn';

  Set<String> get ownedThemes => {'dawn', ...?_str('ownedThemes')?.split(',')};

  Future<void> selectTheme(String id) => _set('theme', id);

  Future<bool> buyTheme(String id, int price) async {
    if (ownedThemes.contains(id)) return true;
    if (!await spendCoins(price)) return false;
    await _set('ownedThemes', {...ownedThemes, id}.join(','));
    return true;
  }

  // ----------------------------------------------------------- daily reward
  int? get lastDailyClaimDay => _store.get('dailyDay') as int?;
  int get dailyStreak => _int('dailyStreak');

  /// Streak day (1-7) that can be claimed now, or null if already claimed.
  int? claimableDailyDay([DateTime? now]) => Progression.claimableStreakDay(
    lastClaimDay: lastDailyClaimDay,
    streak: dailyStreak,
    now: now ?? DateTime.now(),
  );

  /// Claims today's reward ([multiplier] 2 after watching an ad). Returns coins.
  Future<int> claimDaily({int multiplier = 1, DateTime? now}) async {
    final day = claimableDailyDay(now);
    if (day == null) return 0;
    final coins = Progression.dailyRewards[day - 1] * multiplier;
    await _set('dailyDay', Progression.dayKey(now ?? DateTime.now()));
    await _set('dailyStreak', day);
    await addCoins(coins);
    return coins;
  }

  // ------------------------------------------------------------------ journey
  /// Highest level the player may play (levels below it are completed).
  int get journeyLevel => _int('journeyLevel', 1);
  int get journeyWinStreak => _int('journeyStreak');

  Map<int, int> get journeyStars {
    final s = _str('journeyStars');
    if (s == null) return {};
    try {
      return {
        for (final e in (jsonDecode(s) as Map<String, dynamic>).entries)
          int.parse(e.key): e.value as int,
      };
    } catch (_) {
      return {};
    }
  }

  /// Records a completed level and pays coins. Returns the coins earned.
  Future<int> completeLevel(int level, int stars) async {
    final firstTime = level >= journeyLevel;
    final streak = journeyWinStreak;
    final coins = firstTime
        ? Progression.levelCoins(level, stars, streak)
        : Progression.replayCoins;
    final all = journeyStars;
    all[level] = max(all[level] ?? 0, stars);
    await _set(
      'journeyStars',
      jsonEncode({for (final e in all.entries) '${e.key}': e.value}),
    );
    if (firstTime) await _set('journeyLevel', level + 1);
    await _set('journeyStreak', streak + 1);
    await addCoins(coins);
    return coins;
  }

  Future<void> failLevel() => _set('journeyStreak', 0);

  // ----------------------------------------------------------- daily spin
  bool get freeSpinAvailable =>
      _store.get('spinDay') != Progression.dayKey(DateTime.now());

  bool get extraSpinAvailable =>
      !freeSpinAvailable &&
      _store.get('extraSpinDay') != Progression.dayKey(DateTime.now());

  Future<void> useSpin({required bool extra}) => _set(
    extra ? 'extraSpinDay' : 'spinDay',
    Progression.dayKey(DateTime.now()),
  );

  // -------------------------------------------------- free coins (ad), capped
  static const freeCoinAdsPerDay = 5;

  int get freeCoinAdsLeft {
    final today = Progression.dayKey(DateTime.now());
    if (_store.get('freeCoinsDay') != today) return freeCoinAdsPerDay;
    return (freeCoinAdsPerDay - _int('freeCoinsUsed')).clamp(
      0,
      freeCoinAdsPerDay,
    );
  }

  Future<void> useFreeCoinAd() async {
    final today = Progression.dayKey(DateTime.now());
    final used = _store.get('freeCoinsDay') == today
        ? _int('freeCoinsUsed')
        : 0;
    await _set('freeCoinsDay', today);
    await _set('freeCoinsUsed', used + 1);
  }

  // ---------------------------------------------------------------- missions
  DailyMissions? _missions;

  DailyMissions missions([DateTime? now]) {
    final today = Progression.dayKey(now ?? DateTime.now());
    if (_missions?.day != today) {
      _missions = DailyMissions.load(_str('missions'), today, level);
    }
    return _missions!;
  }

  /// Saves mission progress and pays out newly completed missions.
  Future<void> commitMissions(List<Mission> completed) async {
    for (final m in completed) {
      await addCoins(m.reward);
    }
    await _set('missions', missions().toJson());
  }

  // -------------------------------------------------------------- saved game
  Map<String, dynamic>? get savedGame {
    final s = _str('savedGame');
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool get hasSavedGame => _str('savedGame') != null;

  Future<void> saveGame(Map<String, dynamic> json) =>
      _store.set('savedGame', jsonEncode(json)); // no notify: called every move

  Future<void> clearSavedGame() async {
    await _store.remove('savedGame');
    notifyListeners();
  }
}
