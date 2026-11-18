import '../ads/ad_service.dart';
import '../game/game_state.dart';
import '../ml/offer_optimizer.dart';
import 'player_profile.dart';

/// Glue between the game, the ML optimizer, the player's profile and the ad
/// network. The UI only needs this class to run a "watch ad for X" offer.
class RewardOffers {
  RewardOffers({
    required this.ads,
    required this.profile,
    OfferOptimizer? optimizer,
  }) : optimizer = optimizer ?? OfferOptimizer() {
    this.optimizer.loadJson(profile.optimizerState);
  }

  final RewardedAdService ads;
  final PlayerProfile profile;
  final OfferOptimizer optimizer;

  OfferContext contextFor(GameState game) {
    final lastAd = profile.lastAdAt;
    return OfferContext(
      score: game.score,
      bestScore: profile.bestScore,
      gameDuration: game.elapsed,
      gamesThisSession: profile.gamesThisSession,
      adsWatchedThisSession: profile.adsWatchedThisSession,
      timeSinceLastAd: lastAd == null ? null : DateTime.now().difference(lastAd),
      lifetimeOffers: profile.lifetimeOffers,
      lifetimeAccepts: profile.lifetimeAccepts,
      boardFill: game.board.fillRatio,
    );
  }

  /// Decides how to present the revive offer for this game-over.
  OfferDecision decideRevive(GameState game) =>
      optimizer.choose(OfferPlacement.revive, contextFor(game));

  /// Call once the player has answered the offer, before showing the ad.
  Future<void> recordAnswer(OfferDecision decision, {required bool accepted}) async {
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
}
