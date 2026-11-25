// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get pause => 'Pause';

  @override
  String get noThanks => 'No thanks';

  @override
  String get reviveQuickTitle => 'Continue?';

  @override
  String get reviveQuickBody =>
      'Watch a short ad to clear some space and keep playing.';

  @override
  String get reviveCloseTitle => 'So close!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'You\'re $percent% of the way to your best ($best). Watch a short ad to keep this run going.';
  }

  @override
  String get reviveGreatTitle => 'Great run!';

  @override
  String reviveGreatBody(int score) {
    return 'You\'re on $score points. Watch a short ad to keep this run going.';
  }

  @override
  String get reviveCalmTitle => 'Take a breath';

  @override
  String get reviveCalmBody =>
      'No rush. If you\'d like, a short ad will clear some space so you can continue.';

  @override
  String get watchAdContinue => 'Watch ad & continue';

  @override
  String get adNotFinished => 'The ad didn\'t finish, so no revive this time.';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get sound => 'Sound';

  @override
  String get music => 'Music';

  @override
  String get vibrate => 'Vibrate';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get rateGame => 'Rate Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'Today\'s reward is collected. Come back tomorrow for day $day.';
  }

  @override
  String get dailyReward => 'Daily reward';

  @override
  String get dailyRewardHint => 'Come back every day: day 7 is a big one.';

  @override
  String dayShort(int day) {
    return 'D$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Claim $coins';
  }

  @override
  String get dailyDoubleQuick => 'Watch ad: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Watch ad: get $coins';
  }

  @override
  String get dailyDoubleCalm => 'Double it with a short ad';

  @override
  String get todaysGoals => 'Today\'s goals';

  @override
  String get goalsHint => 'New goals every day. Coins are paid automatically.';

  @override
  String get achievements => 'Achievements';

  @override
  String achievementsCount(int have, int total) {
    return 'Achievements  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have of $total unlocked · +$reward coins each';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Achievement: $title  +$reward coins';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Mission complete: $title  +$reward coins';
  }

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String comboSub(int combo) {
    return 'Combo ×$combo';
  }

  @override
  String get dragHint => 'Drag a block onto the board';

  @override
  String get doubleCoinsQuick => 'Watch ad: ×2 coins';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Watch ad: +$coins coins';
  }

  @override
  String get doubleCoinsCalm => 'Double coins with a short ad';

  @override
  String get noMoreMoves => 'No more moves';

  @override
  String get newBest => 'New best score!';

  @override
  String get wellPlayed => 'Well played. Take a breath.';

  @override
  String summaryBest(int best) {
    return 'Best $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return '×$combo combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Level up! Level $level  (+$coins coins)';
  }

  @override
  String get nextLevel => 'Next level';

  @override
  String get tryAgain => 'Try again';

  @override
  String get map => 'Map';

  @override
  String levelComplete(int number) {
    return 'Level $number complete!';
  }

  @override
  String get noPiecesFit => 'None of your pieces fit anywhere.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% done';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Win streak ×$streak: bonus coins!';
  }

  @override
  String get praiseNice => 'Nice';

  @override
  String get praiseGreat => 'Great!';

  @override
  String get praiseExcellent => 'Excellent!';

  @override
  String get praiseAmazing => 'Amazing!';

  @override
  String get praiseIncredible => 'Incredible!';

  @override
  String get praiseLegendary => 'Legendary!';

  @override
  String get praisePerfect => 'Perfect Clear!';

  @override
  String get continueClassic => 'Continue Classic';

  @override
  String get classic => 'Classic';

  @override
  String journeyLevel(int level) {
    return 'Journey · Level $level';
  }

  @override
  String get newClassicGame => 'New Classic game';

  @override
  String get daily => 'Daily';

  @override
  String get spin => 'Spin';

  @override
  String get goals => 'Goals';

  @override
  String get themes => 'Themes';

  @override
  String get journey => 'Journey';

  @override
  String get spinning => 'Spinning…';

  @override
  String get extraSpinOffer =>
      'Watch a short ad for one more spin.\nPrize is random: 10 to 200 coins.';

  @override
  String get watchAdSpin => 'Watch ad & spin';

  @override
  String get comeBackTomorrow => 'Come back tomorrow';

  @override
  String get dailySpin => 'Daily spin';

  @override
  String youWonCoins(int coins) {
    return 'You won $coins coins!';
  }

  @override
  String get freeDailySpin => 'Free daily spin: 10 to 200 coins';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Watch a short ad for $coins free coins ($left left today)';
  }

  @override
  String get freeCoinsTomorrow => 'Free coins are back tomorrow';

  @override
  String get inUse => 'In use';

  @override
  String get use => 'Use';

  @override
  String get themeDawn => 'Lavender Dawn';

  @override
  String get themeOcean => 'Ocean Calm';

  @override
  String get themeForest => 'Forest Moss';

  @override
  String get themeSunset => 'Sunset Glow';

  @override
  String get themeNight => 'Midnight Stars';

  @override
  String get themeSakura => 'Sakura Breeze';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Win streak $streak: +$percent% coins on your next win';
  }

  @override
  String playLevel(int level) {
    return 'Play level $level';
  }

  @override
  String goalScore(int target) {
    return 'Score $target';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count gems',
      one: 'Collect 1 gem',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Clear $count lines',
      one: 'Clear 1 line',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Score $target in one game';
  }

  @override
  String missionCombo(int target) {
    return 'Reach a ×$target combo';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Play $count games',
      one: 'Play 1 game',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Place $count blocks',
      one: 'Place 1 block',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Clear the whole board';

  @override
  String get achFirstBlock => 'First steps';

  @override
  String get achFirstBlockDesc => 'Place your first block';

  @override
  String get achFirstLine => 'Line up';

  @override
  String get achFirstLineDesc => 'Clear your first line';

  @override
  String get achDouble => 'Double up';

  @override
  String get achDoubleDesc => 'Clear 2 lines with one block';

  @override
  String get achTriple => 'Triple treat';

  @override
  String get achTripleDesc => 'Clear 3 lines with one block';

  @override
  String get achCombo3 => 'In the flow';

  @override
  String get achCombo3Desc => 'Reach a ×3 combo';

  @override
  String get achCombo6 => 'Combo master';

  @override
  String get achCombo6Desc => 'Reach a ×6 combo';

  @override
  String get achPerfect => 'Clean slate';

  @override
  String get achPerfectDesc => 'Clear the whole board';

  @override
  String get achScore1k => 'Thousand club';

  @override
  String get achScore1kDesc => 'Score 1,000 in one game';

  @override
  String get achScore5k => 'High flyer';

  @override
  String get achScore5kDesc => 'Score 5,000 in one game';

  @override
  String get achLines500 => 'Line collector';

  @override
  String get achLines500Desc => 'Clear 500 lines in total';

  @override
  String get achJourney5 => 'On the path';

  @override
  String get achJourney5Desc => 'Complete Journey level 5';

  @override
  String get achJourney25 => 'Wayfarer';

  @override
  String get achJourney25Desc => 'Complete Journey level 25';

  @override
  String get achStars30 => 'Star gazer';

  @override
  String get achStars30Desc => 'Earn 30 stars in Journey';

  @override
  String get achGems50 => 'Gem hunter';

  @override
  String get achGems50Desc => 'Collect 50 gems in total';

  @override
  String get achStreak7 => 'Daily habit';

  @override
  String get achStreak7Desc => 'Reach a 7-day login streak';

  @override
  String get couldNotStart => 'Calm Grid could not start:';

  @override
  String get somethingWrong =>
      'Something went wrong (screenshot this for the developer)';
}
