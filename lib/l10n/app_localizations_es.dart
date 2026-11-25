// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get ok => 'Aceptar';

  @override
  String get done => 'Listo';

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Ajustes';

  @override
  String get pause => 'Pausa';

  @override
  String get noThanks => 'No, gracias';

  @override
  String get reviveQuickTitle => '¿Continuar?';

  @override
  String get reviveQuickBody =>
      'Mira un anuncio corto para liberar espacio y seguir jugando.';

  @override
  String get reviveCloseTitle => '¡Casi lo logras!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Llevas el $percent% de tu récord ($best). Mira un anuncio corto para seguir con esta partida.';
  }

  @override
  String get reviveGreatTitle => '¡Gran partida!';

  @override
  String reviveGreatBody(int score) {
    return 'Llevas $score puntos. Mira un anuncio corto para seguir con esta partida.';
  }

  @override
  String get reviveCalmTitle => 'Respira hondo';

  @override
  String get reviveCalmBody =>
      'Sin prisa. Si quieres, un anuncio corto liberará espacio para que puedas continuar.';

  @override
  String get watchAdContinue => 'Ver anuncio y continuar';

  @override
  String get adNotFinished =>
      'El anuncio no terminó, así que esta vez no hay segunda oportunidad.';

  @override
  String get paused => 'En pausa';

  @override
  String get resume => 'Reanudar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get sound => 'Sonido';

  @override
  String get music => 'Música';

  @override
  String get vibrate => 'Vibración';

  @override
  String get privacyOptions => 'Opciones de privacidad';

  @override
  String get rateGame => 'Valorar Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Racha de $days días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'Ya recogiste la recompensa de hoy. Vuelve mañana por la del día $day.';
  }

  @override
  String get dailyReward => 'Recompensa diaria';

  @override
  String get dailyRewardHint =>
      'Vuelve cada día: ¡el día 7 trae un gran premio!';

  @override
  String dayShort(int day) {
    return 'D$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Recoger $coins';
  }

  @override
  String get dailyDoubleQuick => 'Ver anuncio: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Ver anuncio: recibe $coins';
  }

  @override
  String get dailyDoubleCalm => 'Duplícalo con un anuncio corto';

  @override
  String get todaysGoals => 'Objetivos de hoy';

  @override
  String get goalsHint =>
      'Nuevos objetivos cada día. Las monedas se pagan automáticamente.';

  @override
  String get achievements => 'Logros';

  @override
  String achievementsCount(int have, int total) {
    return 'Logros  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have de $total desbloqueados · +$reward monedas cada uno';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Logro: $title  +$reward monedas';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Objetivo cumplido: $title  +$reward monedas';
  }

  @override
  String levelLabel(int number) {
    return 'Nivel $number';
  }

  @override
  String comboSub(int combo) {
    return 'Combo ×$combo';
  }

  @override
  String get dragHint => 'Arrastra un bloque al tablero';

  @override
  String get doubleCoinsQuick => 'Ver anuncio: ×2 monedas';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Ver anuncio: +$coins monedas';
  }

  @override
  String get doubleCoinsCalm => 'Duplica las monedas con un anuncio corto';

  @override
  String get noMoreMoves => 'No quedan movimientos';

  @override
  String get newBest => '¡Nuevo récord!';

  @override
  String get wellPlayed => 'Bien jugado. Respira hondo.';

  @override
  String summaryBest(int best) {
    return 'Récord $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas',
      one: '1 línea',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return 'combo ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return '¡Subiste de nivel! Nivel $level  (+$coins monedas)';
  }

  @override
  String get nextLevel => 'Siguiente nivel';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get map => 'Mapa';

  @override
  String levelComplete(int number) {
    return '¡Nivel $number completado!';
  }

  @override
  String get noPiecesFit => 'Ninguna de tus piezas cabe.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% hecho';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Racha de victorias ×$streak: ¡monedas extra!';
  }

  @override
  String get praiseNice => '¡Bien!';

  @override
  String get praiseGreat => '¡Genial!';

  @override
  String get praiseExcellent => '¡Excelente!';

  @override
  String get praiseAmazing => '¡Increíble!';

  @override
  String get praiseIncredible => '¡Asombroso!';

  @override
  String get praiseLegendary => '¡Legendario!';

  @override
  String get praisePerfect => '¡Tablero limpio!';

  @override
  String get continueClassic => 'Continuar Clásico';

  @override
  String get classic => 'Clásico';

  @override
  String journeyLevel(int level) {
    return 'Viaje · Nivel $level';
  }

  @override
  String get newClassicGame => 'Nueva partida clásica';

  @override
  String get daily => 'Diario';

  @override
  String get spin => 'Girar';

  @override
  String get goals => 'Objetivos';

  @override
  String get themes => 'Temas';

  @override
  String get journey => 'Viaje';

  @override
  String get spinning => 'Girando…';

  @override
  String get extraSpinOffer =>
      'Mira un anuncio corto para girar una vez más.\nEl premio es aleatorio: de 10 a 200 monedas.';

  @override
  String get watchAdSpin => 'Ver anuncio y girar';

  @override
  String get comeBackTomorrow => 'Vuelve mañana';

  @override
  String get dailySpin => 'Ruleta diaria';

  @override
  String youWonCoins(int coins) {
    return '¡Ganaste $coins monedas!';
  }

  @override
  String get freeDailySpin => 'Giro diario gratis: de 10 a 200 monedas';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Mira un anuncio corto y gana $coins monedas gratis (quedan $left hoy)';
  }

  @override
  String get freeCoinsTomorrow => 'Las monedas gratis vuelven mañana';

  @override
  String get inUse => 'En uso';

  @override
  String get use => 'Usar';

  @override
  String get themeDawn => 'Amanecer lavanda';

  @override
  String get themeOcean => 'Océano en calma';

  @override
  String get themeForest => 'Musgo del bosque';

  @override
  String get themeSunset => 'Brillo del atardecer';

  @override
  String get themeNight => 'Estrellas de medianoche';

  @override
  String get themeSakura => 'Brisa de sakura';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Racha de victorias $streak: +$percent% de monedas en tu próxima victoria';
  }

  @override
  String playLevel(int level) {
    return 'Jugar nivel $level';
  }

  @override
  String goalScore(int target) {
    return 'Consigue $target puntos';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recoge $count gemas',
      one: 'Recoge 1 gema',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completa $count líneas',
      one: 'Completa 1 línea',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Consigue $target puntos en una partida';
  }

  @override
  String missionCombo(int target) {
    return 'Logra un combo ×$target';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Juega $count partidas',
      one: 'Juega 1 partida',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Coloca $count bloques',
      one: 'Coloca 1 bloque',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Vacía todo el tablero';

  @override
  String get achFirstBlock => 'Primeros pasos';

  @override
  String get achFirstBlockDesc => 'Coloca tu primer bloque';

  @override
  String get achFirstLine => 'En línea';

  @override
  String get achFirstLineDesc => 'Completa tu primera línea';

  @override
  String get achDouble => 'Doble';

  @override
  String get achDoubleDesc => 'Completa 2 líneas con un bloque';

  @override
  String get achTriple => 'Triple';

  @override
  String get achTripleDesc => 'Completa 3 líneas con un bloque';

  @override
  String get achCombo3 => 'En racha';

  @override
  String get achCombo3Desc => 'Logra un combo ×3';

  @override
  String get achCombo6 => 'Maestro del combo';

  @override
  String get achCombo6Desc => 'Logra un combo ×6';

  @override
  String get achPerfect => 'Borrón y cuenta nueva';

  @override
  String get achPerfectDesc => 'Vacía todo el tablero';

  @override
  String get achScore1k => 'Club de los mil';

  @override
  String get achScore1kDesc => 'Consigue 1000 puntos en una partida';

  @override
  String get achScore5k => 'Por las nubes';

  @override
  String get achScore5kDesc => 'Consigue 5000 puntos en una partida';

  @override
  String get achLines500 => 'Coleccionista de líneas';

  @override
  String get achLines500Desc => 'Completa 500 líneas en total';

  @override
  String get achJourney5 => 'En camino';

  @override
  String get achJourney5Desc => 'Completa el nivel 5 del Viaje';

  @override
  String get achJourney25 => 'Trotamundos';

  @override
  String get achJourney25Desc => 'Completa el nivel 25 del Viaje';

  @override
  String get achStars30 => 'Cazaestrellas';

  @override
  String get achStars30Desc => 'Consigue 30 estrellas en el Viaje';

  @override
  String get achGems50 => 'Cazagemas';

  @override
  String get achGems50Desc => 'Recoge 50 gemas en total';

  @override
  String get achStreak7 => 'Hábito diario';

  @override
  String get achStreak7Desc => 'Entra 7 días seguidos';

  @override
  String get couldNotStart => 'Calm Grid no pudo iniciarse:';

  @override
  String get somethingWrong =>
      'Algo salió mal (haz una captura para el desarrollador)';
}
