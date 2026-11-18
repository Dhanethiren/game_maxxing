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
  - an on-device ML model that learns how to present each offer.
- **Every screen**: from 320×568 phones to tablets, in portrait and landscape,
  on Android 7.0+.

Every design decision is based on famous casual games (Block Blast, Royal
Match, Candy Crush, Woodoku, Tetris and Subway Surfers). The details, with
sources, are in [docs/RESEARCH.md](docs/RESEARCH.md).

Built with Flutter (Android + iOS).

## Project layout

```
lib/
  main.dart                  app start-up, error reporting
  app/app_scope.dart         shared services (profile, ads, sound), screen scaling
  game/                      rules: pieces, board, scoring, fair dealer, Journey levels
  ml/offer_optimizer.dart    on-device contextual bandit (LinUCB)
  ads/ad_service.dart        AdMob rewarded + interstitial ads, consent form (UMP)
  ads/ad_policy.dart         when an interstitial may appear
  audio/sound_service.dart   sound effects and music
  services/                  player profile, progression (levels, streaks, missions)
  ui/                        home, game, Journey map, spin wheel, themes, dialogs, effects
assets/sounds/               generated sound effects and music
tool/generate_sounds.py      synthesises every sound from scratch (numpy)
tool/generate_icons.py       draws the app icon and store graphics (Pillow)
tool/preflight.py            release checklist: run before every Play upload
store/                       Play Store icon, feature graphic and screenshots
docs/PLAY_STORE.md           policy audit, launch steps, form answers, listing text
test/                        unit and widget tests (5 screen sizes)
```

## How the ad-offer ML works

`lib/ml/offer_optimizer.dart` is a **contextual bandit** (LinUCB). It runs
entirely on the phone and needs no server or training step.

* **Context:** at each game-over it looks at 9 signals. These are how close the
  score is to the player's best, time spent in the game, games played this
  session, ads already watched (fatigue), time since the last ad, the player's
  past accept rate, and how full the board is.
* **Placements:** revive, double coins, double daily reward and extra spin. Each one has
  its own learned weights.
* **Actions:** it chooses one of three ways to present the offer. For revive
  these are:
  * `quick`: "Continue?"
  * `progress`: "You're 92% of the way to your best"
  * `calm`: appears after a short pause with "Take a breath…"
* **Learning:** each tap on *Watch ad* (1) or *No thanks* (0) updates that
  variant's model. It mostly picks the variant predicted to be accepted, and
  sometimes tries the others to keep learning. The learned weights are saved on
  the device.
* **Guardrails:**
  * Revive is offered at most once per game.
  * There's no countdown timer, and *No thanks* is always visible.
  * Future optional offers use `shouldOffer()`, which caps them at 4 per session
    with at least 90 s between them.

  Annoying players costs more in uninstalls than one ad earns.

**Debug view:** in a debug build, long-press **BEST** to see each variant's
accept count.

### Adding another reward later

1. Add a value to `OfferPlacement` in `lib/ml/offer_optimizer.dart`.
   It already has `revive`, `doubleCoins`, `dailyBonus` and `extraSpin`.
2. Where the offer should appear, call `offers.optimizer.shouldOffer(...)`. If
   it returns true, call `optimizer.choose(...)`, show your button, then call
   `offers.recordAnswer(...)` and `offers.watchAd()`.

Good candidates are reroll pieces, undo, and doubling the daily bonus.

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

To change the sounds, edit `tool/generate_sounds.py` and run it. It needs
numpy.

```bash
python3 tool/generate_sounds.py
```

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
4. **Build** the bundle you upload to Play Console:
   ```bash
   flutter build appbundle --release
   ```
   The output is `build/app/outputs/bundle/release/app-release.aab`.
5. **App icon:** replace the default Flutter icon, for example with the
   `flutter_launcher_icons` package.
6. **Play Console forms:**
   * *Ads:* yes, contains ads.
   * *Target audience:* 13+, not designed for children.
   * *Data safety:* AdMob collects the device advertising ID and approximate
     location for ads. The game's own ML data never leaves the device.
   * *Privacy policy:* host `PRIVACY.md` somewhere public, such as GitHub Pages,
     and paste the link.
7. **Store listing:** you can say "relaxing" or "calming", but avoid medical
   claims like "treats anxiety" or "reduces stress clinically". Google rejects
   unproven health claims.
8. **Testing track:** new personal developer accounts must run a closed test
   with at least 12 testers for 14 days before going to production.
