import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/sound_service.dart';
import '../services/achievements.dart';
import '../services/player_profile.dart';
import '../services/review_prompter.dart';
import '../services/reward_offers.dart';
import '../ui/game_theme.dart';

/// The app's long-lived services.
class AppServices {
  AppServices({
    required this.profile,
    required this.offers,
    required this.sound,
    ReviewService? review,
  }) : review = review ?? ReviewService.create() {
    _syncSettings();
    profile.addListener(_syncSettings);
  }

  final PlayerProfile profile;
  final RewardOffers offers;
  final SoundService sound;
  final ReviewService review;

  /// Checks lifetime-stat achievements (Journey, gems, streak...) and pays
  /// any new ones. Returns those unlocked now.
  Future<List<Achievement>> checkStatAchievements() =>
      profile.unlock(AchievementRules.fromStats(profile.achievementStats));

  /// Asks for a Play rating if this is a good moment (see [ReviewPolicy]).
  Future<void> maybeAskForReview({required bool happyMoment}) async {
    final ask = ReviewPolicy.shouldAsk(
      happyMoment: happyMoment,
      gamesPlayed: profile.gamesPlayed,
      firstOpenAt: profile.firstOpenAt,
      lastPromptAt: profile.lastReviewPromptAt,
      now: DateTime.now(),
    );
    if (!ask) return;
    await profile.markReviewPrompted();
    await review.requestReview();
  }

  GameTheme get theme => GameTheme.byId(profile.selectedTheme);

  void _syncSettings() {
    final musicChanged = sound.musicOn != profile.musicOn;
    sound
      ..soundOn = profile.soundOn
      ..musicOn = profile.musicOn;
    if (musicChanged) sound.updateMusic();
  }

  void lightHaptic() {
    if (profile.hapticsOn) HapticFeedback.selectionClick();
  }

  void mediumHaptic() {
    if (profile.hapticsOn) HapticFeedback.mediumImpact();
  }

  void heavyHaptic() {
    if (profile.hapticsOn) HapticFeedback.heavyImpact();
  }

  /// Button tap: sound + light haptic.
  void tap() {
    sound.play(Sfx.tap);
    lightHaptic();
  }
}

/// Makes [AppServices] available to every screen, and rebuilds dependants
/// when the profile changes (coins, theme, settings...).
class AppScope extends InheritedNotifier<PlayerProfile> {
  AppScope({super.key, required this.services, required super.child})
    : super(notifier: services.profile);

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  /// Read without subscribing to changes (for callbacks).
  static AppServices read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.services;
}

/// Scales sizes to the screen so the layout works from small 320dp phones
/// to tablets. 1.0 = a typical 390dp-wide phone.
double uiScale(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return (size.shortestSide / 390).clamp(0.8, 1.45);
}
