import 'package:shared_preferences/shared_preferences.dart';

/// Minimal key-value storage used by [PlayerProfile].
abstract class KeyValueStore {
  int? getInt(String key);
  String? getString(String key);
  Future<void> setInt(String key, int value);
  Future<void> setString(String key, String value);
}

class _PrefsStore implements KeyValueStore {
  _PrefsStore(this._p);
  final SharedPreferences _p;
  @override
  int? getInt(String key) => _p.getInt(key);
  @override
  String? getString(String key) => _p.getString(key);
  @override
  Future<void> setInt(String key, int value) => _p.setInt(key, value);
  @override
  Future<void> setString(String key, String value) => _p.setString(key, value);
}

/// Fallback when device storage is unavailable: works, but forgets on exit.
class MemoryStore implements KeyValueStore {
  final _data = <String, Object>{};
  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  String? getString(String key) => _data[key] as String?;
  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;
  @override
  Future<void> setString(String key, String value) async => _data[key] = value;
}

/// Small on-device store for scores and ad-interaction history.
class PlayerProfile {
  PlayerProfile(this._prefs);

  static Future<PlayerProfile> load() async =>
      PlayerProfile(_PrefsStore(await SharedPreferences.getInstance()));

  final KeyValueStore _prefs;

  // Session-only counters (reset when the app restarts).
  int gamesThisSession = 0;
  int adsWatchedThisSession = 0;

  int get bestScore => _prefs.getInt('bestScore') ?? 0;
  int get gamesPlayed => _prefs.getInt('gamesPlayed') ?? 0;
  int get lifetimeOffers => _prefs.getInt('lifetimeOffers') ?? 0;
  int get lifetimeAccepts => _prefs.getInt('lifetimeAccepts') ?? 0;

  DateTime? get lastAdAt {
    final ms = _prefs.getInt('lastAdAt');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  String? get optimizerState => _prefs.getString('offerOptimizer');

  /// Returns true if [score] is a new best.
  Future<bool> submitScore(int score) async {
    if (score <= bestScore) return false;
    await _prefs.setInt('bestScore', score);
    return true;
  }

  Future<void> onGameStarted() async {
    gamesThisSession++;
    await _prefs.setInt('gamesPlayed', gamesPlayed + 1);
  }

  Future<void> onOfferShown({required bool accepted}) async {
    await _prefs.setInt('lifetimeOffers', lifetimeOffers + 1);
    if (accepted) await _prefs.setInt('lifetimeAccepts', lifetimeAccepts + 1);
  }

  Future<void> onAdWatched() async {
    adsWatchedThisSession++;
    await _prefs.setInt('lastAdAt', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> saveOptimizerState(String json) =>
      _prefs.setString('offerOptimizer', json);
}
