// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class L10nId extends L10n {
  L10nId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Selesai';

  @override
  String get home => 'Beranda';

  @override
  String get settings => 'Setelan';

  @override
  String get pause => 'Jeda';

  @override
  String get noThanks => 'Tidak, terima kasih';

  @override
  String get reviveQuickTitle => 'Lanjutkan?';

  @override
  String get reviveQuickBody =>
      'Tonton iklan singkat untuk mengosongkan ruang dan terus bermain.';

  @override
  String get reviveCloseTitle => 'Sedikit lagi!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Kamu sudah mencapai $percent% dari rekormu ($best). Tonton iklan singkat untuk melanjutkan permainan ini.';
  }

  @override
  String get reviveGreatTitle => 'Permainan hebat!';

  @override
  String reviveGreatBody(int score) {
    return 'Kamu punya $score poin. Tonton iklan singkat untuk melanjutkan permainan ini.';
  }

  @override
  String get reviveCalmTitle => 'Tarik napas';

  @override
  String get reviveCalmBody =>
      'Santai saja. Kalau mau, iklan singkat akan mengosongkan ruang supaya kamu bisa lanjut.';

  @override
  String get watchAdContinue => 'Tonton iklan & lanjutkan';

  @override
  String get adNotFinished =>
      'Iklan tidak selesai, jadi kali ini tidak bisa lanjut.';

  @override
  String get paused => 'Dijeda';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get restart => 'Mulai ulang';

  @override
  String get sound => 'Suara';

  @override
  String get music => 'Musik';

  @override
  String get vibrate => 'Getar';

  @override
  String get privacyOptions => 'Opsi privasi';

  @override
  String get rateGame => 'Beri rating Calm Grid';

  @override
  String dayStreak(int days) {
    return 'Beruntun $days hari';
  }

  @override
  String rewardCollected(int day) {
    return 'Hadiah hari ini sudah diambil. Kembali besok untuk hadiah hari ke-$day.';
  }

  @override
  String get dailyReward => 'Hadiah harian';

  @override
  String get dailyRewardHint =>
      'Kembali setiap hari: hadiah hari ke-7 paling besar!';

  @override
  String dayShort(int day) {
    return 'H$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Ambil $coins';
  }

  @override
  String get dailyDoubleQuick => 'Tonton iklan: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Tonton iklan: dapat $coins';
  }

  @override
  String get dailyDoubleCalm => 'Gandakan dengan iklan singkat';

  @override
  String get todaysGoals => 'Target hari ini';

  @override
  String get goalsHint => 'Target baru setiap hari. Koin dibayar otomatis.';

  @override
  String get achievements => 'Pencapaian';

  @override
  String achievementsCount(int have, int total) {
    return 'Pencapaian  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have dari $total terbuka · +$reward koin per pencapaian';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Pencapaian: $title  +$reward koin';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Target selesai: $title  +$reward koin';
  }

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String comboSub(int combo) {
    return 'Kombo ×$combo';
  }

  @override
  String get dragHint => 'Seret blok ke papan';

  @override
  String get doubleCoinsQuick => 'Tonton iklan: koin ×2';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Tonton iklan: +$coins koin';
  }

  @override
  String get doubleCoinsCalm => 'Gandakan koin dengan iklan singkat';

  @override
  String get noMoreMoves => 'Tidak ada langkah lagi';

  @override
  String get newBest => 'Rekor baru!';

  @override
  String get wellPlayed => 'Permainan bagus. Tarik napas.';

  @override
  String summaryBest(int best) {
    return 'Rekor $best';
  }

  @override
  String summaryLines(int count) {
    return '$count baris';
  }

  @override
  String summaryCombo(int combo) {
    return 'kombo ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Naik level! Level $level  (+$coins koin)';
  }

  @override
  String get nextLevel => 'Level berikutnya';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get map => 'Peta';

  @override
  String levelComplete(int number) {
    return 'Level $number selesai!';
  }

  @override
  String get noPiecesFit => 'Tidak ada keping yang muat.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% selesai';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Menang beruntun ×$streak: bonus koin!';
  }

  @override
  String get praiseNice => 'Bagus!';

  @override
  String get praiseGreat => 'Hebat!';

  @override
  String get praiseExcellent => 'Luar biasa!';

  @override
  String get praiseAmazing => 'Mengagumkan!';

  @override
  String get praiseIncredible => 'Sulit dipercaya!';

  @override
  String get praiseLegendary => 'Legendaris!';

  @override
  String get praisePerfect => 'Papan bersih!';

  @override
  String get continueClassic => 'Lanjutkan Klasik';

  @override
  String get classic => 'Klasik';

  @override
  String journeyLevel(int level) {
    return 'Petualangan · Level $level';
  }

  @override
  String get newClassicGame => 'Permainan klasik baru';

  @override
  String get daily => 'Harian';

  @override
  String get spin => 'Putar';

  @override
  String get goals => 'Target';

  @override
  String get themes => 'Tema';

  @override
  String get journey => 'Petualangan';

  @override
  String get spinning => 'Berputar…';

  @override
  String get extraSpinOffer =>
      'Tonton iklan singkat untuk satu putaran lagi.\nHadiahnya acak: 10 sampai 200 koin.';

  @override
  String get watchAdSpin => 'Tonton iklan & putar';

  @override
  String get comeBackTomorrow => 'Kembali besok';

  @override
  String get dailySpin => 'Putaran harian';

  @override
  String youWonCoins(int coins) {
    return 'Kamu menang $coins koin!';
  }

  @override
  String get freeDailySpin => 'Putaran gratis setiap hari: 10 sampai 200 koin';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Tonton iklan singkat untuk $coins koin gratis (sisa $left hari ini)';
  }

  @override
  String get freeCoinsTomorrow => 'Koin gratis kembali besok';

  @override
  String get inUse => 'Dipakai';

  @override
  String get use => 'Pakai';

  @override
  String get themeDawn => 'Fajar Lavender';

  @override
  String get themeOcean => 'Samudra Tenang';

  @override
  String get themeForest => 'Lumut Hutan';

  @override
  String get themeSunset => 'Cahaya Senja';

  @override
  String get themeNight => 'Bintang Tengah Malam';

  @override
  String get themeSakura => 'Semilir Sakura';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Menang beruntun $streak: +$percent% koin di kemenangan berikutnya';
  }

  @override
  String playLevel(int level) {
    return 'Mainkan level $level';
  }

  @override
  String goalScore(int target) {
    return 'Raih $target poin';
  }

  @override
  String goalGems(int count) {
    return 'Kumpulkan $count permata';
  }

  @override
  String missionClearLines(int count) {
    return 'Hapus $count baris';
  }

  @override
  String missionScore(int target) {
    return 'Raih $target poin dalam satu permainan';
  }

  @override
  String missionCombo(int target) {
    return 'Capai kombo ×$target';
  }

  @override
  String missionPlayGames(int count) {
    return 'Mainkan $count permainan';
  }

  @override
  String missionPlaceBlocks(int count) {
    return 'Letakkan $count blok';
  }

  @override
  String get missionPerfect => 'Kosongkan seluruh papan';

  @override
  String get achFirstBlock => 'Langkah pertama';

  @override
  String get achFirstBlockDesc => 'Letakkan blok pertamamu';

  @override
  String get achFirstLine => 'Sebaris';

  @override
  String get achFirstLineDesc => 'Hapus baris pertamamu';

  @override
  String get achDouble => 'Dobel';

  @override
  String get achDoubleDesc => 'Hapus 2 baris dengan satu blok';

  @override
  String get achTriple => 'Tripel';

  @override
  String get achTripleDesc => 'Hapus 3 baris dengan satu blok';

  @override
  String get achCombo3 => 'Lagi lancar';

  @override
  String get achCombo3Desc => 'Capai kombo ×3';

  @override
  String get achCombo6 => 'Master kombo';

  @override
  String get achCombo6Desc => 'Capai kombo ×6';

  @override
  String get achPerfect => 'Bersih total';

  @override
  String get achPerfectDesc => 'Kosongkan seluruh papan';

  @override
  String get achScore1k => 'Klub seribu';

  @override
  String get achScore1kDesc => 'Raih 1.000 poin dalam satu permainan';

  @override
  String get achScore5k => 'Terbang tinggi';

  @override
  String get achScore5kDesc => 'Raih 5.000 poin dalam satu permainan';

  @override
  String get achLines500 => 'Kolektor baris';

  @override
  String get achLines500Desc => 'Hapus total 500 baris';

  @override
  String get achJourney5 => 'Di perjalanan';

  @override
  String get achJourney5Desc => 'Selesaikan level 5 Petualangan';

  @override
  String get achJourney25 => 'Pengelana';

  @override
  String get achJourney25Desc => 'Selesaikan level 25 Petualangan';

  @override
  String get achStars30 => 'Pengamat bintang';

  @override
  String get achStars30Desc => 'Dapatkan 30 bintang di Petualangan';

  @override
  String get achGems50 => 'Pemburu permata';

  @override
  String get achGems50Desc => 'Kumpulkan total 50 permata';

  @override
  String get achStreak7 => 'Kebiasaan harian';

  @override
  String get achStreak7Desc => 'Masuk 7 hari berturut-turut';

  @override
  String get couldNotStart => 'Calm Grid gagal dibuka:';

  @override
  String get somethingWrong =>
      'Terjadi kesalahan (ambil tangkapan layar untuk pengembang)';
}
