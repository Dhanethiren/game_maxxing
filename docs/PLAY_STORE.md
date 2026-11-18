# Google Play launch guide and policy audit

The status below reflects the app at version 1.3.0+3003, checked on 18 Nov
2026. Run `python3 tool/preflight.py` before every upload. It checks the
blocking items automatically.

## 1. Status at a glance

### Done in the app

- Targets **Android 16 (API 36)**. This is Play's current requirement for new
  apps and updates.
- All native libraries are **16 KB page-size aligned**. This is required for
  apps targeting Android 15+, and the preflight check verifies it.
- Release builds are **App Bundles (.aab)**, are not debuggable, and are
  universal across 32- and 64-bit ARM and x86_64.
- **Only normal permissions.** These come from the ads SDK: internet, network
  state, advertising ID, wake lock and a foreground service without a
  special type. There are no sensitive or runtime permissions, so no
  permission declarations are needed.
- **Google-certified consent (UMP)** for the EEA, UK and Switzerland, plus an
  in-app *Privacy options* button when Google requires one.
- **Ads follow AdMob placement rules**:
  - Every rewarded offer is opt-in and says *before* the ad plays that an ad
    will play and what you get.
  - A random reward (the extra spin) says it is random: "10 to 200 coins".
  - Interstitials only appear between games. Never at launch or exit, never
    on every tap, and always preloaded.
- **Real app icon**: adaptive icon, Android 13 themed icon, all iOS sizes,
  and a lavender launch screen.
- **Store graphics**: a 512 px icon, a 1024×500 feature graphic and five
  1080×1920 screenshots in `store/`.
- **Large screens and Android 16**: tablet and landscape layouts. Android 16
  ignores portrait locks on large screens, and the game handles that.
- **Edge-to-edge** (enforced on Android 15+): all screens use safe areas.
- **Predictive back**: the back gesture opens the pause menu instead of
  quitting mid-game.
- **No fake urgency**: no countdown timers on offers, and "No thanks" is
  always visible.
- **Fair play**: the piece dealer never deals a deliberately unplayable set to
  sell revives.

### Only you can do these (blocking)

| # | Item | Why it blocks |
|---|---|---|
| 1 | **Create an upload key** and `android/key.properties` (README step 3). | Play rejects bundles signed with the debug key. If you lose this key, you can never update the app. Back it up. |
| 2 | **AdMob**: create the app plus a *Rewarded* and an *Interstitial* ad unit. Put the IDs in `AndroidManifest.xml` and `lib/ads/ad_service.dart`. | The app ships with Google's **test** IDs, which earn nothing. |
| 3 | **Privacy policy**: fill in `PRIVACY.md` (name, email, date) and host it at a public URL. | Play requires a privacy policy for any app with ads or that uses the advertising ID. |
| 4 | **Developer website with `app-ads.txt`** at the domain root. | AdMob is making app-ads.txt verification mandatory. Unverified apps can get limited ad serving. A GitHub *user* site (`yourname.github.io`) works; a project page does not, because it isn't at the domain root. |
| 5 | **Closed test: 12 testers for 14 days in a row.** | Required for personal developer accounts created after 13 Nov 2023 before you can apply for production. |

## 2. Policy audit

