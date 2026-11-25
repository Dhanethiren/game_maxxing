import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

/// In-app review (Google Play In-App Review, Apple's SKStoreReviewController).
/// Ratings feed ranking on both stores, and Play weights a game's *recent*
/// ratings most, so asking happy players matters.
///
/// Google's rules (developer.android.com/guide/playcore/in-app-review):
/// ask only after the player has experienced enough of the game, at a natural
/// moment, never behind a button (use [openStoreListing] for that), and never
/// with screening questions first. Play also applies its own hidden quota, so
/// the app keeps its own timing limits ([ReviewPolicy]).
abstract class ReviewService {
  /// The app's numeric Apple ID from App Store Connect (App Information →
  /// Apple ID). iOS needs it to open the store page. TODO(release, iOS).
  static const appStoreId = '';

  Future<void> requestReview();

  /// Opens the store page: the allowed way to rate from a button.
  Future<void> openStoreListing();

  /// Whether [openStoreListing] can work on this device. On iOS it needs
  /// [appStoreId]; until that is set the "Rate" button stays hidden.
  bool get canOpenStore;

  static ReviewService create() {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return mobile ? PlayReviewService() : NoReviewService();
  }
}

class PlayReviewService implements ReviewService {
  bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get canOpenStore => !_ios || ReviewService.appStoreId.isNotEmpty;

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
      await InAppReview.instance.openStoreListing(
        appStoreId: _ios ? ReviewService.appStoreId : null,
      );
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
  bool get canOpenStore => true;

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
