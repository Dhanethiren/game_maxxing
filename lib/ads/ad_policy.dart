/// When a full-screen (interstitial) ad may be shown.
///
/// Based on the research in docs/RESEARCH.md: interstitials are the ad type
/// most likely to make players quit, so they are only shown at a natural
/// break (after a game ends, when the player taps to continue), never to new
/// players, and never close together. Rewarded ads (which the player chooses)
/// are the main income and are never limited by this policy.
class InterstitialPolicy {
  const InterstitialPolicy({
    this.enabled = true,
    this.minLifetimeGames = 3,
    this.minGamesBetween = 3,
    this.minGap = const Duration(minutes: 3),
    this.quietAfterRewarded = const Duration(minutes: 3),
    this.maxPerSession = 4,
    this.minSessionAge = const Duration(seconds: 90),
  });

  /// Master switch. Set to false for a rewarded-ads-only game.
  final bool enabled;

  /// New players get this many full games with no interstitials at all.
  final int minLifetimeGames;

  /// At most one interstitial every N games.
  final int minGamesBetween;

  /// Minimum time between two interstitials.
  final Duration minGap;

  /// Skip if the player watched a rewarded ad recently: they've "paid".
  final Duration quietAfterRewarded;

  final int maxPerSession;

  /// No interstitial in the first moments after opening the app.
  final Duration minSessionAge;

  bool shouldShow({
    required int lifetimeGames,
    required int gamesSinceLast,
    required DateTime? lastInterstitialAt,
    required DateTime? lastRewardedAt,
    required int shownThisSession,
    required DateTime sessionStart,
    required bool justSetNewBest,
    required DateTime now,
  }) {
    if (!enabled) return false;
    if (lifetimeGames < minLifetimeGames) return false;
    if (gamesSinceLast < minGamesBetween) return false;
    if (shownThisSession >= maxPerSession) return false;
    if (justSetNewBest) return false; // don't spoil a celebration
    if (now.difference(sessionStart) < minSessionAge) return false;
    if (lastInterstitialAt != null &&
        now.difference(lastInterstitialAt) < minGap) {
      return false;
    }
    if (lastRewardedAt != null &&
        now.difference(lastRewardedAt) < quietAfterRewarded) {
      return false;
    }
    return true;
  }
}
