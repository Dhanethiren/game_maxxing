import '../ads/ad_policy.dart';
import '../ads/ad_service.dart';
import '../game/game_state.dart';
import '../ml/offer_optimizer.dart';
import 'player_profile.dart';

/// Glue between the game, the ML optimizer, the player's profile and the ad
/// network. The UI only needs this class to run ads.
class RewardOffers {
  RewardOffers({
    required this.ads,
    required this.profile,
    OfferOptimizer? optimizer,
    this.interstitialPolicy = const InterstitialPolicy(),
  }) : optimizer = optimizer ?? OfferOptimizer() {
    this.optimizer.loadJson(profile.optimizerState);
  }

  final AdService ads;
  final PlayerProfile profile;
  final OfferOptimizer optimizer;
  final InterstitialPolicy interstitialPolicy;

  OfferContext contextFor(GameState? game) {
    final lastAd = profile.lastAdAt;
    return OfferContext(
      score: game?.score ?? 0,
      bestScore: profile.bestScore,
      gameDuration: game?.elapsed ?? Duration.zero,
      gamesThisSession: profile.gamesThisSession,
      adsWatchedThisSession: profile.adsWatchedThisSession,
      timeSinceLastAd: lastAd == null
          ? null
          : DateTime.now().difference(lastAd),
      lifetimeOffers: profile.lifetimeOffers,
      lifetimeAccepts: profile.lifetimeAccepts,
      boardFill: game?.board.fillRatio ?? 0,
    );
  }

  /// Lets the ML model pick how to present an offer.
  OfferDecision decide(OfferPlacement placement, [GameState? game]) =>
      optimizer.choose(placement, contextFor(game));

  /// Call once the player has answered (or ignored) the offer.
  Future<void> recordAnswer(
    OfferDecision decision, {
    required bool accepted,
  }) async {
    optimizer.record(decision, accepted: accepted);
    await profile.onOfferShown(accepted: accepted);
    await profile.saveOptimizerState(optimizer.toJson());
  }

  /// Shows a rewarded ad. Returns true if the reward should be granted.
  Future<bool> watchAd() async {
    final earned = await ads.showRewarded();
    if (earned) await profile.onAdWatched();
    return earned;
  }

  /// Shows an interstitial if the [interstitialPolicy] allows it right now.
  /// Call only at a natural break (leaving the game-over screen).
  Future<bool> maybeShowInterstitial({required bool justSetNewBest}) async {
    final allowed = interstitialPolicy.shouldShow(
      lifetimeGames: profile.gamesPlayed,
      gamesSinceLast: profile.gamesSinceInterstitial,
      lastInterstitialAt: profile.lastInterstitialAt,
      lastRewardedAt: profile.lastAdAt,
      shownThisSession: profile.interstitialsThisSession,
      sessionStart: profile.sessionStart,
      justSetNewBest: justSetNewBest,
      now: DateTime.now(),
    );
    if (!allowed || !ads.interstitialReady) return false;
    await ads.showInterstitial();
    await profile.onInterstitialShown();
    return true;
  }
}
