# Design research: lessons from famous casual games

The design of Calm Grid is based **only on famous, chart-topping casual
games**. Each lesson below names the game it comes from and how we applied it.
Wherever possible the sources are the games' own store listings, developer
statements, or major trade press covering those games.

| Game | Why it counts |
|---|---|
| **Block Blast!** (Hungry Studio) | Most downloaded game of 2025 (about 356M installs, AppMagic). The closest relative to Calm Grid. |
| **Royal Match** (Dream Games) | Top-grossing mobile game of 2025 (about $1.37B, AppMagic). |
| **Candy Crush Saga** (King) | The longest-running top-grossing casual puzzle game. |
| **Woodoku** (Tripledot) | One of the most popular "calm" block puzzles. |
| **Tetris** | The original line-clearing game, with an official scoring guideline. |
| **Subway Surfers** (SYBO) | The classic example of rewarded ads in a casual game. |

Sources for the rankings: [Pocket Gamer.biz](https://www.pocketgamer.biz/the-most-downloaded-mobile-games-of-2025),
[AppMagic via Mobidictum](https://mobidictum.com/?p=210271).

## 1. Core game

| Lesson | From | What we built |
|---|---|---|
| Classic block-puzzle format: place pieces on an **8×8 board**, clear rows or columns. Plus an **endless high-score hunt**. | Block Blast App Store listing ([link](https://apps.apple.com/us/app/block-blast/id1617391485)) | 8×8 board, three pieces at a time, endless **Classic** mode chasing your best. |
| "No rush… play at your own pace". **No pressure or time limit.** Playable offline. | Block Blast listing; Woodoku listing ([link](https://apps.apple.com/us/app/woodoku-wood-block-puzzles/id1496354836)) | No timers anywhere. The game works offline; only ads need a connection. |
| **Combo points** for multi-line clears and **streak points** for clearing on consecutive turns. | Woodoku listing | Multi-line clears score more. A combo streak survives 2 non-clearing moves. |
| Bigger clears are worth much more: the 4-line "Tetris" pays 800 vs 100 for a single. | Tetris Guideline ([Tetris Wiki](https://tetris.wiki/Line_clear)) | Clearing *n* lines pays 10·n(n+1)/2 points (10, 30, 60, 100…), multiplied by the combo. Clearing the whole board adds +300. |
| Players accuse Block Blast's Adventure levels of unfair piece dealing, and say Classic feels fairer. A decompiled build suggests Block Blast tests when to deal deadly pieces to sell revive ads. | Block Blast App Store reviews ([link](https://apps.apple.com/us/app/block-blast/id1617391485)); [The Star](https://www.thestar.com.my/tech/tech-news/2026/10/28/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out) | A **fair dealer**: every new set of pieces includes one that fits. It never deals a deadly set on purpose, and on crowded boards it leans toward helpful pieces. |

## 2. Modes and progression (why players come back)

| Lesson | From | What we built |
|---|---|---|
| Next to Classic, **Adventure Mode** has "progressive levels, unique jigsaw designs and colourful themes". Some levels need a target score, others **diamonds**. | Block Blast listing | **Journey mode**: endless levels with pre-built, symmetric boards. Levels alternate between **score goals** and **gem goals** (clear the blocks holding gems), and get gradually harder. |
| **Level maps** keep players moving forward. | Candy Crush Saga, Royal Match; Woodoku's "weekly journeys" ([Tripledot](https://tripledotstudios.com/page/2)) | A winding **Journey map** with 1–3 **stars** per level, based on how many moves you took. |
| A **win streak** pays more for each consecutive win and resets when you fail. Candy Crush's version is an "endless reward track". | Royal Match's Butler's Gift ([Naavik](https://naavik.co/digest/royal-match-finding-success-through-iteration/)); Candy Crush ([Deconstructor of Fun](https://www.deconstructoroffun.com/blog/2024/8/5/win-streak-the-gift-that-keeps-on-giving)) | A **Journey win streak** adds +25% coins per consecutive win, up to +100%. Losing a level resets it. |
| "Check back daily and spin the **Daily Booster Wheel**." | Candy Crush App Store listing ([link](https://apps.apple.com/app/553834731)) | A **Daily Spin** wheel for up to 200 coins, plus one extra spin per day for an ad. |
| A **daily check-in streak** with growing rewards. | Candy Crush Jelly (King) | A **7-day login streak** with a day-7 jackpot. |
| **Daily challenges**: players report filling a full calendar every month. | Woodoku reviews | **3 daily goals**, plus XP and levels that pay coins. |
| Cosmetic themes. | Block Blast ("colourful themes") | **6 colour themes** bought with coins. |

## 3. Ads: more views without driving players away

| Lesson | From | What we built |
|---|---|---|
| The top-grossing casual game has **no forced third-party ads**, and reviewers name that as a reason they stay. | Royal Match listing and reviews ([link](https://apps.apple.com/us/app/royal-match/id1482155847)) | Forced (interstitial) ads are **rare and strictly limited**. See below. |
| Players complain about **heavy and unskippable ads**, and about having no way to remove them. | Block Blast and Woodoku App Store reviews | Same as above. A paid "remove ads" option is a recommended next step. |
| King: players appreciate watching an ad **when they need help**, for example to get a colour bomb. | Candy Crush ([AdExchanger](https://adexchanger.com/mobile/rewarded-video-the-name-of-the-game-at-king/)) | Rewarded ads appear at moments of need: **revive** after losing, and double coins after a game. |
| Revive is a pop-up after a run ends, with a clear, eye-catching offer. Rewards scale with how many ads a player has watched. | Subway Surfers ([Unity](https://unity.com/blog/the-fundamentals-of-rewarded-video-ad-placements)) | Revive offer once per game, worded by the ML model. Extra rewarded spots: **double coins**, **double the daily reward**, **extra spin**, and up to 5 **free-coin** ads a day. |
| Make the offer optional and clear, so players feel in control. | Candy Crush ([Applixir](https://blog.applixir.com/blog/how-successful-games-implement-reward-video-ads)) | Every offer has a visible "No thanks". No countdown timers. |

The **interstitial limits** are in `lib/ads/ad_policy.dart` and covered by
tests:
- none in a player's first 3 games,
- at most 1 every 3 games, at least 3 minutes apart and 4 per session,
- none in the first 90 seconds of a session,
- none within 3 minutes of a rewarded ad,
- none right after a new best score.

They only appear when leaving a finished game. To match Royal Match exactly,
turn them off with `enabled: false`.

## 4. Look, feel and sound

| Lesson | From | What we built |
|---|---|---|
| Sound on every step, plus **praise that escalates** with the move ("Sweet → Tasty → Delicious → Divine"). It builds a "feeling of elevation". | Candy Crush ([Game Developer audio breakdown](https://www.gamedeveloper.com/audio/why-candy-crush-saga-is-so-engaging-an-audio-breakdown)) | Praise text grows with the clear: Nice → Great! → Excellent! → Amazing! → Perfect Clear!. It pops in with a bounce. Line-clear chimes **climb in pitch with each combo** (8 steps), every button has a soft tap sound, and the game uses haptics. |
| Big clears deserve a bigger celebration. | Tetris (the 4-line "Tetris") | 2+ lines add a sparkle layer and a gentle shake. A perfect clear gets a scale run, confetti and a heavy haptic. |
| A calm, tactile look with satisfying "wood-tile" sound effects. | Woodoku listing | Soft glossy blocks and a soft wooden "tock" when placing, in 3 pitch variants. All sounds are synthesised from scratch (`tool/sound/synth.js`). |
| Clear, colourful blocks. | Block Blast | Seven distinct hues per theme, plus a dark "Midnight" theme. |

Note: the chimes use the **pentatonic** scale because it never sounds harsh.
This is a music-theory choice that also fits the stress-relief goal. A small
2024 EEG study found pentatonic sequences relaxing
([Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC11056517/)).

## 5. Works on (almost) every phone

Block Blast and Woodoku run on a huge range of devices, and so must we:
- **Android 7.0+** (API 24), with 32- and 64-bit ARM builds.
- Layouts tested from **320×568** phones to tablets in portrait and landscape.
- Large system fonts are respected, up to 125%.
- Cached block art and capped particle effects for low-end phones.

## Caveats

These sources describe *what* famous games do, not exact numbers behind it.
Store listings and reviews change over time, and several design write-ups are
third-party analyses. Once Calm Grid is live, tune the ad limits and rewards
against its own retention data, with D7 retention as the guardrail.
