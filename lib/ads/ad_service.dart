import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob ad unit IDs.
///
/// These are Google's official TEST IDs and are safe to use while developing.
/// BEFORE PUBLISHING: create the app and two ad units (Rewarded and
/// Interstitial) in AdMob (https://apps.admob.com), replace the release IDs
/// below, and set the APPLICATION_ID in android/app/src/main/AndroidManifest.xml
/// and ios/Runner/Info.plist. Never click your own real ads.
class AdIds {
  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // TODO(release): replace with your real ad unit IDs.
  static const _releaseRewardedAndroid = _testRewardedAndroid;
  static const _releaseRewardedIos = _testRewardedIos;
  static const _releaseInterstitialAndroid = _testInterstitialAndroid;
  static const _releaseInterstitialIos = _testInterstitialIos;

  static String get rewarded => kReleaseMode
      ? (_ios ? _releaseRewardedIos : _releaseRewardedAndroid)
      : (_ios ? _testRewardedIos : _testRewardedAndroid);

  static String get interstitial => kReleaseMode
      ? (_ios ? _releaseInterstitialIos : _releaseInterstitialAndroid)
      : (_ios ? _testInterstitialIos : _testInterstitialAndroid);
}

/// Shows ads. The game only talks to this interface, so the ad network can be
/// swapped and tests can use [SimulatedAdService].
abstract class AdService {
  Future<void> init();

  /// True when a rewarded ad is loaded and can be shown immediately.
  bool get isReady;

  bool get interstitialReady;

  /// Shows a rewarded ad. Completes with `true` only if the player earned the
  /// reward (watched to the end).
  Future<bool> showRewarded();

  /// Shows an interstitial if one is loaded. Completes when it's closed.
  Future<void> showInterstitial();

  /// True if the player must be offered a "Privacy options" button
  /// (required by Google for players in regions with consent laws).
  Future<bool> privacyOptionsRequired();

  Future<void> showPrivacyOptions();

  static AdService create() {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return mobile ? AdMobService() : SimulatedAdService();
  }
}

/// Real ads through Google AdMob, including the Google consent form (UMP),
/// which is required for players in the EU/UK.
class AdMobService implements AdService {
  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  bool _loadingRewarded = false;
  bool _loadingInterstitial = false;
  bool _canRequestAds = false;
  int _retryRewarded = 0;
  int _retryInterstitial = 0;

  @override
  bool get isReady => _rewarded != null;

  @override
  bool get interstitialReady => _interstitial != null;

  @override
  Future<void> init() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) {
        if (!done.isCompleted) done.complete();
      }),
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (!_canRequestAds) return;
    await MobileAds.instance.initialize();
    _loadRewarded();
    _loadInterstitial();
  }

  // Back off after failures: 2s, 4s, 8s ... up to 64s.
  static Duration _backoff(int retry) =>
      Duration(seconds: 2 << retry.clamp(0, 5));

  void _loadRewarded() {
    if (_loadingRewarded || _rewarded != null || !_canRequestAds) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
          _retryRewarded = 0;
        },
        onAdFailedToLoad: (_) {
          _loadingRewarded = false;
          Timer(_backoff(_retryRewarded++), _loadRewarded);
        },
      ),
    );
  }

  void _loadInterstitial() {
    if (_loadingInterstitial || _interstitial != null || !_canRequestAds) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          _retryInterstitial = 0;
        },
        onAdFailedToLoad: (_) {
          _loadingInterstitial = false;
          Timer(_backoff(_retryInterstitial++), _loadInterstitial);
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
    _loadRewarded();
    _loadInterstitial();
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!result.isCompleted) result.complete(earned);
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!result.isCompleted) result.complete(false);
        _loadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return result.future;
  }

  @override
  Future<void> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
        _loadInterstitial();
      },
    );
    await ad.show();
    return closed.future;
  }
}

/// Stand-in used on web/desktop and in tests: waits briefly and grants the
/// reward, so every ad flow can be tried without a phone.
class SimulatedAdService implements AdService {
  SimulatedAdService({this.delay = const Duration(milliseconds: 1200)});

  final Duration delay;
  int rewardedShown = 0;
  int interstitialsShown = 0;

  @override
  bool get isReady => true;

  @override
  bool get interstitialReady => true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<bool> showRewarded() async {
    rewardedShown++;
    await Future<void>.delayed(delay);
    return true;
  }

  @override
  Future<void> showInterstitial() async {
    interstitialsShown++;
    await Future<void>.delayed(delay);
  }
}
