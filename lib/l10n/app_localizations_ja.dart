// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => '閉じる';

  @override
  String get back => '戻る';

  @override
  String get ok => 'OK';

  @override
  String get done => '完了';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get pause => '一時停止';

  @override
  String get noThanks => '今回はやめておく';

  @override
  String get reviveQuickTitle => '続けますか？';

  @override
  String get reviveQuickBody => '短い広告を見てスペースを空け、プレイを続けましょう。';

  @override
  String get reviveCloseTitle => 'あと少し！';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'ベストスコア（$best）の$percent%まで来ています。短い広告を見て、このゲームを続けましょう。';
  }

  @override
  String get reviveGreatTitle => 'ナイスプレイ！';

  @override
  String reviveGreatBody(int score) {
    return '現在$score点です。短い広告を見て、このゲームを続けましょう。';
  }

  @override
  String get reviveCalmTitle => 'ひと息つこう';

  @override
  String get reviveCalmBody => '急がなくて大丈夫。よければ短い広告でスペースを空けて、続きを遊べます。';

  @override
  String get watchAdContinue => '広告を見て続ける';

  @override
  String get adNotFinished => '広告が最後まで再生されなかったため、今回は続けられません。';

  @override
  String get paused => '一時停止中';

  @override
  String get resume => '再開';

  @override
  String get restart => 'やり直す';

  @override
  String get sound => '効果音';

  @override
  String get music => '音楽';

  @override
  String get vibrate => '振動';

  @override
  String get privacyOptions => 'プライバシー設定';

  @override
  String get rateGame => 'Calm Gridを評価';

  @override
  String dayStreak(int days) {
    return '$days日連続';
  }

  @override
  String rewardCollected(int day) {
    return '今日の報酬は受け取り済みです。明日また来ると$day日目の報酬がもらえます。';
  }

  @override
  String get dailyReward => 'デイリー報酬';

  @override
  String get dailyRewardHint => '毎日来てね。7日目は豪華報酬！';

  @override
  String dayShort(int day) {
    return '$day日目';
  }

  @override
  String claimCoins(int coins) {
    return '$coins受け取る';
  }

  @override
  String get dailyDoubleQuick => '広告を見て2倍';

  @override
  String dailyDoubleProgress(int coins) {
    return '広告を見て$coinsもらう';
  }

  @override
  String get dailyDoubleCalm => '短い広告で2倍にする';

  @override
  String get todaysGoals => '今日のミッション';

  @override
  String get goalsHint => 'ミッションは毎日更新。コインは自動で受け取れます。';

  @override
  String get achievements => '実績';

  @override
  String achievementsCount(int have, int total) {
    return '実績  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$total個中$have個を達成 · 各+$rewardコイン';
  }

  @override
  String achievementToast(String title, int reward) {
    return '実績解除：$title  +$rewardコイン';
  }

  @override
  String missionToast(String title, int reward) {
    return 'ミッション達成：$title  +$rewardコイン';
  }

  @override
  String levelLabel(int number) {
    return 'レベル$number';
  }

  @override
  String comboSub(int combo) {
    return 'コンボ×$combo';
  }

  @override
  String get dragHint => 'ブロックを盤面にドラッグしよう';

  @override
  String get doubleCoinsQuick => '広告を見てコイン2倍';

  @override
  String doubleCoinsProgress(int coins) {
    return '広告を見て+$coinsコイン';
  }

  @override
  String get doubleCoinsCalm => '短い広告でコインを2倍に';

  @override
  String get noMoreMoves => '置ける場所がありません';

  @override
  String get newBest => 'ベストスコア更新！';

  @override
  String get wellPlayed => 'お疲れさま。ひと息つこう。';

  @override
  String summaryBest(int best) {
    return 'ベスト$best';
  }

  @override
  String summaryLines(int count) {
    return '$countライン';
  }

  @override
  String summaryCombo(int combo) {
    return '×$comboコンボ';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'レベルアップ！レベル$level  （+$coinsコイン）';
  }

  @override
  String get nextLevel => '次のレベル';

  @override
  String get tryAgain => 'もう一度';

  @override
  String get map => 'マップ';

  @override
  String levelComplete(int number) {
    return 'レベル$numberクリア！';
  }

  @override
  String get noPiecesFit => 'どのピースも置けません。';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal：$percent%達成';
  }

  @override
  String winStreakBonus(int streak) {
    return '$streak連勝：ボーナスコイン！';
  }

  @override
  String get praiseNice => 'ナイス！';

  @override
  String get praiseGreat => 'グレート！';

  @override
  String get praiseExcellent => 'エクセレント！';

  @override
  String get praiseAmazing => 'アメイジング！';

  @override
  String get praiseIncredible => 'すごすぎる！';

  @override
  String get praiseLegendary => 'レジェンド！';

  @override
  String get praisePerfect => 'パーフェクト！';

  @override
  String get continueClassic => 'クラシックを続ける';

  @override
  String get classic => 'クラシック';

  @override
  String journeyLevel(int level) {
    return 'ジャーニー · レベル$level';
  }

  @override
  String get newClassicGame => 'クラシックを最初から';

  @override
  String get daily => 'デイリー';

  @override
  String get spin => '回す';

  @override
  String get goals => 'ミッション';

  @override
  String get themes => 'テーマ';

  @override
  String get journey => 'ジャーニー';

  @override
  String get spinning => '回転中…';

  @override
  String get extraSpinOffer => '短い広告を見てもう1回回そう。\n賞品はランダム：10〜200コイン。';

  @override
  String get watchAdSpin => '広告を見て回す';

  @override
  String get comeBackTomorrow => 'また明日';

  @override
  String get dailySpin => 'デイリールーレット';

  @override
  String youWonCoins(int coins) {
    return '$coinsコイン獲得！';
  }

  @override
  String get freeDailySpin => '毎日1回無料：10〜200コイン';

  @override
  String freeCoinsOffer(int coins, int left) {
    return '短い広告を見て$coinsコインを無料でゲット（今日はあと$left回）';
  }

  @override
  String get freeCoinsTomorrow => '無料コインは明日また受け取れます';

  @override
  String get inUse => '使用中';

  @override
  String get use => '使う';

  @override
  String get themeDawn => 'ラベンダーの夜明け';

  @override
  String get themeOcean => '穏やかな海';

  @override
  String get themeForest => '森の苔';

  @override
  String get themeSunset => '夕焼けの輝き';

  @override
  String get themeNight => '真夜中の星';

  @override
  String get themeSakura => '桜のそよ風';

  @override
  String journeyStreak(int streak, int percent) {
    return '$streak連勝中：次の勝利でコイン+$percent%';
  }

  @override
  String playLevel(int level) {
    return 'レベル$levelをプレイ';
  }

  @override
  String goalScore(int target) {
    return '$target点を取る';
  }

  @override
  String goalGems(int count) {
    return 'ジェムを$count個集める';
  }

  @override
  String missionClearLines(int count) {
    return '$countラインを消す';
  }

  @override
  String missionScore(int target) {
    return '1ゲームで$target点を取る';
  }

  @override
  String missionCombo(int target) {
    return '×$targetコンボを達成';
  }

  @override
  String missionPlayGames(int count) {
    return '$count回プレイする';
  }

  @override
  String missionPlaceBlocks(int count) {
    return 'ブロックを$count個置く';
  }

  @override
  String get missionPerfect => '盤面をすべて消す';

  @override
  String get achFirstBlock => 'はじめの一歩';

  @override
  String get achFirstBlockDesc => '最初のブロックを置く';

  @override
  String get achFirstLine => '一列そろった';

  @override
  String get achFirstLineDesc => '初めてラインを消す';

  @override
  String get achDouble => 'ダブル';

  @override
  String get achDoubleDesc => '1つのブロックで2ラインを消す';

  @override
  String get achTriple => 'トリプル';

  @override
  String get achTripleDesc => '1つのブロックで3ラインを消す';

  @override
  String get achCombo3 => 'ノッてきた';

  @override
  String get achCombo3Desc => '×3コンボを達成';

  @override
  String get achCombo6 => 'コンボマスター';

  @override
  String get achCombo6Desc => '×6コンボを達成';

  @override
  String get achPerfect => 'まっさら';

  @override
  String get achPerfectDesc => '盤面をすべて消す';

  @override
  String get achScore1k => '千点クラブ';

  @override
  String get achScore1kDesc => '1ゲームで1,000点を取る';

  @override
  String get achScore5k => 'ハイフライヤー';

  @override
  String get achScore5kDesc => '1ゲームで5,000点を取る';

  @override
  String get achLines500 => 'ラインコレクター';

  @override
  String get achLines500Desc => '合計500ラインを消す';

  @override
  String get achJourney5 => '旅の途中';

  @override
  String get achJourney5Desc => 'ジャーニーのレベル5をクリア';

  @override
  String get achJourney25 => '旅人';

  @override
  String get achJourney25Desc => 'ジャーニーのレベル25をクリア';

  @override
  String get achStars30 => '星を見る人';

  @override
  String get achStars30Desc => 'ジャーニーで星を30個獲得';

  @override
  String get achGems50 => 'ジェムハンター';

  @override
  String get achGems50Desc => 'ジェムを合計50個集める';

  @override
  String get achStreak7 => '毎日の習慣';

  @override
  String get achStreak7Desc => '7日連続でログイン';

  @override
  String get couldNotStart => 'Calm Gridを起動できませんでした：';

  @override
  String get somethingWrong => '問題が発生しました（開発者向けにスクリーンショットを撮ってください）';
}
