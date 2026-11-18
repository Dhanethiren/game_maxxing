import 'package:shared_preferences/shared_preferences.dart';

/// Small on-device store for scores and ad-interaction history.
class PlayerProfile {
  PlayerProfile(this._prefs);

  static Future<PlayerProfile> load() async =>
      PlayerProfile(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

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
