import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob ad unit IDs.
///
/// These are Google's official TEST IDs and are safe to use while developing.
/// BEFORE PUBLISHING: create an app + rewarded ad unit in AdMob
/// (https://apps.admob.com) and replace the release IDs below, plus the
/// APPLICATION_ID in android/app/src/main/AndroidManifest.xml and
/// ios/Runner/Info.plist. Never click your own real ads.
class AdIds {
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // TODO(release): replace with your real rewarded ad unit IDs.
  static const _releaseRewardedAndroid = _testRewardedAndroid;
  static const _releaseRewardedIos = _testRewardedIos;

  static String get rewarded {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    if (kReleaseMode) return ios ? _releaseRewardedIos : _releaseRewardedAndroid;
    return ios ? _testRewardedIos : _testRewardedAndroid;
  }
}

/// Shows rewarded ads. The game only talks to this interface, so the ad
/// network can be swapped and tests can use [SimulatedAdService].
abstract class RewardedAdService {
  Future<void> init();

  /// True when an ad is loaded and can be shown immediately.
  bool get isReady;

  /// Shows an ad. Completes with `true` only if the player earned the reward
  /// (watched to the end).
  Future<bool> showRewarded();

  /// True if the player must be offered a "Privacy options" button
  /// (required by Google for players in regions with consent laws).
  Future<bool> privacyOptionsRequired() async => false;

  Future<void> showPrivacyOptions() async {}

  static RewardedAdService create() {
    final mobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return mobile ? AdMobRewardedService() : SimulatedAdService();
  }
}

/// Real ads through Google AdMob, including the Google consent form (UMP),
/// which is required for players in the EU/UK.
class AdMobRewardedService implements RewardedAdService {
  RewardedAd? _ad;
  bool _loading = false;
  bool _canRequestAds = false;
  int _retry = 0;

  @override
  bool get isReady => _ad != null;

  @override
  Future<void> init() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => done.complete()),
      (_) => done.complete(),
    );
    await done.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (!_canRequestAds) return;
    await MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (_loading || _ad != null || !_canRequestAds) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          _retry = 0;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          // Back off: 2s, 4s, 8s ... up to 64s.
          final delay = Duration(seconds: 2 << _retry.clamp(0, 5));
          _retry++;
          Timer(delay, _load);
        },
      ),
    );
  }

  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) => done.complete());
    await done.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    _load();
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _ad;
    if (ad == null) {
      _load();
      return false;
    }
    _ad = null;
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!result.isCompleted) result.complete(earned);
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!result.isCompleted) result.complete(false);
        _load();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }
}

/// Stand-in used on web/desktop and in tests: waits briefly and grants the
/// reward, so the full revive flow can be tried without a phone.
class SimulatedAdService implements RewardedAdService {
  SimulatedAdService({this.delay = const Duration(milliseconds: 1500)});

  final Duration delay;

  @override
  bool get isReady => true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<bool> showRewarded() async {
    await Future<void>.delayed(delay);
    return true;
  }
}
