# Calm Grid on the Apple App Store

Google Play is the main launch. This guide covers the second store: what is
already prepared in the project, how the App Store decides what to show, and
the steps only you can do (they need an Apple account and a Mac or a Mac
build service).

## 1. How the App Store ranks and recommends apps

Apple's own developer pages:

- **Search** combines **text relevance** (matches in the app's **name**,
  **subtitle**, **keywords** and **primary category**) with **user
  behaviour** (downloads, ratings and reviews, and more).
  ([App Store search](https://developer.apple.com/app-store/search/))
- **Keywords**: 100 characters, separated by commas without spaces. Don't
  repeat words already in the name or category: they are indexed anyway.
  No plurals of words you already have, and no generic filler.
  ([Tech Talk](https://developer.apple.com/videos/play/tech-talks/110358/))
- **Ratings** feed ranking and show in search results. The summary rating is
  per country or region.
- **App Store Tags** (2025) are generated from your metadata by language
  models and checked by people. They highlight what the app does, so clear,
  accurate descriptions matter.
  ([WWDC25: What's new in App Store Connect](https://developer.apple.com/videos/play/wwdc2025/328/))
- **The Apple Games app** (iOS 26) recommends games based on what people and
  their friends play. Games with **Game Center leaderboards** get **friend
  score notifications** and **challenges**: time-limited, score-based
  contests between friends. They are built on top of existing leaderboards,
  and the same score-submission call feeds both.
  ([Apple Games app](https://developer.apple.com/games-app/),
  [WWDC25: Game Center](https://developer.apple.com/videos/play/wwdc2025/214/))
- **Product page**: name, subtitle and the first screenshots appear in
  search results. Product Page Optimization lets you A/B test icons and
  screenshots; in-app events can appear in search but don't change your
  ranking against other apps.
  ([Product page](https://developer.apple.com/app-store/product-page/),
  [In-app events](https://developer.apple.com/videos/play/tech-talks/110347/))
- **Accessibility Nutrition Labels** (2025) show on the product page which
  accessibility features you support. Only declare features that really
  work. ([WWDC25](https://developer.apple.com/videos/play/wwdc2025/224/))
- **Age ratings** now have five tiers (4+, 9+, 13+, 16+, 18+). The
  questionnaire includes a declaration for **advertising**.
  ([Age ratings](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/))

## 2. Already prepared in the project

| Item | Where |
|---|---|
| iPhone + iPad app, iOS 15+, bundle ID `com.gamemaxxing.calmGrid` | `ios/Runner.xcodeproj` |
| App icons in every size, no alpha channel (Apple rejects alpha) | `ios/Runner/Assets.xcassets/AppIcon.appiconset` (`tool/generate_icons.py`) |
| Launch screen in the game's lavender, matching Android | `ios/Runner/Base.lproj/LaunchScreen.storyboard` |
| **11 languages** declared (`CFBundleLocalizations`), so the App Store lists them | `ios/Runner/Info.plist` |
| App Tracking Transparency text (`NSUserTrackingUsageDescription`) for the consent flow | `ios/Runner/Info.plist` |
| Export compliance: no non-exempt encryption (skips the question on every upload) | `ios/Runner/Info.plist` |
| AdMob test app ID and Google's own SKAdNetwork ID | `ios/Runner/Info.plist` |
| Sound mixes with the player's own music and respects the silent switch | `lib/audio/sound_service.dart` |
| Ratings use Apple's system prompt (SKStoreReviewController) with the same "happy moment" rules as Android | `lib/services/review_prompter.dart` |
| Name, subtitle, keywords and promotional text in 11 languages, within every limit | `store/listings/*.md` |
| Screenshots at the required sizes: iPhone 6.9″ (1320×2868) and iPad 13″ (2064×2752) | `store/screenshots_ios/` |

## 3. Your steps

1. **Join the Apple Developer Program** and create the app in App Store
   Connect with the bundle ID above. Copy the app's numeric **Apple ID**
   (App Information) into `ReviewService.appStoreId` in
   `lib/services/review_prompter.dart`. Until then the "Rate Calm Grid"
   button is hidden on iOS.
2. **AdMob**: add an iOS app and two ad units (Rewarded, Interstitial).
   - Put the iOS **app ID** in `ios/Runner/Info.plist`
     (`GADApplicationIdentifier`).
   - Put the iOS **ad unit IDs** in `lib/ads/ad_service.dart`
     (`_releaseRewardedIos`, `_releaseInterstitialIos`).
   - **SKAdNetwork IDs**: Info.plist has Google's own ID. Add the full
     third-party buyer list from Google's page,
     <https://developers.google.com/admob/ios/3p-skadnetworks>. It
     couldn't be fetched from this build environment, and without it
     fewer advertisers bid on iOS.
   - In **Privacy & messaging**, create the GDPR message and an **IDFA
     explainer** (the App Tracking Transparency message). The game already
     shows whatever you configure there.
3. **App Privacy** (App Store Connect): declare the data the Google Mobile
   Ads SDK collects (device ID, product interaction, advertising data,
   coarse location, diagnostics), following Google's App Store data
   disclosure guide. The game itself sends nothing anywhere.
4. **Age rating**: answer the questionnaire honestly. Declare advertising.
   Set AdMob's maximum ad content rating to match the rating you get.
5. **Listings**: for each language in `store/listings/`, paste the name,
   subtitle, keywords, promotional text and description. Upload the
   screenshots from `store/screenshots_ios/`.
6. **Build and upload** on a Mac (or a hosted macOS build service):
   ```bash
   flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
   ```
   Then upload `build/ios/ipa/*.ipa` with Transporter or Xcode. Test with
   TestFlight first.
7. **Strongly recommended after launch: Game Center.** Add a "Best score"
   leaderboard plus the 15 achievements (their IDs are in
   `lib/services/achievements.dart`). This gets Calm Grid into the Apple
   Games app's friend notifications and challenges. The same IDs map to
   Google Play Games Services on Android, so one integration covers both
   stores.

## 4. Release checklist

```bash
python3 tool/preflight.py
```

The preflight also lists the iOS items that are still placeholders.
