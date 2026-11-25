// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class L10nTr extends L10n {
  L10nTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get ok => 'Tamam';

  @override
  String get done => 'Bitti';

  @override
  String get home => 'Ana sayfa';

  @override
  String get settings => 'Ayarlar';

  @override
  String get pause => 'Duraklat';

  @override
  String get noThanks => 'Hayır, teşekkürler';

  @override
  String get reviveQuickTitle => 'Devam edilsin mi?';

  @override
  String get reviveQuickBody =>
      'Yer açmak ve oynamaya devam etmek için kısa bir reklam izle.';

  @override
  String get reviveCloseTitle => 'Çok yaklaştın!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Rekorunun %$percent kadarına ulaştın ($best). Bu oyuna devam etmek için kısa bir reklam izle.';
  }

  @override
  String get reviveGreatTitle => 'Harika oyun!';

  @override
  String reviveGreatBody(int score) {
    return '$score puanın var. Bu oyuna devam etmek için kısa bir reklam izle.';
  }

  @override
  String get reviveCalmTitle => 'Derin bir nefes al';

  @override
  String get reviveCalmBody =>
      'Acele yok. İstersen kısa bir reklam yer açar ve devam edebilirsin.';

  @override
  String get watchAdContinue => 'Reklam izle ve devam et';

  @override
  String get adNotFinished =>
      'Reklam bitmediği için bu sefer devam edilemiyor.';

  @override
  String get paused => 'Duraklatıldı';

  @override
  String get resume => 'Devam et';

  @override
  String get restart => 'Yeniden başla';

  @override
  String get sound => 'Ses';

  @override
  String get music => 'Müzik';

  @override
  String get vibrate => 'Titreşim';

  @override
  String get privacyOptions => 'Gizlilik seçenekleri';

  @override
  String get rateGame => 'Calm Grid\'i değerlendir';

  @override
  String dayStreak(int days) {
    return '$days günlük seri';
  }

  @override
  String rewardCollected(int day) {
    return 'Bugünün ödülü alındı. $day. günün ödülü için yarın tekrar gel.';
  }

  @override
  String get dailyReward => 'Günlük ödül';

  @override
  String get dailyRewardHint => 'Her gün gel: 7. günde büyük ödül var!';

  @override
  String dayShort(int day) {
    return 'G$day';
  }

  @override
  String claimCoins(int coins) {
    return '$coins al';
  }

  @override
  String get dailyDoubleQuick => 'Reklam izle: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Reklam izle: $coins kazan';
  }

  @override
  String get dailyDoubleCalm => 'Kısa bir reklamla ikiye katla';

  @override
  String get todaysGoals => 'Bugünün hedefleri';

  @override
  String get goalsHint =>
      'Her gün yeni hedefler. Altınlar otomatik olarak verilir.';

  @override
  String get achievements => 'Başarımlar';

  @override
  String achievementsCount(int have, int total) {
    return 'Başarımlar  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$total başarımdan $have tanesi açıldı · her biri +$reward altın';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Başarım: $title  +$reward altın';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Hedef tamamlandı: $title  +$reward altın';
  }

  @override
  String levelLabel(int number) {
    return 'Seviye $number';
  }

  @override
  String comboSub(int combo) {
    return 'Kombo ×$combo';
  }

  @override
  String get dragHint => 'Bir bloğu tahtaya sürükle';

  @override
  String get doubleCoinsQuick => 'Reklam izle: ×2 altın';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Reklam izle: +$coins altın';
  }

  @override
  String get doubleCoinsCalm => 'Kısa bir reklamla altınları ikiye katla';

  @override
  String get noMoreMoves => 'Hamle kalmadı';

  @override
  String get newBest => 'Yeni rekor!';

  @override
  String get wellPlayed => 'İyi oyundu. Derin bir nefes al.';

  @override
  String summaryBest(int best) {
    return 'Rekor $best';
  }

  @override
  String summaryLines(int count) {
    return '$count satır';
  }

  @override
  String summaryCombo(int combo) {
    return '×$combo kombo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Seviye atladın! Seviye $level  (+$coins altın)';
  }

  @override
  String get nextLevel => 'Sonraki seviye';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get map => 'Harita';

  @override
  String levelComplete(int number) {
    return 'Seviye $number tamamlandı!';
  }

  @override
  String get noPiecesFit => 'Parçalarından hiçbiri sığmıyor.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: %$percent tamamlandı';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Galibiyet serisi ×$streak: bonus altın!';
  }

  @override
  String get praiseNice => 'Güzel!';

  @override
  String get praiseGreat => 'Harika!';

  @override
  String get praiseExcellent => 'Mükemmel!';

  @override
  String get praiseAmazing => 'Muhteşem!';

  @override
  String get praiseIncredible => 'İnanılmaz!';

  @override
  String get praiseLegendary => 'Efsanevi!';

  @override
  String get praisePerfect => 'Tahta temizlendi!';

  @override
  String get continueClassic => 'Klasik\'e devam et';

  @override
  String get classic => 'Klasik';

  @override
  String journeyLevel(int level) {
    return 'Yolculuk · Seviye $level';
  }

  @override
  String get newClassicGame => 'Yeni klasik oyun';

  @override
  String get daily => 'Günlük';

  @override
  String get spin => 'Çevir';

  @override
  String get goals => 'Hedefler';

  @override
  String get themes => 'Temalar';

  @override
  String get journey => 'Yolculuk';

  @override
  String get spinning => 'Dönüyor…';

  @override
  String get extraSpinOffer =>
      'Bir kez daha çevirmek için kısa bir reklam izle.\nÖdül rastgele: 10 ile 200 altın arası.';

  @override
  String get watchAdSpin => 'Reklam izle ve çevir';

  @override
  String get comeBackTomorrow => 'Yarın tekrar gel';

  @override
  String get dailySpin => 'Günlük çark';

  @override
  String youWonCoins(int coins) {
    return '$coins altın kazandın!';
  }

  @override
  String get freeDailySpin =>
      'Her gün ücretsiz çevirme: 10 ile 200 altın arası';

  @override
  String freeCoinsOffer(int coins, int left) {
    return '$coins ücretsiz altın için kısa bir reklam izle (bugün $left hakkın kaldı)';
  }

  @override
  String get freeCoinsTomorrow => 'Ücretsiz altınlar yarın geri geliyor';

  @override
  String get inUse => 'Kullanımda';

  @override
  String get use => 'Kullan';

  @override
  String get themeDawn => 'Lavanta Şafağı';

  @override
  String get themeOcean => 'Sakin Okyanus';

  @override
  String get themeForest => 'Orman Yosunu';

  @override
  String get themeSunset => 'Gün Batımı';

  @override
  String get themeNight => 'Gece Yarısı Yıldızları';

  @override
  String get themeSakura => 'Sakura Esintisi';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Galibiyet serisi $streak: sonraki galibiyette +%$percent altın';
  }

  @override
  String playLevel(int level) {
    return '$level. seviyeyi oyna';
  }

  @override
  String goalScore(int target) {
    return '$target puan yap';
  }

  @override
  String goalGems(int count) {
    return '$count mücevher topla';
  }

  @override
  String missionClearLines(int count) {
    return '$count satır temizle';
  }

  @override
  String missionScore(int target) {
    return 'Bir oyunda $target puan yap';
  }

  @override
  String missionCombo(int target) {
    return '×$target kombo yap';
  }

  @override
  String missionPlayGames(int count) {
    return '$count oyun oyna';
  }

  @override
  String missionPlaceBlocks(int count) {
    return '$count blok yerleştir';
  }

  @override
  String get missionPerfect => 'Tüm tahtayı temizle';

  @override
  String get achFirstBlock => 'İlk adımlar';

  @override
  String get achFirstBlockDesc => 'İlk bloğunu yerleştir';

  @override
  String get achFirstLine => 'Sıraya gir';

  @override
  String get achFirstLineDesc => 'İlk satırını temizle';

  @override
  String get achDouble => 'Çifte vuruş';

  @override
  String get achDoubleDesc => 'Tek blokla 2 satır temizle';

  @override
  String get achTriple => 'Üçlü vuruş';

  @override
  String get achTripleDesc => 'Tek blokla 3 satır temizle';

  @override
  String get achCombo3 => 'Akışta';

  @override
  String get achCombo3Desc => '×3 kombo yap';

  @override
  String get achCombo6 => 'Kombo ustası';

  @override
  String get achCombo6Desc => '×6 kombo yap';

  @override
  String get achPerfect => 'Tertemiz';

  @override
  String get achPerfectDesc => 'Tüm tahtayı temizle';

  @override
  String get achScore1k => 'Binler kulübü';

  @override
  String get achScore1kDesc => 'Bir oyunda 1.000 puan yap';

  @override
  String get achScore5k => 'Yükseklerde';

  @override
  String get achScore5kDesc => 'Bir oyunda 5.000 puan yap';

  @override
  String get achLines500 => 'Satır koleksiyoncusu';

  @override
  String get achLines500Desc => 'Toplam 500 satır temizle';

  @override
  String get achJourney5 => 'Yolda';

  @override
  String get achJourney5Desc => 'Yolculuğun 5. seviyesini tamamla';

  @override
  String get achJourney25 => 'Gezgin';

  @override
  String get achJourney25Desc => 'Yolculuğun 25. seviyesini tamamla';

  @override
  String get achStars30 => 'Yıldız gözlemcisi';

  @override
  String get achStars30Desc => 'Yolculukta 30 yıldız kazan';

  @override
  String get achGems50 => 'Mücevher avcısı';

  @override
  String get achGems50Desc => 'Toplam 50 mücevher topla';

  @override
  String get achStreak7 => 'Günlük alışkanlık';

  @override
  String get achStreak7Desc => '7 gün üst üste giriş yap';

  @override
  String get couldNotStart => 'Calm Grid başlatılamadı:';

  @override
  String get somethingWrong =>
      'Bir şeyler ters gitti (geliştirici için ekran görüntüsü al)';
}
