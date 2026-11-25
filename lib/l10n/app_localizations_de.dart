// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fertig';

  @override
  String get home => 'Start';

  @override
  String get settings => 'Einstellungen';

  @override
  String get pause => 'Pause';

  @override
  String get noThanks => 'Nein danke';

  @override
  String get reviveQuickTitle => 'Weiterspielen?';

  @override
  String get reviveQuickBody =>
      'Sieh dir eine kurze Werbung an, um Platz zu schaffen und weiterzuspielen.';

  @override
  String get reviveCloseTitle => 'So knapp!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Du hast $percent % deines Rekords ($best) erreicht. Sieh dir eine kurze Werbung an, um diese Runde fortzusetzen.';
  }

  @override
  String get reviveGreatTitle => 'Starke Runde!';

  @override
  String reviveGreatBody(int score) {
    return 'Du hast $score Punkte. Sieh dir eine kurze Werbung an, um diese Runde fortzusetzen.';
  }

  @override
  String get reviveCalmTitle => 'Durchatmen';

  @override
  String get reviveCalmBody =>
      'Keine Eile. Wenn du möchtest, schafft eine kurze Werbung Platz, damit du weiterspielen kannst.';

  @override
  String get watchAdContinue => 'Werbung ansehen & weiter';

  @override
  String get adNotFinished =>
      'Die Werbung wurde nicht zu Ende gesehen, daher geht es diesmal nicht weiter.';

  @override
  String get paused => 'Pausiert';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get restart => 'Neustart';

  @override
  String get sound => 'Ton';

  @override
  String get music => 'Musik';

  @override
  String get vibrate => 'Vibration';

  @override
  String get privacyOptions => 'Datenschutzoptionen';

  @override
  String get rateGame => 'Calm Grid bewerten';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage in Folge',
      one: '1 Tag in Folge',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'Die heutige Belohnung ist abgeholt. Komm morgen für Tag $day wieder.';
  }

  @override
  String get dailyReward => 'Tagesbelohnung';

  @override
  String get dailyRewardHint =>
      'Komm jeden Tag wieder: Tag 7 ist etwas Besonderes!';

  @override
  String dayShort(int day) {
    return 'T$day';
  }

  @override
  String claimCoins(int coins) {
    return '$coins abholen';
  }

  @override
  String get dailyDoubleQuick => 'Werbung ansehen: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Werbung ansehen: $coins erhalten';
  }

  @override
  String get dailyDoubleCalm => 'Mit kurzer Werbung verdoppeln';

  @override
  String get todaysGoals => 'Heutige Ziele';

  @override
  String get goalsHint =>
      'Jeden Tag neue Ziele. Münzen werden automatisch ausgezahlt.';

  @override
  String get achievements => 'Erfolge';

  @override
  String achievementsCount(int have, int total) {
    return 'Erfolge  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have von $total freigeschaltet · je +$reward Münzen';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Erfolg: $title  +$reward Münzen';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Ziel erreicht: $title  +$reward Münzen';
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
  String get dragHint => 'Zieh einen Block auf das Spielfeld';

  @override
  String get doubleCoinsQuick => 'Werbung ansehen: ×2 Münzen';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Werbung ansehen: +$coins Münzen';
  }

  @override
  String get doubleCoinsCalm => 'Münzen mit kurzer Werbung verdoppeln';

  @override
  String get noMoreMoves => 'Keine Züge mehr';

  @override
  String get newBest => 'Neuer Rekord!';

  @override
  String get wellPlayed => 'Gut gespielt. Atme kurz durch.';

  @override
  String summaryBest(int best) {
    return 'Rekord $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reihen',
      one: '1 Reihe',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return '×$combo Kombo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Levelaufstieg! Level $level  (+$coins Münzen)';
  }

  @override
  String get nextLevel => 'Nächstes Level';

  @override
  String get tryAgain => 'Nochmal';

  @override
  String get map => 'Karte';

  @override
  String levelComplete(int number) {
    return 'Level $number geschafft!';
  }

  @override
  String get noPiecesFit => 'Keiner deiner Steine passt mehr.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent % geschafft';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Siegesserie ×$streak: Bonusmünzen!';
  }

  @override
  String get praiseNice => 'Gut!';

  @override
  String get praiseGreat => 'Super!';

  @override
  String get praiseExcellent => 'Exzellent!';

  @override
  String get praiseAmazing => 'Großartig!';

  @override
  String get praiseIncredible => 'Unglaublich!';

  @override
  String get praiseLegendary => 'Legendär!';

  @override
  String get praisePerfect => 'Feld leer!';

  @override
  String get continueClassic => 'Klassisch fortsetzen';

  @override
  String get classic => 'Klassisch';

  @override
  String journeyLevel(int level) {
    return 'Reise · Level $level';
  }

  @override
  String get newClassicGame => 'Neues klassisches Spiel';

  @override
  String get daily => 'Täglich';

  @override
  String get spin => 'Drehen';

  @override
  String get goals => 'Ziele';

  @override
  String get themes => 'Designs';

  @override
  String get journey => 'Reise';

  @override
  String get spinning => 'Dreht sich…';

  @override
  String get extraSpinOffer =>
      'Sieh dir eine kurze Werbung für eine weitere Drehung an.\nDer Gewinn ist zufällig: 10 bis 200 Münzen.';

  @override
  String get watchAdSpin => 'Werbung ansehen & drehen';

  @override
  String get comeBackTomorrow => 'Komm morgen wieder';

  @override
  String get dailySpin => 'Tägliches Glücksrad';

  @override
  String youWonCoins(int coins) {
    return 'Du hast $coins Münzen gewonnen!';
  }

  @override
  String get freeDailySpin => 'Jeden Tag gratis drehen: 10 bis 200 Münzen';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Sieh dir eine kurze Werbung für $coins Gratismünzen an (heute noch $left)';
  }

  @override
  String get freeCoinsTomorrow => 'Gratismünzen gibt es morgen wieder';

  @override
  String get inUse => 'Aktiv';

  @override
  String get use => 'Verwenden';

  @override
  String get themeDawn => 'Lavendelmorgen';

  @override
  String get themeOcean => 'Ruhiger Ozean';

  @override
  String get themeForest => 'Waldmoos';

  @override
  String get themeSunset => 'Abendrot';

  @override
  String get themeNight => 'Mitternachtssterne';

  @override
  String get themeSakura => 'Kirschblütenbrise';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Siegesserie $streak: +$percent % Münzen beim nächsten Sieg';
  }

  @override
  String playLevel(int level) {
    return 'Level $level spielen';
  }

  @override
  String goalScore(int target) {
    return 'Erziele $target Punkte';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sammle $count Edelsteine',
      one: 'Sammle 1 Edelstein',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Räume $count Reihen ab',
      one: 'Räume 1 Reihe ab',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Erziele $target Punkte in einem Spiel';
  }

  @override
  String missionCombo(int target) {
    return 'Erreiche eine ×$target Kombo';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spiele $count Runden',
      one: 'Spiele 1 Runde',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Setze $count Blöcke',
      one: 'Setze 1 Block',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Räume das ganze Feld ab';

  @override
  String get achFirstBlock => 'Erste Schritte';

  @override
  String get achFirstBlockDesc => 'Setze deinen ersten Block';

  @override
  String get achFirstLine => 'In Reih und Glied';

  @override
  String get achFirstLineDesc => 'Räume deine erste Reihe ab';

  @override
  String get achDouble => 'Doppelpack';

  @override
  String get achDoubleDesc => 'Räume 2 Reihen mit einem Block ab';

  @override
  String get achTriple => 'Dreierpack';

  @override
  String get achTripleDesc => 'Räume 3 Reihen mit einem Block ab';

  @override
  String get achCombo3 => 'Im Fluss';

  @override
  String get achCombo3Desc => 'Erreiche eine ×3 Kombo';

  @override
  String get achCombo6 => 'Kombo-Meister';

  @override
  String get achCombo6Desc => 'Erreiche eine ×6 Kombo';

  @override
  String get achPerfect => 'Reiner Tisch';

  @override
  String get achPerfectDesc => 'Räume das ganze Feld ab';

  @override
  String get achScore1k => 'Tausender-Club';

  @override
  String get achScore1kDesc => 'Erziele 1.000 Punkte in einem Spiel';

  @override
  String get achScore5k => 'Höhenflug';

  @override
  String get achScore5kDesc => 'Erziele 5.000 Punkte in einem Spiel';

  @override
  String get achLines500 => 'Reihensammler';

  @override
  String get achLines500Desc => 'Räume insgesamt 500 Reihen ab';

  @override
  String get achJourney5 => 'Auf dem Weg';

  @override
  String get achJourney5Desc => 'Schließe Level 5 der Reise ab';

  @override
  String get achJourney25 => 'Weltenbummler';

  @override
  String get achJourney25Desc => 'Schließe Level 25 der Reise ab';

  @override
  String get achStars30 => 'Sternengucker';

  @override
  String get achStars30Desc => 'Verdiene 30 Sterne auf der Reise';

  @override
  String get achGems50 => 'Edelsteinjäger';

  @override
  String get achGems50Desc => 'Sammle insgesamt 50 Edelsteine';

  @override
  String get achStreak7 => 'Tägliche Gewohnheit';

  @override
  String get achStreak7Desc => 'Spiele 7 Tage in Folge';

  @override
  String get couldNotStart => 'Calm Grid konnte nicht starten:';

  @override
  String get somethingWrong =>
      'Etwas ist schiefgelaufen (bitte einen Screenshot für den Entwickler machen)';
}
