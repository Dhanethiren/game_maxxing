// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => '닫기';

  @override
  String get back => '뒤로';

  @override
  String get ok => '확인';

  @override
  String get done => '완료';

  @override
  String get home => '홈';

  @override
  String get settings => '설정';

  @override
  String get pause => '일시정지';

  @override
  String get noThanks => '괜찮아요';

  @override
  String get reviveQuickTitle => '계속할까요?';

  @override
  String get reviveQuickBody => '짧은 광고를 보고 공간을 비운 뒤 계속 플레이하세요.';

  @override
  String get reviveCloseTitle => '거의 다 왔어요!';

  @override
  String reviveCloseBody(int percent, int best) {
    return '최고 기록($best)의 $percent%까지 왔어요. 짧은 광고를 보고 이번 판을 이어가세요.';
  }

  @override
  String get reviveGreatTitle => '멋진 플레이!';

  @override
  String reviveGreatBody(int score) {
    return '현재 $score점이에요. 짧은 광고를 보고 이번 판을 이어가세요.';
  }

  @override
  String get reviveCalmTitle => '잠깐 숨 고르기';

  @override
  String get reviveCalmBody => '서두르지 않아도 돼요. 원하면 짧은 광고로 공간을 비우고 계속할 수 있어요.';

  @override
  String get watchAdContinue => '광고 보고 계속하기';

  @override
  String get adNotFinished => '광고가 끝나지 않아 이번에는 이어서 할 수 없어요.';

  @override
  String get paused => '일시정지됨';

  @override
  String get resume => '계속하기';

  @override
  String get restart => '다시 시작';

  @override
  String get sound => '효과음';

  @override
  String get music => '음악';

  @override
  String get vibrate => '진동';

  @override
  String get privacyOptions => '개인정보 옵션';

  @override
  String get rateGame => 'Calm Grid 평가하기';

  @override
  String dayStreak(int days) {
    return '$days일 연속';
  }

  @override
  String rewardCollected(int day) {
    return '오늘의 보상을 받았어요. 내일 다시 오면 $day일차 보상을 받을 수 있어요.';
  }

  @override
  String get dailyReward => '일일 보상';

  @override
  String get dailyRewardHint => '매일 들러 주세요. 7일차에는 큰 보상이 있어요!';

  @override
  String dayShort(int day) {
    return '$day일';
  }

  @override
  String claimCoins(int coins) {
    return '$coins 받기';
  }

  @override
  String get dailyDoubleQuick => '광고 보고 ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return '광고 보고 $coins 받기';
  }

  @override
  String get dailyDoubleCalm => '짧은 광고로 두 배 받기';

  @override
  String get todaysGoals => '오늘의 목표';

  @override
  String get goalsHint => '매일 새로운 목표가 생겨요. 코인은 자동으로 지급돼요.';

  @override
  String get achievements => '업적';

  @override
  String achievementsCount(int have, int total) {
    return '업적  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$total개 중 $have개 달성 · 각 +$reward 코인';
  }

  @override
  String achievementToast(String title, int reward) {
    return '업적 달성: $title  +$reward 코인';
  }

  @override
  String missionToast(String title, int reward) {
    return '목표 완료: $title  +$reward 코인';
  }

  @override
  String levelLabel(int number) {
    return '레벨 $number';
  }

  @override
  String comboSub(int combo) {
    return '콤보 ×$combo';
  }

  @override
  String get dragHint => '블록을 보드로 끌어다 놓으세요';

  @override
  String get doubleCoinsQuick => '광고 보고 코인 ×2';

  @override
  String doubleCoinsProgress(int coins) {
    return '광고 보고 +$coins 코인';
  }

  @override
  String get doubleCoinsCalm => '짧은 광고로 코인 두 배';

  @override
  String get noMoreMoves => '더 이상 둘 곳이 없어요';

  @override
  String get newBest => '최고 기록 경신!';

  @override
  String get wellPlayed => '잘했어요. 잠깐 숨을 고르세요.';

  @override
  String summaryBest(int best) {
    return '최고 $best';
  }

  @override
  String summaryLines(int count) {
    return '$count줄';
  }

  @override
  String summaryCombo(int combo) {
    return '×$combo 콤보';
  }

  @override
  String levelUpLine(int level, int coins) {
    return '레벨 업! 레벨 $level  (+$coins 코인)';
  }

  @override
  String get nextLevel => '다음 레벨';

  @override
  String get tryAgain => '다시 하기';

  @override
  String get map => '지도';

  @override
  String levelComplete(int number) {
    return '레벨 $number 클리어!';
  }

  @override
  String get noPiecesFit => '놓을 수 있는 조각이 없어요.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% 완료';
  }

  @override
  String winStreakBonus(int streak) {
    return '$streak연승: 보너스 코인!';
  }

  @override
  String get praiseNice => '좋아요!';

  @override
  String get praiseGreat => '훌륭해요!';

  @override
  String get praiseExcellent => '최고예요!';

  @override
  String get praiseAmazing => '대단해요!';

  @override
  String get praiseIncredible => '믿을 수 없어요!';

  @override
  String get praiseLegendary => '전설이에요!';

  @override
  String get praisePerfect => '퍼펙트 클리어!';

  @override
  String get continueClassic => '클래식 이어하기';

  @override
  String get classic => '클래식';

  @override
  String journeyLevel(int level) {
    return '여정 · 레벨 $level';
  }

  @override
  String get newClassicGame => '새 클래식 게임';

  @override
  String get daily => '출석';

  @override
  String get spin => '돌리기';

  @override
  String get goals => '목표';

  @override
  String get themes => '테마';

  @override
  String get journey => '여정';

  @override
  String get spinning => '돌아가는 중…';

  @override
  String get extraSpinOffer => '짧은 광고를 보고 한 번 더 돌리세요.\n상품은 무작위: 10~200 코인.';

  @override
  String get watchAdSpin => '광고 보고 돌리기';

  @override
  String get comeBackTomorrow => '내일 다시 오세요';

  @override
  String get dailySpin => '일일 룰렛';

  @override
  String youWonCoins(int coins) {
    return '$coins 코인 획득!';
  }

  @override
  String get freeDailySpin => '매일 무료 1회: 10~200 코인';

  @override
  String freeCoinsOffer(int coins, int left) {
    return '짧은 광고를 보고 무료 코인 $coins개 받기 (오늘 $left번 남음)';
  }

  @override
  String get freeCoinsTomorrow => '무료 코인은 내일 다시 받을 수 있어요';

  @override
  String get inUse => '사용 중';

  @override
  String get use => '사용';

  @override
  String get themeDawn => '라벤더 새벽';

  @override
  String get themeOcean => '고요한 바다';

  @override
  String get themeForest => '숲속 이끼';

  @override
  String get themeSunset => '노을빛';

  @override
  String get themeNight => '한밤의 별';

  @override
  String get themeSakura => '벚꽃 산들바람';

  @override
  String journeyStreak(int streak, int percent) {
    return '$streak연승 중: 다음 승리 시 코인 +$percent%';
  }

  @override
  String playLevel(int level) {
    return '레벨 $level 플레이';
  }

  @override
  String goalScore(int target) {
    return '$target점 달성';
  }

  @override
  String goalGems(int count) {
    return '보석 $count개 모으기';
  }

  @override
  String missionClearLines(int count) {
    return '$count줄 지우기';
  }

  @override
  String missionScore(int target) {
    return '한 게임에서 $target점 달성';
  }

  @override
  String missionCombo(int target) {
    return '×$target 콤보 달성';
  }

  @override
  String missionPlayGames(int count) {
    return '게임 $count판 하기';
  }

  @override
  String missionPlaceBlocks(int count) {
    return '블록 $count개 놓기';
  }

  @override
  String get missionPerfect => '보드를 모두 비우기';

  @override
  String get achFirstBlock => '첫걸음';

  @override
  String get achFirstBlockDesc => '첫 블록 놓기';

  @override
  String get achFirstLine => '한 줄 완성';

  @override
  String get achFirstLineDesc => '처음으로 줄 지우기';

  @override
  String get achDouble => '더블';

  @override
  String get achDoubleDesc => '블록 하나로 2줄 지우기';

  @override
  String get achTriple => '트리플';

  @override
  String get achTripleDesc => '블록 하나로 3줄 지우기';

  @override
  String get achCombo3 => '흐름 타기';

  @override
  String get achCombo3Desc => '×3 콤보 달성';

  @override
  String get achCombo6 => '콤보 마스터';

  @override
  String get achCombo6Desc => '×6 콤보 달성';

  @override
  String get achPerfect => '깨끗하게';

  @override
  String get achPerfectDesc => '보드를 모두 비우기';

  @override
  String get achScore1k => '천 점 클럽';

  @override
  String get achScore1kDesc => '한 게임에서 1,000점 달성';

  @override
  String get achScore5k => '하이 플라이어';

  @override
  String get achScore5kDesc => '한 게임에서 5,000점 달성';

  @override
  String get achLines500 => '줄 수집가';

  @override
  String get achLines500Desc => '총 500줄 지우기';

  @override
  String get achJourney5 => '여정의 시작';

  @override
  String get achJourney5Desc => '여정 레벨 5 클리어';

  @override
  String get achJourney25 => '방랑자';

  @override
  String get achJourney25Desc => '여정 레벨 25 클리어';

  @override
  String get achStars30 => '별 관찰자';

  @override
  String get achStars30Desc => '여정에서 별 30개 획득';

  @override
  String get achGems50 => '보석 사냥꾼';

  @override
  String get achGems50Desc => '보석 총 50개 모으기';

  @override
  String get achStreak7 => '매일의 습관';

  @override
  String get achStreak7Desc => '7일 연속 접속';

  @override
  String get couldNotStart => 'Calm Grid를 시작할 수 없어요:';

  @override
  String get somethingWrong => '문제가 발생했어요 (개발자에게 보낼 스크린샷을 찍어 주세요)';
}
