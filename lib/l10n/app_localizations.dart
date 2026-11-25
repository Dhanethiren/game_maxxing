import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// Game name. Keep it as is in every language.
  ///
  /// In en, this message translates to:
  /// **'Calm Grid'**
  String get appTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @reviveQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue?'**
  String get reviveQuickTitle;

  /// No description provided for @reviveQuickBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to clear some space and keep playing.'**
  String get reviveQuickBody;

  /// No description provided for @reviveCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'So close!'**
  String get reviveCloseTitle;

  /// No description provided for @reviveCloseBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re {percent}% of the way to your best ({best}). Watch a short ad to keep this run going.'**
  String reviveCloseBody(int percent, int best);

  /// No description provided for @reviveGreatTitle.
  ///
  /// In en, this message translates to:
  /// **'Great run!'**
  String get reviveGreatTitle;

  /// No description provided for @reviveGreatBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re on {score} points. Watch a short ad to keep this run going.'**
  String reviveGreatBody(int score);

  /// No description provided for @reviveCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a breath'**
  String get reviveCalmTitle;

  /// No description provided for @reviveCalmBody.
  ///
  /// In en, this message translates to:
  /// **'No rush. If you\'d like, a short ad will clear some space so you can continue.'**
  String get reviveCalmBody;

  /// Button. Must say that an ad plays (ad policy).
  ///
  /// In en, this message translates to:
  /// **'Watch ad & continue'**
  String get watchAdContinue;

  /// No description provided for @adNotFinished.
  ///
  /// In en, this message translates to:
  /// **'The ad didn\'t finish, so no revive this time.'**
  String get adNotFinished;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @vibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get vibrate;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get privacyOptions;

  /// No description provided for @rateGame.
  ///
  /// In en, this message translates to:
  /// **'Rate Calm Grid'**
  String get rateGame;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1-day streak} other{{days}-day streak}}'**
  String dayStreak(int days);

  /// No description provided for @rewardCollected.
  ///
  /// In en, this message translates to:
  /// **'Today\'s reward is collected. Come back tomorrow for day {day}.'**
  String rewardCollected(int day);

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily reward'**
  String get dailyReward;

  /// No description provided for @dailyRewardHint.
  ///
  /// In en, this message translates to:
  /// **'Come back every day: day 7 is a big one.'**
  String get dailyRewardHint;

  /// Very short label for a day in the 7-day reward calendar (2-3 characters).
  ///
  /// In en, this message translates to:
  /// **'D{day}'**
  String dayShort(int day);

  /// No description provided for @claimCoins.
  ///
  /// In en, this message translates to:
  /// **'Claim {coins}'**
  String claimCoins(int coins);

  /// No description provided for @dailyDoubleQuick.
  ///
  /// In en, this message translates to:
  /// **'Watch ad: ×2'**
  String get dailyDoubleQuick;

  /// No description provided for @dailyDoubleProgress.
  ///
  /// In en, this message translates to:
  /// **'Watch ad: get {coins}'**
  String dailyDoubleProgress(int coins);

  /// No description provided for @dailyDoubleCalm.
  ///
  /// In en, this message translates to:
  /// **'Double it with a short ad'**
  String get dailyDoubleCalm;

  /// No description provided for @todaysGoals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goals'**
  String get todaysGoals;

  /// No description provided for @goalsHint.
  ///
  /// In en, this message translates to:
  /// **'New goals every day. Coins are paid automatically.'**
  String get goalsHint;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsCount.
  ///
  /// In en, this message translates to:
  /// **'Achievements  {have}/{total}'**
  String achievementsCount(int have, int total);

  /// No description provided for @achievementsSummary.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total} unlocked · +{reward} coins each'**
  String achievementsSummary(int have, int total, int reward);

  /// No description provided for @achievementToast.
  ///
  /// In en, this message translates to:
  /// **'Achievement: {title}  +{reward} coins'**
  String achievementToast(String title, int reward);

  /// No description provided for @missionToast.
  ///
  /// In en, this message translates to:
  /// **'Mission complete: {title}  +{reward} coins'**
  String missionToast(String title, int reward);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelLabel(int number);

  /// No description provided for @comboSub.
  ///
  /// In en, this message translates to:
  /// **'Combo ×{combo}'**
  String comboSub(int combo);

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a block onto the board'**
  String get dragHint;

  /// No description provided for @doubleCoinsQuick.
  ///
  /// In en, this message translates to:
  /// **'Watch ad: ×2 coins'**
  String get doubleCoinsQuick;

  /// No description provided for @doubleCoinsProgress.
  ///
  /// In en, this message translates to:
  /// **'Watch ad: +{coins} coins'**
  String doubleCoinsProgress(int coins);

  /// No description provided for @doubleCoinsCalm.
  ///
  /// In en, this message translates to:
  /// **'Double coins with a short ad'**
  String get doubleCoinsCalm;

  /// No description provided for @noMoreMoves.
  ///
  /// In en, this message translates to:
  /// **'No more moves'**
  String get noMoreMoves;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'New best score!'**
  String get newBest;

  /// No description provided for @wellPlayed.
  ///
  /// In en, this message translates to:
  /// **'Well played. Take a breath.'**
  String get wellPlayed;

  /// No description provided for @summaryBest.
  ///
  /// In en, this message translates to:
  /// **'Best {best}'**
  String summaryBest(int best);

  /// No description provided for @summaryLines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}}'**
  String summaryLines(int count);

  /// No description provided for @summaryCombo.
  ///
  /// In en, this message translates to:
  /// **'×{combo} combo'**
  String summaryCombo(int combo);

  /// No description provided for @levelUpLine.
  ///
  /// In en, this message translates to:
  /// **'Level up! Level {level}  (+{coins} coins)'**
  String levelUpLine(int level, int coins);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get nextLevel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level {number} complete!'**
  String levelComplete(int number);

  /// No description provided for @noPiecesFit.
  ///
  /// In en, this message translates to:
  /// **'None of your pieces fit anywhere.'**
  String get noPiecesFit;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'{goal}: {percent}% done'**
  String goalProgress(String goal, int percent);

  /// No description provided for @winStreakBonus.
  ///
  /// In en, this message translates to:
  /// **'Win streak ×{streak}: bonus coins!'**
  String winStreakBonus(int streak);

  /// Shown big on screen after clearing 1 line. Praise grows: Nice (1 line) < Great (2) < Excellent (3) < Amazing (4) < Incredible (5) < Legendary (6). Keep them short.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get praiseNice;

  /// No description provided for @praiseGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get praiseGreat;

  /// No description provided for @praiseExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get praiseExcellent;

  /// No description provided for @praiseAmazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing!'**
  String get praiseAmazing;

  /// No description provided for @praiseIncredible.
  ///
  /// In en, this message translates to:
  /// **'Incredible!'**
  String get praiseIncredible;

  /// No description provided for @praiseLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary!'**
  String get praiseLegendary;

  /// No description provided for @praisePerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect Clear!'**
  String get praisePerfect;

  /// No description provided for @continueClassic.
  ///
  /// In en, this message translates to:
  /// **'Continue Classic'**
  String get continueClassic;

  /// The endless game mode.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @journeyLevel.
  ///
  /// In en, this message translates to:
  /// **'Journey · Level {level}'**
  String journeyLevel(int level);

  /// No description provided for @newClassicGame.
  ///
  /// In en, this message translates to:
  /// **'New Classic game'**
  String get newClassicGame;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// The level-based game mode (a path of levels).
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journey;

  /// No description provided for @spinning.
  ///
  /// In en, this message translates to:
  /// **'Spinning…'**
  String get spinning;

  /// No description provided for @extraSpinOffer.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad for one more spin.\nPrize is random: 10 to 200 coins.'**
  String get extraSpinOffer;

  /// No description provided for @watchAdSpin.
  ///
  /// In en, this message translates to:
  /// **'Watch ad & spin'**
  String get watchAdSpin;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get comeBackTomorrow;

  /// No description provided for @dailySpin.
  ///
  /// In en, this message translates to:
  /// **'Daily spin'**
  String get dailySpin;

  /// No description provided for @youWonCoins.
  ///
  /// In en, this message translates to:
  /// **'You won {coins} coins!'**
  String youWonCoins(int coins);

  /// No description provided for @freeDailySpin.
  ///
  /// In en, this message translates to:
  /// **'Free daily spin: 10 to 200 coins'**
  String get freeDailySpin;

  /// No description provided for @freeCoinsOffer.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad for {coins} free coins ({left} left today)'**
  String freeCoinsOffer(int coins, int left);

  /// No description provided for @freeCoinsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Free coins are back tomorrow'**
  String get freeCoinsTomorrow;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @themeDawn.
  ///
  /// In en, this message translates to:
  /// **'Lavender Dawn'**
  String get themeDawn;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean Calm'**
  String get themeOcean;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest Moss'**
  String get themeForest;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset Glow'**
  String get themeSunset;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Midnight Stars'**
  String get themeNight;

  /// No description provided for @themeSakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura Breeze'**
  String get themeSakura;

  /// No description provided for @journeyStreak.
  ///
  /// In en, this message translates to:
  /// **'Win streak {streak}: +{percent}% coins on your next win'**
  String journeyStreak(int streak, int percent);

  /// No description provided for @playLevel.
  ///
  /// In en, this message translates to:
  /// **'Play level {level}'**
  String playLevel(int level);

  /// No description provided for @goalScore.
  ///
  /// In en, this message translates to:
  /// **'Score {target}'**
  String goalScore(int target);

  /// No description provided for @goalGems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect 1 gem} other{Collect {count} gems}}'**
  String goalGems(int count);

  /// No description provided for @missionClearLines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Clear 1 line} other{Clear {count} lines}}'**
  String missionClearLines(int count);

  /// No description provided for @missionScore.
  ///
  /// In en, this message translates to:
  /// **'Score {target} in one game'**
  String missionScore(int target);

  /// No description provided for @missionCombo.
  ///
  /// In en, this message translates to:
  /// **'Reach a ×{target} combo'**
  String missionCombo(int target);

  /// No description provided for @missionPlayGames.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Play 1 game} other{Play {count} games}}'**
  String missionPlayGames(int count);

  /// No description provided for @missionPlaceBlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Place 1 block} other{Place {count} blocks}}'**
  String missionPlaceBlocks(int count);

  /// No description provided for @missionPerfect.
  ///
  /// In en, this message translates to:
  /// **'Clear the whole board'**
  String get missionPerfect;

  /// No description provided for @achFirstBlock.
  ///
  /// In en, this message translates to:
  /// **'First steps'**
  String get achFirstBlock;

  /// No description provided for @achFirstBlockDesc.
  ///
  /// In en, this message translates to:
  /// **'Place your first block'**
  String get achFirstBlockDesc;

  /// No description provided for @achFirstLine.
  ///
  /// In en, this message translates to:
  /// **'Line up'**
  String get achFirstLine;

  /// No description provided for @achFirstLineDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear your first line'**
  String get achFirstLineDesc;

  /// No description provided for @achDouble.
  ///
  /// In en, this message translates to:
  /// **'Double up'**
  String get achDouble;

  /// No description provided for @achDoubleDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 2 lines with one block'**
  String get achDoubleDesc;

  /// No description provided for @achTriple.
  ///
  /// In en, this message translates to:
  /// **'Triple treat'**
  String get achTriple;

  /// No description provided for @achTripleDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 3 lines with one block'**
  String get achTripleDesc;

  /// No description provided for @achCombo3.
  ///
  /// In en, this message translates to:
  /// **'In the flow'**
  String get achCombo3;

  /// No description provided for @achCombo3Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a ×3 combo'**
  String get achCombo3Desc;

  /// No description provided for @achCombo6.
  ///
  /// In en, this message translates to:
  /// **'Combo master'**
  String get achCombo6;

  /// No description provided for @achCombo6Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a ×6 combo'**
  String get achCombo6Desc;

  /// No description provided for @achPerfect.
  ///
  /// In en, this message translates to:
  /// **'Clean slate'**
  String get achPerfect;

  /// No description provided for @achPerfectDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear the whole board'**
  String get achPerfectDesc;

  /// No description provided for @achScore1k.
  ///
  /// In en, this message translates to:
  /// **'Thousand club'**
  String get achScore1k;

  /// No description provided for @achScore1kDesc.
  ///
  /// In en, this message translates to:
  /// **'Score 1,000 in one game'**
  String get achScore1kDesc;

  /// No description provided for @achScore5k.
  ///
  /// In en, this message translates to:
  /// **'High flyer'**
  String get achScore5k;

  /// No description provided for @achScore5kDesc.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in one game'**
  String get achScore5kDesc;

  /// No description provided for @achLines500.
  ///
  /// In en, this message translates to:
  /// **'Line collector'**
  String get achLines500;

  /// No description provided for @achLines500Desc.
  ///
  /// In en, this message translates to:
  /// **'Clear 500 lines in total'**
  String get achLines500Desc;

  /// No description provided for @achJourney5.
  ///
  /// In en, this message translates to:
  /// **'On the path'**
  String get achJourney5;

  /// No description provided for @achJourney5Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete Journey level 5'**
  String get achJourney5Desc;

  /// No description provided for @achJourney25.
  ///
  /// In en, this message translates to:
  /// **'Wayfarer'**
  String get achJourney25;

  /// No description provided for @achJourney25Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete Journey level 25'**
  String get achJourney25Desc;

  /// No description provided for @achStars30.
  ///
  /// In en, this message translates to:
  /// **'Star gazer'**
  String get achStars30;

  /// No description provided for @achStars30Desc.
  ///
  /// In en, this message translates to:
  /// **'Earn 30 stars in Journey'**
  String get achStars30Desc;

  /// No description provided for @achGems50.
  ///
  /// In en, this message translates to:
  /// **'Gem hunter'**
  String get achGems50;

  /// No description provided for @achGems50Desc.
  ///
  /// In en, this message translates to:
  /// **'Collect 50 gems in total'**
  String get achGems50Desc;

  /// No description provided for @achStreak7.
  ///
  /// In en, this message translates to:
  /// **'Daily habit'**
  String get achStreak7;

  /// No description provided for @achStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day login streak'**
  String get achStreak7Desc;

  /// No description provided for @couldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Calm Grid could not start:'**
  String get couldNotStart;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong (screenshot this for the developer)'**
  String get somethingWrong;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
    case 'id':
      return L10nId();
    case 'it':
      return L10nIt();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'pt':
      return L10nPt();
    case 'ru':
      return L10nRu();
    case 'tr':
      return L10nTr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
