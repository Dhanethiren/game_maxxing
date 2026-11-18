# Design research for Calm Grid

This note covers what we learned from popular block-puzzle games and from
mobile-game research, and how each finding shaped the game. Most public sources
are developer statements or ad-network blogs rather than independent studies.
Treat the numbers as directional and verify them against our own data once the
game is live.

## 1. What makes the genre's hits work

**Findings**
- Block Blast is the genre leader, reported at around 70M daily players. Its
  studio describes the game as *"simple to learn, challenging to master"*. The
  screen is minimal: the board, three pieces, and the score. Praise messages
  such as "Perfect!" reinforce good moves. Players describe it as "relaxing"
  and "a perfect time killer".
  ([Global Games Forum](https://www.globalgamesforum.com/news/how-casual-games-build-global-audiences-the-block-blast-approach),
  [Pocket Gamer.biz](https://www.pocketgamer.biz/block-blast-reaches-70m-daily-active-users-and-300m-monthly-active-users-worldwide))
- The studio runs more than 50 A/B tests a week. Its piece dealer is a complex
  rule system that reacts to the board state.
  ([mobilegamer.biz](https://mobilegamer.biz/block-blast-maker-hungry-studio-a-b-tested-its-way-to-the-top-of-the-charts/))
- The genre usually uses an 8×8 or 10×10 board with three pieces at a time.
  Rows and columns clear. Combos reward clears on consecutive moves, and many
  games keep the streak alive across a non-clearing move.
  ([Woodoku](https://apps.apple.com/us/app/woodoku/id1496354836),
  [Blockudoku](https://apps.apple.com/us/app/-/id6760023546))
- A decompiled-build report says some games test when to deal an unplayable
  set of pieces so that a revive ad is most effective.
  ([The Star](https://www.thestar.com.my/tech/tech-news/2026/10/28/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out))

**What we built**
- Gameplay: an 8×8 board, three pieces, row and column clears, and the same
  clean board-plus-tray layout.
- Combos survive up to 2 non-clearing moves.
- Praise text grows with the size of the clear: Nice → Great! → Excellent! →
  Amazing! → Perfect Clear! (+300 bonus).
- A **fair dealer**. We deliberately do **not** deal deadly pieces to sell
  revives, because it contradicts a stress-relief game. Every set of pieces
  includes at least one that fits. When the board gets crowded, the dealer
  favours smaller pieces and pieces that finish a line.

## 2. What keeps players coming back

**Findings**
- Typical casual-puzzle retention is about D1 30–40%, D7 10–20% and D30
  3–7%. A big drop between D1 and D7 means the game lacks mid-term goals.
  ([Playio](https://blog.playio.co/retention-by-game-genre),
  [Segwise](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies))
- Daily login rewards that grow over a streak lift D7. Puzzle games often use
  a large "jackpot" reward to encourage daily visits.
  ([Supersonic](https://supersonic.com/learn/blog/6-ways-to-boost-your-games-retention-from-d1-d7/),
  [Naavik](https://naavik.co/digest/live-ops-trends-powering-mobile-puzzle/))
- Triggering daily rewards on later sessions rather than the very first one
  improved first-time experience in one developer's tests.
  ([Supersonic](https://supersonic.com/learn/blog/6-ways-to-boost-your-games-retention-from-d1-d7/))
- Hyper-casual games lose players without progression, so the trend is toward
  "hybrid-casual" games with meta goals.
  ([Segwise](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies))

**What we built**
- A **7-day login streak**: 20 → 30 → 40 → 60 → 80 → 100 → **250** coins. The
  reward can be doubled with an ad, and the pop-up only appears for returning
  players.
- **Daily goals**: 3 missions a day, such as "Clear 20 lines" or "Reach a ×3
  combo", which pay coins.
- **Levels and XP**: your score becomes XP, and each level-up pays coins.
- **Themes** to buy with coins, giving players a long-term goal.
- **Continue where you left off**: the game saves after every move, so closing
  the app never loses a run.
- A gentle first-game hint and no timers or penalties.

## 3. Earning from ads without driving players away

**Findings**
- **Rewarded ads**, which the player chooses to watch, are the
  retention-safe format. **Interstitials**, which are forced, cause the most
  churn.
  ([Unity](https://unity.com/blog/3-ways-to-optimize-the-ad-experience-for-your-users),
  [Playio](https://blog.playio.co/interstitial-ads-mobile-games))
- Common interstitial caps are 3–5 per session and at least 2–3 minutes apart,
  with no interstitial early in a session. Beyond the 5th or 6th impression,
  extra revenue shrinks while churn risk grows.
  ([Playio](https://blog.playio.co/interstitial-ads-mobile-games),
  [Airflux](https://airflux.ai/blog/mobile-game-interstitial-strategies))
- Delaying ads for new players is reported to lift D1 retention.
  ([RevenueFlex](https://revenueflex.com/blog/interstitial-ad-best-practices-mobile-games/))
- Don't show an interstitial before a "double your reward" offer: it blocks a
  higher-value rewarded ad.
  ([RevenueFlex](https://revenueflex.com/blog/interstitial-ad-best-practices-mobile-games/))
- Judge ad changes by long-term value per player with D7 retention as a
  guardrail, not by same-day revenue. Same-day revenue always favours more ads.
  ([Global Games Forum](https://www.globalgamesforum.com/news/why-early-arpu-is-one-of-the-most-misleading-metrics-in-puzzle-games-and-what-to-use-instead))

**What we built**
- Rewarded ads are the main source of income:
  - **revive** once per game,
  - **double coins** after a game,
  - **double the daily reward**,
  - **free coins** in the shop, up to 5 a day.
- Interstitials follow a strict policy in `lib/ads/ad_policy.dart`:
  - none in a player's first 3 games,
  - at most 1 every 3 games, at least 3 minutes apart and 4 per session,
  - none in the first 90 seconds of a session,
  - none within 3 minutes of a rewarded ad,
  - none right after a new best score.

  They only appear when the player leaves the game-over screen, after the
  double-coins offer.
- The on-device ML model (`lib/ml/offer_optimizer.dart`) learns how to word
  each rewarded offer for each player.
- No countdown timers on offers, and "No thanks" is always clear. This follows
  Google Play's policy against misleading ad prompts.

## 4. Visuals, animation and sound

**Findings**
- "Juicy" feedback makes a game feel satisfying:
  - a particle burst on line clears, tinted to the cleared blocks' colours,
  - text that pops in with a bounce,
  - a short screen shake (0.1–0.3 s) reserved for bigger moments such as
    clearing 2 or more lines.
  ([itch.io](https://itch.io/blog/1059831/making-a-game-feel-juicy-with-simple-effects),
  [Game Developer](https://gamedeveloper.com/design/squeezing-more-juice-out-of-your-game-design-))
- Bright, glossy blocks with crisp edges and clear contrast are the genre norm.
- Sound:
  - Vary the pitch of frequently repeated sounds (±7%) so they never feel
    cheap.
  - Raise the pitch as a combo builds, the classic "rising reward" cue.
  - Keep clear sounds short.
  ([Wayline](https://www.wayline.io/blog/game-loop-not-fun-sound-fixes),
  [itch.io](https://itch.io/blog/809496/how-one-sound-effect-made-my-puzzle-game-juicy))
- A 2024 EEG study found **pentatonic** tone sequences were rated more
  pleasant and relaxing, with increased alpha and theta brain waves. The study
  was small.
  ([Costa et al., Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC11056517/))

**What we built**
- **Glossy "jelly" blocks**: a soft top light, a bottom bevel and a highlight.
  Each block is drawn once per colour and cached, so low-end phones stay
  smooth.
- **Placing a piece**: a soft wooden "tock" in 3 slightly different pitches,
  a light haptic, and a small bounce as the block settles.
- **While dragging**: a ghost preview shows where the piece will land, and
  lines that would clear light up in the piece's colour before you drop.
- **Line clear**:
  - The blocks flash white, then shrink away in a wave spreading out from
    where you placed the piece.
  - Coloured particles burst out.
  - "+points" floats up.
  - The praise word pops in with an elastic bounce.
  - The board shakes gently on 2+ lines.
  - A medium haptic plays.
- **Clear sound**: a three-note C-major-pentatonic chime that climbs one scale
  step per combo level (8 levels), with an extra sparkle layer on 2+ lines.
- **Perfect clear**: a glissando up the scale into a held chord, a confetti
  burst and a heavy haptic.
- **Game over**: a soft descending phrase, never a harsh buzzer.
- **Music**: an optional 32-second seamless ambient loop of four soft
  pentatonic pad chords and sparse bells. It plays alongside the player's own
  music instead of pausing it.
- Every sound is synthesised from scratch by `tool/generate_sounds.py`, so
  everything is original and royalty-free.

## 5. Works on (almost) every phone

- **Android 7.0+** (API 24): Flutter's minimum, covering the vast majority of
  active devices. The APK includes 32-bit and 64-bit ARM, plus x86_64.
- **Every screen size**: layouts scale from 320×568 phones up to tablets.
  - Short screens get a compact home header.
  - Wide screens (tablets, foldables, landscape) put the pieces beside the
    board. Android 16 ignores portrait-only locks on large screens, so this
    matters.
  - Automated tests check 5 screen sizes for layout overflow.
- Large system font sizes are respected, but capped at 125% so the game still
  fits.
- Effects use capped particle counts and cached block images for low-end
  phones.
