// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class L10nIt extends L10n {
  L10nIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fatto';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Impostazioni';

  @override
  String get pause => 'Pausa';

  @override
  String get noThanks => 'No, grazie';

  @override
  String get reviveQuickTitle => 'Continuare?';

  @override
  String get reviveQuickBody =>
      'Guarda una breve pubblicità per liberare spazio e continuare a giocare.';

  @override
  String get reviveCloseTitle => 'Ci sei quasi!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Sei al $percent% del tuo record ($best). Guarda una breve pubblicità per continuare questa partita.';
  }

  @override
  String get reviveGreatTitle => 'Ottima partita!';

  @override
  String reviveGreatBody(int score) {
    return 'Hai $score punti. Guarda una breve pubblicità per continuare questa partita.';
  }

  @override
  String get reviveCalmTitle => 'Fai un bel respiro';

  @override
  String get reviveCalmBody =>
      'Nessuna fretta. Se vuoi, una breve pubblicità libererà spazio per farti continuare.';

  @override
  String get watchAdContinue => 'Guarda la pubblicità e continua';

  @override
  String get adNotFinished =>
      'La pubblicità non è terminata, quindi stavolta niente seconda possibilità.';

  @override
  String get paused => 'In pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String get restart => 'Ricomincia';

  @override
  String get sound => 'Suono';

  @override
  String get music => 'Musica';

  @override
  String get vibrate => 'Vibrazione';

  @override
  String get privacyOptions => 'Opzioni privacy';

  @override
  String get rateGame => 'Valuta Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Serie di $days giorni',
      one: 'Serie di 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'Hai già riscattato la ricompensa di oggi. Torna domani per il giorno $day.';
  }

  @override
  String get dailyReward => 'Ricompensa giornaliera';

  @override
  String get dailyRewardHint => 'Torna ogni giorno: il giorno 7 è speciale!';

  @override
  String dayShort(int day) {
    return 'G$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Riscatta $coins';
  }

  @override
  String get dailyDoubleQuick => 'Guarda pubblicità: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Guarda pubblicità: ottieni $coins';
  }

  @override
  String get dailyDoubleCalm => 'Raddoppia con una breve pubblicità';

  @override
  String get todaysGoals => 'Obiettivi di oggi';

  @override
  String get goalsHint =>
      'Nuovi obiettivi ogni giorno. Le monete vengono pagate in automatico.';

  @override
  String get achievements => 'Traguardi';

  @override
  String achievementsCount(int have, int total) {
    return 'Traguardi  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have su $total sbloccati · +$reward monete ciascuno';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Traguardo: $title  +$reward monete';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Obiettivo completato: $title  +$reward monete';
  }

  @override
  String levelLabel(int number) {
    return 'Livello $number';
  }

  @override
  String comboSub(int combo) {
    return 'Combo ×$combo';
  }

  @override
  String get dragHint => 'Trascina un blocco sulla griglia';

  @override
  String get doubleCoinsQuick => 'Guarda pubblicità: monete ×2';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Guarda pubblicità: +$coins monete';
  }

  @override
  String get doubleCoinsCalm => 'Raddoppia le monete con una breve pubblicità';

  @override
  String get noMoreMoves => 'Nessuna mossa possibile';

  @override
  String get newBest => 'Nuovo record!';

  @override
  String get wellPlayed => 'Ben giocato. Fai un bel respiro.';

  @override
  String summaryBest(int best) {
    return 'Record $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linee',
      one: '1 linea',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return 'combo ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Livello superiore! Livello $level  (+$coins monete)';
  }

  @override
  String get nextLevel => 'Livello successivo';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get map => 'Mappa';

  @override
  String levelComplete(int number) {
    return 'Livello $number completato!';
  }

  @override
  String get noPiecesFit => 'Nessuno dei tuoi pezzi ci sta.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% completato';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Serie di vittorie ×$streak: monete bonus!';
  }

  @override
  String get praiseNice => 'Bene!';

  @override
  String get praiseGreat => 'Ottimo!';

  @override
  String get praiseExcellent => 'Eccellente!';

  @override
  String get praiseAmazing => 'Fantastico!';

  @override
  String get praiseIncredible => 'Incredibile!';

  @override
  String get praiseLegendary => 'Leggendario!';

  @override
  String get praisePerfect => 'Griglia pulita!';

  @override
  String get continueClassic => 'Continua Classica';

  @override
  String get classic => 'Classica';

  @override
  String journeyLevel(int level) {
    return 'Viaggio · Livello $level';
  }

  @override
  String get newClassicGame => 'Nuova partita classica';

  @override
  String get daily => 'Ogni giorno';

  @override
  String get spin => 'Gira';

  @override
  String get goals => 'Obiettivi';

  @override
  String get themes => 'Temi';

  @override
  String get journey => 'Viaggio';

  @override
  String get spinning => 'Gira…';

  @override
  String get extraSpinOffer =>
      'Guarda una breve pubblicità per un altro giro.\nIl premio è casuale: da 10 a 200 monete.';

  @override
  String get watchAdSpin => 'Guarda pubblicità e gira';

  @override
  String get comeBackTomorrow => 'Torna domani';

  @override
  String get dailySpin => 'Ruota del giorno';

  @override
  String youWonCoins(int coins) {
    return 'Hai vinto $coins monete!';
  }

  @override
  String get freeDailySpin => 'Un giro gratis al giorno: da 10 a 200 monete';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Guarda una breve pubblicità per $coins monete gratis (ancora $left oggi)';
  }

  @override
  String get freeCoinsTomorrow => 'Le monete gratis tornano domani';

  @override
  String get inUse => 'In uso';

  @override
  String get use => 'Usa';

  @override
  String get themeDawn => 'Alba di lavanda';

  @override
  String get themeOcean => 'Oceano calmo';

  @override
  String get themeForest => 'Muschio del bosco';

  @override
  String get themeSunset => 'Bagliore del tramonto';

  @override
  String get themeNight => 'Stelle di mezzanotte';

  @override
  String get themeSakura => 'Brezza di sakura';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Serie di vittorie $streak: +$percent% di monete alla prossima vittoria';
  }

  @override
  String playLevel(int level) {
    return 'Gioca il livello $level';
  }

  @override
  String goalScore(int target) {
    return 'Fai $target punti';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raccogli $count gemme',
      one: 'Raccogli 1 gemma',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completa $count linee',
      one: 'Completa 1 linea',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Fai $target punti in una partita';
  }

  @override
  String missionCombo(int target) {
    return 'Raggiungi una combo ×$target';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gioca $count partite',
      one: 'Gioca 1 partita',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Posiziona $count blocchi',
      one: 'Posiziona 1 blocco',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Svuota tutta la griglia';

  @override
  String get achFirstBlock => 'Primi passi';

  @override
  String get achFirstBlockDesc => 'Posiziona il tuo primo blocco';

  @override
  String get achFirstLine => 'In linea';

  @override
  String get achFirstLineDesc => 'Completa la tua prima linea';

  @override
  String get achDouble => 'Doppietta';

  @override
  String get achDoubleDesc => 'Completa 2 linee con un blocco';

  @override
  String get achTriple => 'Tripletta';

  @override
  String get achTripleDesc => 'Completa 3 linee con un blocco';

  @override
  String get achCombo3 => 'Nel ritmo';

  @override
  String get achCombo3Desc => 'Raggiungi una combo ×3';

  @override
  String get achCombo6 => 'Maestro delle combo';

  @override
  String get achCombo6Desc => 'Raggiungi una combo ×6';

  @override
  String get achPerfect => 'Tabula rasa';

  @override
  String get achPerfectDesc => 'Svuota tutta la griglia';

  @override
  String get achScore1k => 'Club dei mille';

  @override
  String get achScore1kDesc => 'Fai 1.000 punti in una partita';

  @override
  String get achScore5k => 'Alta quota';

  @override
  String get achScore5kDesc => 'Fai 5.000 punti in una partita';

  @override
  String get achLines500 => 'Collezionista di linee';

  @override
  String get achLines500Desc => 'Completa 500 linee in totale';

  @override
  String get achJourney5 => 'In cammino';

  @override
  String get achJourney5Desc => 'Completa il livello 5 del Viaggio';

  @override
  String get achJourney25 => 'Viandante';

  @override
  String get achJourney25Desc => 'Completa il livello 25 del Viaggio';

  @override
  String get achStars30 => 'Osservatore di stelle';

  @override
  String get achStars30Desc => 'Ottieni 30 stelle nel Viaggio';

  @override
  String get achGems50 => 'Cacciatore di gemme';

  @override
  String get achGems50Desc => 'Raccogli 50 gemme in totale';

  @override
  String get achStreak7 => 'Abitudine quotidiana';

  @override
  String get achStreak7Desc => 'Gioca 7 giorni di fila';

  @override
  String get couldNotStart => 'Impossibile avviare Calm Grid:';

  @override
  String get somethingWrong =>
      'Qualcosa è andato storto (fai uno screenshot per lo sviluppatore)';
}
