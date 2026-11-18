# How Google Play decides what to show, and what we changed

The research below uses **only trustworthy sources**:
- Google's own Play Console Help Center and "How Google Play Works" pages
- Android Developers documentation and the official Android Developers Blog
- Google Research's peer-reviewed paper on the Play recommender

Google does not publish its exact ranking weights. Where something is
inferred rather than stated, it is marked *inference*.

## 1. What Google says it ranks on

Google names three pillars for search and recommendations
([App discovery and ranking](https://support.google.com/googleplay/android-developer/answer/9958766?hl=en),
[How Google Play Works](https://play.google.com/intl/en_in/about/howplayworks)):

1. **Relevance to the user.**
   - In **search**, Play works out what the user wants and matches it using
     the app's metadata (**title, description, category**) plus other
     signals.
   - In **recommendations** ("For you" and similar), Play personalises based
     on the apps a user has already installed.
2. **Quality.**
   - **Technical performance** and **user experience** in the app.
   - The **pre-install experience**: icon, title, screenshots, video,
     description.
   - Low-value or badly performing apps are kept off discovery surfaces and
     out of top search results.
3. **Editorial value.** Editors curate collections and "Editors' Choice"
   based on novelty, design, usefulness and breadth of appeal.

More from Google's own pages:
- **Search** combines **ratings, reviews, downloads and other factors**
  ([Get discovered on Google Play search](https://support.google.com/googleplay/android-developer/answer/4448378?hl=en)).
- **Top charts** are driven mainly by **popularity**; **search** mainly by
  **relevance** to the query.
- **Engagement after install**, meaning how users actually use an app, is a
  main ranking factor. This comes from Google's legally required consumer
  disclosure for France
  ([Google Play Help](https://support.google.com/googleplay/answer/7588573)).
- **Nobody can buy a better position** in search results. Ads appear only in
  the separate ad slots.

## 2. How the recommender works (Google Research)

Google Research published the Play recommender's design: **"Wide & Deep
Learning for Recommender Systems"** (Cheng et al., 2016)
([arXiv](https://arxiv.org/abs/1606.07792),
[Google Research](https://research.google/pubs/wide-deep-learning-for-recommender-systems/)).

- It ran in production on Google Play, scoring over 10 million apps per
  second at peak.
- **What it predicts:** each training example is one *impression* (an app
  shown to a user). The label is **whether the user then installed it**. So
  the system learns which apps a given user, in a given context, is most
  likely to install.
- **How:** a "wide" part memorises patterns from past behaviour (users who
  installed X often install Y). A "deep" part generalises to similar apps
  the user hasn't seen.
- **Result:** +3.9% app acquisitions on the Play home page in a live
  experiment.

*Inference (the current system has surely evolved since 2016, so treat this
as directional):*
- **Listing conversion matters.** How often people install after seeing the
  listing is the very thing the model learns. Icon, screenshots and short
  description all influence that.
- **Being clearly in the right neighbourhood helps.** The model links apps
  through shared users and features, so an accurate category, tags and
  wording help Play show Calm Grid to people who like block puzzles.

## 3. The other official levers

| Lever | What Google says | Source |
|---|---|---|
| **Technical quality (Android vitals)** | "Bad behaviour" thresholds are a **1.09%** user-perceived crash rate and **0.47%** ANR rate overall, and **8%** on any single phone model. Over them, Play **may reduce visibility** and **show a warning on the listing**. Measured over 28 days. | [Android vitals](https://developer.android.com/topic/performance/vitals), [Play Console Help](https://support.google.com/googleplay/android-developer/answer/9844486?hl=en) |
| **Ratings** | The store rating is **weighted towards recent ratings**, not a lifetime average. | [Android Developers Blog, 2019](https://android-developers.googleblog.com/2019/05/whats-new-in-play.html), [Play Console Help](https://support.google.com/googleplay/android-developer/answer/138230?hl=en) |
| **Asking for ratings** | Use the In-App Review API after the user has experienced enough of the app, at a natural moment. Never behind a button (link to the store instead), never with screening questions first. Play enforces a hidden quota, so keep your own limits. | [In-App Review API](https://developer.android.com/guide/playcore/in-app-review), [Android Developers Blog](https://android-developers.googleblog.com/2020/08/in-app-review-api.html) |
| **Metadata rules** | Title of 30 characters or fewer. No "free", "best", "#1" or ranking or price claims in the title, icon or preview assets. Keyword stuffing is prohibited, and unnecessary keywords **don't help ranking**. Assets that miss the guidelines may be **ineligible for promotion** on Apps & Games home. | [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842?hl=en), [Android Developers Blog, 2021](https://android-developers.googleblog.com/2021/04/updated-guidance-to-improve-your-app.html), [Preview assets](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en) |
| **Category and tags** | Up to **5 tags**, chosen for obvious accuracy. They help users find the app. | [Category and tags](https://support.google.com/googleplay/android-developer/answer/9859673?hl=en) |
| **Large screens** | Apps meeting the large-screen quality guidelines (resize well, **both orientations**, **no letterboxing**) **rank higher in search and Apps/Games home** on tablets and foldables. Unoptimised apps can show a warning. A new "Optimized for large screens" badge started in 2026. | [Android Developers Blog, 2022](https://android-developers.googleblog.com/2022/03/helping-users-discover-quality-apps-on.html), [Adaptive app quality](https://developer.android.com/docs/quality-guidelines/large-screen-app-quality), [Android Developers Blog, 2026](https://android-developers.googleblog.com/2026/05/android-adaptive-development-ecosystem.html) |
| **Localisation** | Free machine translation of the store listing. Play Console may suggest languages likely to increase installs. | [Translate and localize](https://support.google.com/googleplay/android-developer/answer/9844778?hl=en) |
| **Custom store listings** | Different listings for different audiences, for example by country or for lapsed players. Google reports a **+3.5% MAU** average lift (internal analysis). | [Android Developers Blog, 2023](https://android-developers.googleblog.com/2023/09/grow-user-acquisition-and-store-conversions-with-updated-play-store-listing-certificate-course.html), [Custom listings](https://support.google.com/googleplay/android-developer/answer/9867158?hl=en) |
| **Store listing experiments** | A/B test icons, screenshots and text against install data. | [Run A/B tests](https://support.google.com/googleplay/android-developer/answer/12053285?hl=en) |
| **Promotional content** (events and offers on the store) | Google reports **+3.6% revenue** and **+5.1% 28-day active users** versus similar titles. | [Android Developers Blog, 2022](https://android-developers.googleblog.com/2022/11/supporting-and-rewarding-great-apps-and-games-on-google-play.html) |
| **Google Play Games Level Up** (voluntary) | Games meeting its guidelines keep access to the personalised **You tab**, **Sidekick** and **Play Points** offers and quests. Achievements are discoverable through **search filters**. Guidelines include: Play Games Services sign-in, **at least 10 achievements**, cloud save and Sidekick. | [Level Up](https://play.google.com/console/about/levelup/), [Android Developers Blog, 2025](https://android-developers.googleblog.com/2025/09/introducing-google-play-games-level-up.html), [Android Developers Blog, 2026](https://android-developers.googleblog.com/2026/03/level-up-your-game.html), [Enrolment](https://support.google.com/googleplay/android-developer/answer/18018581) |

## 4. What we changed in the game (done)

| Change | Why (from the evidence above) |
|---|---|
| **In-App Review prompt** after happy moments: a new best score, or a 3-star Journey level. Only for players with 5+ games who installed 2+ days ago, at most once every 120 days, after the result screen settles. No reward is ever given for rating (that's prohibited). | Ratings feed search ranking, and recent ratings weigh most. This follows Google's In-App Review rules exactly. |
| **"Rate Calm Grid" button in Settings** opens the store page. | Google says not to put the review card behind a button. |
| **15 achievements** (+25 coins each), viewable from Goals. Each has a stable ID ready to map to Play Games achievements. | Level Up needs at least 10 Play Games achievements, which unlock the You tab, Play Points quests and search-filter discovery. They also add mid-term goals, which supports engagement. |
| **Tablets and foldables can rotate** and use the landscape layout. Phones stay portrait. The fixed portrait lock was removed from the manifest. | Large-screen-optimised apps rank higher on tablets. Both orientations and no letterboxing are core criteria. |
| **Tablet store screenshots**, portrait and landscape (`store/screenshots_tablet/`). | Tablet listings show tablet screenshots, and they show the large-screen layout. |
| **Store listing text revised**: main keyword in the title, plain wording, no promotional words (section 5). | Metadata drives search relevance. Promotional words can make assets ineligible for promotion. |
| Already in place: low crash risk (no heavy main-thread work, crash reporter), 16 KB pages, Android 16 target. | Android vitals thresholds affect visibility. |

## 5. Store listing text (updated)

- **Title (23/30):** `Calm Grid: Block Puzzle`
- **Short description (78/80):** `Relaxing block puzzle game. No timer, no rush: fill lines and clear the board.`
- **Category:** Games → **Puzzle**.
- **Tags (max 5):** pick the five most accurate from Play Console's list.
  Look for block puzzle, brain or logic, relaxing, casual and offline-style
  tags. Use only ones a new player would agree describe the game.
- **Full description:**

  > Calm Grid is a relaxing block puzzle game for quiet moments. Drag blocks
  > onto the 8×8 grid, complete a row or column, and watch it clear with a
  > soft chime. There's no timer and no rush: play at your own pace.
  >
  > CLASSIC MODE
  > An endless puzzle where you chase your best score. Plan ahead, chain
  > clears into combos, and empty the whole board for a Perfect Clear.
  >
  > JOURNEY MODE
  > Hundreds of puzzle levels with score and gem goals, 1–3 stars per level
  > and win-streak bonuses.
  >
  > MADE TO HELP YOU UNWIND
  > • Soft colours and hand-crafted tiles
  > • Gentle pentatonic sounds that rise with every combo, and calm music you
  >   can turn off
  > • Plays offline: no Wi-Fi needed
  > • Your game saves after every move
  >
  > DAILY FUN
  > • Daily reward, daily spin and three new goals every day
  > • 15 achievements to unlock
  > • Six colour themes, including a dark Midnight theme
  >
  > Works on phones and tablets, in portrait and landscape on tablets.
  > Calm Grid is supported by ads. Most of them are your choice: watch one to
  > continue a run or double your coins.

## 6. Your Play Console checklist for discovery

1. **Tags**: choose 5 accurate tags (section 5).
2. **Translations**: use the free machine translation for the store listing.
   Start with the languages Play Console suggests, or es, pt-BR, id, hi, de,
   fr, ja.
3. **Preview video** (30 s of real gameplay): recommended for games and part
   of the "highly recommended" assets.
4. **Store listing experiments**: A/B test the icon and first screenshot,
   since these drive the impression-to-install rate the recommender learns
   from.
5. **Custom store listing** for lapsed players, for example highlighting
   Journey mode.
6. **Promotional content** for events, such as a weekend themed challenge or
   a new theme, once eligible.
7. **Play Games Services + Level Up**:
   - create the Play Games project,
   - add the 15 achievements using the IDs in `lib/services/achievements.dart`,
   - then I wire up sign-in, achievements and cloud save.
8. **Watch Android vitals weekly**: crash rate under 1.09% and ANR rate under
   0.47%.
9. **Reply to reviews.** Google lists responding to user feedback among its
   discovery recommendations.