| Policy | Status | Evidence / action |
|---|---|---|
| Target API level (new apps: API 36) | ✅ | `targetSdkVersion 36` in the built APK. |
| 16 KB memory page support | ✅ | `tool/preflight.py` reads every 64-bit `.so`. Alignments are 16 KB or 64 KB. |
| App signing | ❌ you | Needs your upload key (blocking #1). Enrol in Play App Signing when you create the app. |
| Developer identity verification | ✅/you | Play Console verifies your identity at account setup. Android-wide verification starts 30 Sep 2026 in 4 countries and expands in 2027. Play apps are registered automatically. |
| User Data policy / privacy policy | ❌ you | `PRIVACY.md` is drafted; fill it in and host it (blocking #3). It must be linked in Play Console. |
| Data safety form | Form to fill | Suggested answers in section 4. |
| Advertising ID declaration | Form to fill | Answer **Yes**, for **Advertising or marketing**, **Analytics** and **Fraud prevention, security and compliance**. |
| Ads policy: disruptive ads | ✅ | Interstitials are capped (first 3 games ad-free, 1 every 3 games, 3 minutes apart, 4 per session) and only shown between games. |
| AdMob rewarded disclosure | ✅ (fixed now) | Every rewarded button names the ad and the reward, e.g. "Watch ad: ×2 coins", "Watch ad & spin" with "Prize is random: 10 to 200 coins". |
| AdMob interstitial placement | ✅ | Never on app launch or exit, never on every tap, always preloaded. |
| GDPR/UK consent (Google-certified CMP) | ✅ code / you | UMP is built in. **Create the GDPR message in AdMob → Privacy & messaging**, or no form shows. |
| Families policy | ✅ | Target audience is 13+. No characters or kid-styled marketing. Keep the store creative calm and abstract, as it is now. |
| Simulated gambling / loot boxes | ✅ | The daily spin costs nothing (free or rewarded ad) and pays only in-game coins. If you ever **sell** spins or random items, you must show the odds before purchase. |
| Misleading claims / health | ⚠️ | Say "relaxing" and "calming". **Don't** claim it "reduces stress or anxiety" or treats anything. Unproven health claims break the Misleading Claims policy. |
| Intellectual property | ⚠️ you | The game code, art and sounds are original. **Check the name** "Calm Grid": "Calm" is a well-known registered brand in the relaxation-app space. Search USPTO/EUIPO and Play before launch. Renaming later loses ratings and search position. |
| Metadata policy | ✅ | The listing text below has no rankings, prices, "#1" claims or keyword stuffing. |
| Account deletion | n/a | There are no accounts. |
| Permissions | ✅ | No sensitive or runtime permissions. |

## 3. Step-by-step launch path

1. **Play Console account** ($25 one-time). Choose a *personal* or
   *organisation* account. Organisations need a D-U-N-S number but skip the
   12-tester rule.
2. **AdMob account**:
   - Add the app as "not yet published" and create both ad units.
   - Set up the **GDPR** message, and optionally the **US states** message.
   - Put the IDs into the code (blocking #2).
3. **Website + app-ads.txt**: publish the line AdMob gives you at
   `https://<your-domain>/app-ads.txt`. Add the same site as the *Website* in
   your Play listing.
4. **Privacy policy**: fill in `PRIVACY.md` and publish it on the same site,
   for example `https://<your-domain>/privacy`.
5. **Upload key**: follow the README, then build:
   ```bash
   flutter build appbundle --release
   ```
   Then run:
   ```bash
   python3 tool/preflight.py
   ```
   All checks should pass.
6. **Create the app** in Play Console: Game, Free, category **Puzzle**.
7. **App content** forms (section 4), the **store listing** (section 5) and
   graphics from `store/`.
8. **Internal testing**: upload the `.aab` and install it on your phone from
   the Play link. Check ads (test devices), sound and the consent form.
9. **Closed testing**: 12+ testers who really play for 14 days. Collect
   feedback and fix issues.
10. **Apply for production access**. Answer the questionnaire about your
    testing honestly. Google reviews it.
11. **Production**: a staged rollout (for example 20% → 100%). Watch Android
    vitals (crashes and ANRs) and reviews.

## 4. Suggested App content answers

> You are legally responsible for these answers. Verify them against Google's
> current AdMob disclosure page for the SDK version you ship:
> https://developers.google.com/admob/android/privacy/play-data-disclosure

- **Ads**: Yes, the app contains ads.
- **App access**: All functionality is available without special access.
- **Target audience**: 13–15, 16–17 and 18+. Do not select under-13 groups.
- **Content rating (IARC)**:
  - Category: Game.
  - No violence, sexual content, language, drugs or gambling. The daily
    wheel is not simulated gambling: there is no wager and no casino game.
  - Users can't interact with each other.
  - No digital purchases (yet).
  - Expected result: Everyone / PEGI 3.
- **Advertising ID**: Yes, for advertising or marketing, analytics, and fraud
  prevention.
- **Data safety**:
  - *Does your app collect or share user data?* **Yes**, through the Google
    Mobile Ads SDK.
  - *Encrypted in transit?* **Yes**.
  - *Way to request deletion?* No user accounts. Ad data is controlled by the
    user's device ad settings.
  - Data types, as listed by Google for the Ads SDK:

    | Category | Data type |
    |---|---|
    | Location | **Approximate location** (from IP address) |
    | App activity | **App interactions** |
    | App info and performance | **Diagnostics** |
    | Device or other IDs | **Device or other IDs** |

    Purposes: **Advertising or marketing**, **Analytics**, and **Fraud
    prevention, security and compliance**.
  - The game's own data (scores, coins, settings, the offer model) never
    leaves the phone. Data processed only on the device doesn't count as
    "collected".
- **Health apps**: No health features. **News**, **Government**,
  **Financial features**: No.

## 5. Store listing text

The current, discovery-optimised title, descriptions, tags and graphics list
are in **[PLAY_DISCOVERY.md, section 5](PLAY_DISCOVERY.md#5-store-listing-text-updated)**.

Graphics:
- icon: `store/icon-512.png`
- feature graphic: `store/feature-graphic.png`
- phone screenshots: `store/screenshots/`
- tablet screenshots (portrait and landscape): `store/screenshots_tablet/`

## 6. If you also want the Apple App Store (iPhone)

The Flutter code already builds for iOS, but Apple has its own requirements:
- **Apple Developer Program** ($99 a year).
- **A Mac with Xcode** to build and upload. This can't be done in this Linux
  cloud workspace; a macOS CI service can do it instead.
- **App Tracking Transparency**: add `NSUserTrackingUsageDescription` to
  `Info.plist` and show the ATT prompt (UMP can show Google's IDFA explainer
  first). *Not implemented yet.* Personalised ads on iOS need it.
- **SKAdNetwork IDs**: add Google's full recommended list to `Info.plist`.
  Only Google's own ID is there now.
- **Privacy manifest**: check Xcode's privacy report. Flutter and the plugins
  include their own manifests; add `PrivacyInfo.xcprivacy` if Xcode reports
  missing required-reason APIs.
- **App Privacy labels** in App Store Connect, the iOS equivalent of Data
  safety.
- **A separate AdMob app and ad units** for iOS.
- **Screenshots**: 6.9" iPhone (for example 1320×2868), plus 13" iPad if you
  support iPad.

## 7. Recommended improvements (with reasons)

Ordered by impact. **P0** = do before launch, **P1** = soon after,
**P2** = when you can.

| P | Improvement | Why |
|---|---|---|
| P0 | **Trademark check / possible rename** | "Calm" is a strong brand in relaxation apps. An IP complaint can pull the listing, and renaming after launch throws away reviews and search ranking. It's free to fix now. |
| P0 | **Crash reporting (Firebase Crashlytics)** | The first build failed to launch on your phone and we could only debug blind. Play lowers the visibility of apps with high crash or ANR rates (Android vitals), so you need to see crashes from real devices. Update Data safety when you add it. |
| P0 | **Real-device testing on 2–3 cheap phones**, plus Play's pre-launch report | Everything so far was tested in a browser and the test renderer. Low-end GPUs, audio latency and ad SDK behaviour can only be checked on hardware. |
| P1 | **Analytics + Remote Config** (Firebase) | Ad limits, rewards and difficulty are informed guesses. You need D1/D7 retention and ad-engagement numbers to tune them, and Remote Config lets you change limits without an app update. |
| P1 | **"Remove ads" one-time purchase** (Play Billing) | Woodoku's reviews complain there's no way to remove ads, and players who hate ads will pay. Keep rewarded ads available as an optional choice. |
| P1 | **In-app review prompt** after a happy moment (new best, Journey level 10) | Ratings drive store ranking and conversion. Google's In-App Review API is the allowed way to ask. |
| P1 | **Localisation** (store listing first, then UI) | Block Blast's audience is global. A translated listing lifts installs in each market; start with es, pt-BR, id, hi, de, fr, ja. |
| P2 | **Colour-blind support** (a small symbol per block colour, or a high-contrast theme) | Several block colours are close in brightness. About 1 in 12 men has colour-vision deficiency. |
| P2 | **Smaller download**: compress sound effects (OGG/Opus on Android) | Sounds are 4.9 MB of WAV. Each player downloads about 20 MB thanks to App Bundle splits, and smaller still converts better on slow or expensive data. |
| P2 | **Hide the on-screen error panel in release** once Crashlytics is in | It was added to diagnose the launch failure. Real players shouldn't see technical text. |
| P2 | **Odds screen for the daily spin** (an "i" button showing each prize's chance) | Not required while spins are free, but it builds trust, and it becomes mandatory if spins are ever sold. |
| P2 | **Tablet screenshots** | Improves the large-screen listing, where Play now promotes optimised apps. |

## 8. Could Block Blast's maker take legal action?

*This is research, not legal advice. For certainty before you spend money on
marketing, ask an IP lawyer.*

**Anyone can file a complaint. The real question is whether it would hold
up.** Here is how the law has treated cases like this:

| Case | What happened | What it means for us |
|---|---|---|
| *Tetris Holding v. Xio* (US, 2012) | A clone lost. Game **rules and mechanics are not protected**, but the specific *look* (piece styling, board appearance, overall visual expression) is. Xio copied it wholesale. | Using the same *kind* of game (grid, pieces, line clears) is fine. Copying how another game *looks* is not. |
| *Spry Fox v. 6waves* (US, 2012, settled) | The court said nobody owns the idea of the game, but very similar art and style could be infringement. | The same lesson: ideas are free, expression is protected. |
| **Aretis (Hungry Studio, Block Blast) v. Oakever Games** (N.D. Cal., filed May 2025, Hungry Studio won in April 2026) | The complaint was about QBlock using "essentially the same **artwork and design interface**" and **sound effects** as Block Blast. It was **not** about the rules. Oakever lost and rebranded. | Block Blast's maker *does* sue copycats, so take this seriously. They went after **art, UI and audio**. |

**Where Calm Grid stands today**

| Area | Status |
|---|---|
| Mechanics: 8×8 grid, 3 pieces, row/column clears | Shared by the whole genre (1010!, Woodoku, Blockudoku, Block Blast) and not protectable. |
| Name, logo, icon | Original. "Calm Grid" has nothing in common with "Block Blast" (but see the separate "Calm" trademark note in section 2). |
| Art | Original and generated by our own code. Block Blast uses saturated blocks on a dark navy board; ours are soft hand-textured pastel tiles in a raised light frame. |
| Interface | Our own layout and styling: light theme, our buttons, our home screen. |
| Sounds and music | 100% synthesised from scratch by `tool/generate_sounds.py`. None of their audio. |
| Code | Written for this project. |
| Modes | The *idea* of a level mode is generic. Our Journey uses generated symmetric boards and gem goals, not Block Blast's jigsaw-picture levels. |

**Risk: low**, provided you keep it that way:
1. **Never use "Block Blast"** (or "Blast") in the app name, store listing,
   keywords, ads, screenshots or icon.
2. **Don't move the look towards theirs**: no dark-navy board with neon
   blocks, no copied screens, praise animations or sounds from their game.
3. **Keep the git history**: it shows independent creation, and the
   asset-generator scripts prove the art and sounds are original.
4. **Make the GitHub repository private** before launch. The internal research
   notes name competitor games; that's normal design research, but no need to
   publish it.
5. **Be ready for a takedown notice**: Play acts on DMCA complaints even when
   they're weak (Block Blast itself was briefly removed after one). You can
   file a counter-notice with the evidence above.

Sources:
- [Tetris v. Xio summary (Loeb & Loeb)](https://www.loeb.com/en/insights/publications/2012/06/tetris-holding-llc-v-xio-interactive-inc)
- [Spry Fox v. 6waves (MCV)](https://mcvuk.com/development-news/court-denies-motion-to-dismiss-spry-fox-vs-6waves)
- [Aretis v. Oakever (Justia docket)](https://dockets.justia.com/docket/california/candce/3:2025cv04570/450329)
- [Oakever cloning accusations (mobilegamer.biz)](https://mobilegamer.biz/vita-mahjong-amaze-go-and-meowdoku-maker-oakever-games-fights-cloning-accusations/)
- [Block Blast removed from Google Play (Gamigion)](https://www.gamigion.com/the-worlds-biggest-mobile-puzzle-game-block-blast-removed-from-google-play/)

## Sources

- Target API: https://developer.android.com/google/play/requirements/target-sdk
- 16 KB pages: https://developer.android.com/guide/practices/page-sizes
- Closed-testing rule: https://support.google.com/googleplay/android-developer/answer/14151465
- Developer verification: https://android-developers.googleblog.com/2026/06/android-developer-verification.html
- AdMob Data safety disclosure: https://developers.google.com/admob/android/privacy/play-data-disclosure
- AdMob rewarded ads policy: https://support.google.com/admob/answer/7313578
- AdMob interstitial guidance: https://support.google.com/admob/answer/6066980
- app-ads.txt: https://support.google.com/admob/answer/9363762
- Store graphics: https://support.google.com/googleplay/android-developer/answer/9866151
- Families / target audience: https://support.google.com/googleplay/android-developer/answer/9867159
- iOS IDFA/ATT with AdMob: https://developers.google.com/admob/flutter/privacy/idfa
