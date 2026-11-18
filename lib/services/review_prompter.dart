import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

/// Google Play In-App Review. Ratings feed Play's ranking, and Play weights a
/// game's *recent* ratings most, so asking happy players matters.
///
/// Google's rules (developer.android.com/guide/playcore/in-app-review):
/// ask only after the player has experienced enough of the game, at a natural
/// moment, never behind a button (use [openStoreListing] for that), and never
/// with screening questions first. Play also applies its own hidden quota, so
/// the app keeps its own timing limits ([ReviewPolicy]).
abstract class ReviewService {
  Future<void> requestReview();

  /// Opens the Play Store page: the allowed way to rate from a button.
  Future<void> openStoreListing();

  static ReviewService create() {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return mobile ? PlayReviewService() : NoReviewService();
  }
}

class PlayReviewService implements ReviewService {
  @override
  Future<void> requestReview() async {
    try {
      if (await InAppReview.instance.isAvailable()) {
        await InAppReview.instance.requestReview();
      }
    } catch (e) {
      debugPrint('In-app review unavailable: $e');
    }
  }

  @override
  Future<void> openStoreListing() async {
    try {
      await InAppReview.instance.openStoreListing();
    } catch (e) {
      debugPrint('Store listing unavailable: $e');
    }
  }
}

/// Used on web/desktop and in tests.
class NoReviewService implements ReviewService {
  int requests = 0;
  int storeOpens = 0;

  @override
  Future<void> requestReview() async => requests++;

  @override
  Future<void> openStoreListing() async => storeOpens++;
}

/// When it's appropriate to ask for a rating.
class ReviewPolicy {
  static const minGames = 5;
  static const minAge = Duration(days: 2);
  static const minGap = Duration(days: 120);

  static bool shouldAsk({
    required bool happyMoment,
    required int gamesPlayed,
    required DateTime firstOpenAt,
    required DateTime? lastPromptAt,
    required DateTime now,
  }) {
    if (!happyMoment) return false;
    if (gamesPlayed < minGames) return false;
    if (now.difference(firstOpenAt) < minAge) return false;
    if (lastPromptAt != null && now.difference(lastPromptAt) < minGap) {
      return false;
    }
    return true;
  }
}
