# Calm Grid

A calm, no-timer block puzzle made to help people unwind. Drag pieces onto an
8×8 grid and fill rows or columns to clear them.

**Features**
- **Two modes**:
  - **Classic**: endless, chase your best score.
  - **Journey**: levels with score or gem goals, pre-built boards, 1–3 stars
    and a win-streak bonus.
- **Home screen**: Classic and Journey buttons, best score, level, coins, the
  daily reward, the daily spin and today's goals.
- **Satisfying clears**: glossy blocks, a ghost preview while dragging, a
  clear wave, particles, praise text, a gentle screen shake, haptics, and
  pentatonic chimes that climb with each combo.
- **Reasons to come back**:
  - a 7-day login streak,
  - a daily spin wheel,
  - 3 daily goals,
  - levels and XP,
  - coins and 6 unlockable colour themes,
  - auto-saving after every move.
- **Ads**:
  - opt-in rewarded ads for revive, double coins, double daily reward, an
    extra spin and free coins,
  - rare, strictly capped interstitials,
  - every offer is optional, says what it gives, and adapts to the player on
    the device.
- **Every screen**: from 320×568 phones to tablets, in portrait and landscape,
  on Android 7.0+.

Every design decision is based on famous casual games (Block Blast, Royal
Match, Candy Crush, Woodoku, Tetris and Subway Surfers). The details, with
sources, are in [docs/RESEARCH.md](docs/RESEARCH.md).

Built with Flutter (Android + iOS), in 11 languages: English, Spanish,
Portuguese (Brazil), French, German, Italian, Russian, Turkish, Indonesian,
Japanese and Korean. To change a text, edit `lib/l10n/app_en.arb` and the
same key in the other `app_<language>.arb` files; `flutter pub get`
regenerates the code. `flutter test` checks that every language has every
text and that every screen fits on a small phone in every language.

## Project layout

```
lib/
  main.dart                  app start-up, error reporting
  app/app_scope.dart         shared services (profile, ads, sound), screen scaling
  game/                      rules: pieces, board, scoring, fair dealer, Journey levels
  ads/ad_service.dart        AdMob rewarded + interstitial ads, consent form (UMP)
  ads/ad_policy.dart         when an interstitial may appear
  audio/sound_service.dart   sound effects and music
  services/                  player profile, progression (levels, streaks, missions), reward offers
  ui/                        home, game, Journey map, spin wheel, themes, dialogs, effects
  l10n/                      translations: app_<language>.arb (11 languages) + helpers
assets/sounds/               generated sound effects and music
tool/sound/                  sound engine + sounds.config.js, renderer, checker, Sound Studio page
tool/generate_icons.py       draws the app icon and store graphics (Pillow)
tool/preflight.py            release checklist: run before every Play upload
store/                       Play Store icon, feature graphic and screenshots
docs/PLAY_STORE.md           policy audit, launch steps, form answers, legal risk
docs/PLAY_DISCOVERY.md       how Play ranks and recommends apps, and what we changed
docs/APP_STORE.md            App Store launch: what's prepared, ranking, your steps
store/listings/              store text in 11 languages (tool/listings.py checks limits)
store/screenshots_ios/       App Store screenshots: iPhone 6.9" and iPad 13"
docs/SOUNDS.md               every sound file and exactly when it plays
test/                        unit and widget tests (5 screen sizes)
```

## Adding another reward offer

1. Add a value to `OfferPlacement` in `lib/services/reward_offers.dart`.
2. Where the offer appears, call `offers.decide(...)`, word your button with
   the chosen `variant`, then call `offers.recordAnswer(...)` and
   `offers.watchAd()`.

Keep every offer optional, say what it gives before the ad plays, and give
it a visible "No thanks". Good candidates are reroll pieces and undo.

## Develop

```bash
flutter pub get
```

```bash
flutter test
```

```bash
flutter run
```

On web and desktop the ads are simulated. On a phone they're real **test** ads.

To change the sounds, use the **Sound Studio** page: listen, move the
sliders, then press *Save for Claude*. Or save your settings as JSON and
render them yourself (needs Node.js):

```bash
node tool/sound/render.js --settings my-settings.json
```

This writes `assets/sounds/*.wav` plus `assets/sounds/mix.json` (in-game
volumes). See [docs/SOUNDS.md](docs/SOUNDS.md).

## Before publishing to Google Play: checklist

The full policy audit and step-by-step launch guide is in
[docs/PLAY_STORE.md](docs/PLAY_STORE.md). Before every upload, run:

```bash
python3 tool/preflight.py
```

1. **AdMob account**
   * Create the app and two ad units, *Rewarded* and *Interstitial*, at
     <https://apps.admob.com>.
   * Put the IDs in `lib/ads/ad_service.dart` (`_releaseRewarded…` and
     `_releaseInterstitial…`).
   * To ship with rewarded ads only, set `enabled: false` in
     `InterstitialPolicy` (`lib/ads/ad_policy.dart`).
   * Put the app ID in `android/app/src/main/AndroidManifest.xml` and
     `ios/Runner/Info.plist`.
   * Create a GDPR consent message in AdMob → *Privacy & messaging*. The code
     already shows it.
   * Never tap your own live ads. Add your phone as a test device.
2. **Package name:** `com.gamemaxxing.calm_grid` (in
   `android/app/build.gradle.kts`). It can't be changed after the first upload,
   so change it now if you want a different one.
3. **Upload key:** create it once and keep it safe. If you lose it, you can't
   update the app.
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Then create `android/key.properties`. It's git-ignored; never commit it.
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```
4. **Build** the bundle you upload to Play Console. Obfuscation renames the
   game's code inside the app so it's hard to read if someone unpacks it:
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
   ```
   The output is `build/app/outputs/bundle/release/app-release.aab`. Keep a
   copy of `build/debug-info` for every release: `flutter symbolize` needs
   it to turn crash reports back into readable stack traces.
5. **App icon:** already drawn by `tool/generate_icons.py` (adaptive icon
   plus the 512 px store icon).
6. **Play Console forms:**
   * *Ads:* yes, contains ads.
   * *Target audience:* 13+, not designed for children.
   * *Data safety:* AdMob collects the device advertising ID and approximate
     location for ads. The game's own data (progress, settings, offer
     preferences) never leaves the device.
   * *Privacy policy:* host `PRIVACY.md` somewhere public, such as GitHub Pages,
     and paste the link.
7. **Store listing:** you can say "relaxing" or "calming", but avoid medical
   claims like "treats anxiety" or "reduces stress clinically". Google rejects
   unproven health claims.
8. **Testing track:** new personal developer accounts must run a closed test
   with at least 12 testers for 14 days before going to production.
