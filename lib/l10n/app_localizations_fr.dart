// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Terminé';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Réglages';

  @override
  String get pause => 'Pause';

  @override
  String get noThanks => 'Non merci';

  @override
  String get reviveQuickTitle => 'Continuer ?';

  @override
  String get reviveQuickBody =>
      'Regardez une courte pub pour libérer de la place et continuer à jouer.';

  @override
  String get reviveCloseTitle => 'Si près du but !';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Vous êtes à $percent % de votre record ($best). Regardez une courte pub pour prolonger cette partie.';
  }

  @override
  String get reviveGreatTitle => 'Belle partie !';

  @override
  String reviveGreatBody(int score) {
    return 'Vous avez $score points. Regardez une courte pub pour prolonger cette partie.';
  }

  @override
  String get reviveCalmTitle => 'Respirez un instant';

  @override
  String get reviveCalmBody =>
      'Rien ne presse. Si vous le souhaitez, une courte pub libérera de la place pour continuer.';

  @override
  String get watchAdContinue => 'Voir une pub et continuer';

  @override
  String get adNotFinished =>
      'La pub ne s\'est pas terminée : pas de seconde chance cette fois.';

  @override
  String get paused => 'En pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get restart => 'Recommencer';

  @override
  String get sound => 'Son';

  @override
  String get music => 'Musique';

  @override
  String get vibrate => 'Vibration';

  @override
  String get privacyOptions => 'Options de confidentialité';

  @override
  String get rateGame => 'Noter Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Série de $days jours',
      one: 'Série de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'La récompense du jour est récupérée. Revenez demain pour le jour $day.';
  }

  @override
  String get dailyReward => 'Récompense du jour';

  @override
  String get dailyRewardHint =>
      'Revenez chaque jour : le 7e jour est spécial !';

  @override
  String dayShort(int day) {
    return 'J$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Récupérer $coins';
  }

  @override
  String get dailyDoubleQuick => 'Voir une pub : ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Voir une pub : obtenez $coins';
  }

  @override
  String get dailyDoubleCalm => 'Doublez-la avec une courte pub';

  @override
  String get todaysGoals => 'Objectifs du jour';

  @override
  String get goalsHint =>
      'De nouveaux objectifs chaque jour. Les pièces sont versées automatiquement.';

  @override
  String get achievements => 'Succès';

  @override
  String achievementsCount(int have, int total) {
    return 'Succès  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have sur $total débloqués · +$reward pièces chacun';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Succès : $title  +$reward pièces';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Objectif atteint : $title  +$reward pièces';
  }

  @override
  String levelLabel(int number) {
    return 'Niveau $number';
  }

  @override
  String comboSub(int combo) {
    return 'Combo ×$combo';
  }

  @override
  String get dragHint => 'Faites glisser un bloc sur la grille';

  @override
  String get doubleCoinsQuick => 'Voir une pub : pièces ×2';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Voir une pub : +$coins pièces';
  }

  @override
  String get doubleCoinsCalm => 'Doublez vos pièces avec une courte pub';

  @override
  String get noMoreMoves => 'Plus aucun coup possible';

  @override
  String get newBest => 'Nouveau record !';

  @override
  String get wellPlayed => 'Bien joué. Respirez un instant.';

  @override
  String summaryBest(int best) {
    return 'Record $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '1 ligne',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return 'combo ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Niveau supérieur ! Niveau $level  (+$coins pièces)';
  }

  @override
  String get nextLevel => 'Niveau suivant';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get map => 'Carte';

  @override
  String levelComplete(int number) {
    return 'Niveau $number terminé !';
  }

  @override
  String get noPiecesFit => 'Aucune de vos pièces ne rentre.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal : $percent % accompli';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Série de victoires ×$streak : pièces bonus !';
  }

  @override
  String get praiseNice => 'Bien !';

  @override
  String get praiseGreat => 'Super !';

  @override
  String get praiseExcellent => 'Excellent !';

  @override
  String get praiseAmazing => 'Génial !';

  @override
  String get praiseIncredible => 'Incroyable !';

  @override
  String get praiseLegendary => 'Légendaire !';

  @override
  String get praisePerfect => 'Grille vidée !';

  @override
  String get continueClassic => 'Continuer Classique';

  @override
  String get classic => 'Classique';

  @override
  String journeyLevel(int level) {
    return 'Voyage · Niveau $level';
  }

  @override
  String get newClassicGame => 'Nouvelle partie classique';

  @override
  String get daily => 'Du jour';

  @override
  String get spin => 'Tourner';

  @override
  String get goals => 'Objectifs';

  @override
  String get themes => 'Thèmes';

  @override
  String get journey => 'Voyage';

  @override
  String get spinning => 'Ça tourne…';

  @override
  String get extraSpinOffer =>
      'Regardez une courte pub pour un tour de plus.\nLe gain est aléatoire : de 10 à 200 pièces.';

  @override
  String get watchAdSpin => 'Voir une pub et tourner';

  @override
  String get comeBackTomorrow => 'Revenez demain';

  @override
  String get dailySpin => 'Roue du jour';

  @override
  String youWonCoins(int coins) {
    return 'Vous gagnez $coins pièces !';
  }

  @override
  String get freeDailySpin => 'Un tour gratuit par jour : de 10 à 200 pièces';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Regardez une courte pub pour $coins pièces gratuites (encore $left aujourd\'hui)';
  }

  @override
  String get freeCoinsTomorrow => 'Les pièces gratuites reviennent demain';

  @override
  String get inUse => 'Utilisé';

  @override
  String get use => 'Utiliser';

  @override
  String get themeDawn => 'Aube lavande';

  @override
  String get themeOcean => 'Océan paisible';

  @override
  String get themeForest => 'Mousse des bois';

  @override
  String get themeSunset => 'Lueur du couchant';

  @override
  String get themeNight => 'Étoiles de minuit';

  @override
  String get themeSakura => 'Brise de sakura';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Série de victoires $streak : +$percent % de pièces à la prochaine victoire';
  }

  @override
  String playLevel(int level) {
    return 'Jouer le niveau $level';
  }

  @override
  String goalScore(int target) {
    return 'Marquez $target points';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récoltez $count gemmes',
      one: 'Récoltez 1 gemme',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complétez $count lignes',
      one: 'Complétez 1 ligne',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Marquez $target points en une partie';
  }

  @override
  String missionCombo(int target) {
    return 'Atteignez un combo ×$target';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jouez $count parties',
      one: 'Jouez 1 partie',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Placez $count blocs',
      one: 'Placez 1 bloc',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Videz toute la grille';

  @override
  String get achFirstBlock => 'Premiers pas';

  @override
  String get achFirstBlockDesc => 'Placez votre premier bloc';

  @override
  String get achFirstLine => 'En ligne';

  @override
  String get achFirstLineDesc => 'Complétez votre première ligne';

  @override
  String get achDouble => 'Coup double';

  @override
  String get achDoubleDesc => 'Complétez 2 lignes avec un bloc';

  @override
  String get achTriple => 'Coup triple';

  @override
  String get achTripleDesc => 'Complétez 3 lignes avec un bloc';

  @override
  String get achCombo3 => 'Dans le rythme';

  @override
  String get achCombo3Desc => 'Atteignez un combo ×3';

  @override
  String get achCombo6 => 'Maître du combo';

  @override
  String get achCombo6Desc => 'Atteignez un combo ×6';

  @override
  String get achPerfect => 'Table rase';

  @override
  String get achPerfectDesc => 'Videz toute la grille';

  @override
  String get achScore1k => 'Club des mille';

  @override
  String get achScore1kDesc => 'Marquez 1 000 points en une partie';

  @override
  String get achScore5k => 'Haut vol';

  @override
  String get achScore5kDesc => 'Marquez 5 000 points en une partie';

  @override
  String get achLines500 => 'Collectionneur de lignes';

  @override
  String get achLines500Desc => 'Complétez 500 lignes au total';

  @override
  String get achJourney5 => 'En chemin';

  @override
  String get achJourney5Desc => 'Terminez le niveau 5 du Voyage';

  @override
  String get achJourney25 => 'Grand voyageur';

  @override
  String get achJourney25Desc => 'Terminez le niveau 25 du Voyage';

  @override
  String get achStars30 => 'Chasseur d\'étoiles';

  @override
  String get achStars30Desc => 'Gagnez 30 étoiles dans le Voyage';

  @override
  String get achGems50 => 'Chasseur de gemmes';

  @override
  String get achGems50Desc => 'Récoltez 50 gemmes au total';

  @override
  String get achStreak7 => 'Habitude quotidienne';

  @override
  String get achStreak7Desc => 'Venez jouer 7 jours d\'affilée';

  @override
  String get couldNotStart => 'Calm Grid n\'a pas pu démarrer :';

  @override
  String get somethingWrong =>
      'Un problème est survenu (faites une capture d\'écran pour le développeur)';
}
