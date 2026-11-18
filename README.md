# Calm Grid

A calm, no-timer block puzzle made to help people unwind. Drag pieces onto an
8×8 grid and fill rows or columns to clear them. There's no clock and no
pressure, just soft colours and gentle feedback.

Monetised with **opt-in rewarded ads**. After a loss the player can watch a
short ad to revive once. A small **on-device ML model** learns how best to
present that offer to each player.

Built with Flutter (Android + iOS).

## Project layout

```
lib/
  main.dart                  app entry
  game/                      rules: pieces, board, scoring (no UI, fully tested)
  ml/offer_optimizer.dart    on-device contextual bandit (LinUCB)
  ads/ad_service.dart        AdMob rewarded ads + Google consent form (UMP)
  services/                  player profile storage, glue between game/ML/ads
  ui/                        game screen, revive dialog, theme
test/                        unit + widget tests
```

## How the ad-offer ML works

`lib/ml/offer_optimizer.dart` is a **contextual bandit** (LinUCB). It runs
entirely on the phone and needs no server or training step.

* **Context:** at each game-over it looks at 9 signals. These are how close the
  score is to the player's best, time spent in the game, games played this
  session, ads already watched (fatigue), time since the last ad, the player's
  past accept rate, and how full the board is.
* **Actions:** it chooses one of three ways to present the offer:
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

## Before publishing to Google Play: checklist

1. **AdMob account**
   * Create the app and a *Rewarded* ad unit at <https://apps.admob.com>.
   * Put the IDs in `lib/ads/ad_service.dart` (`_releaseRewarded…`).
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
