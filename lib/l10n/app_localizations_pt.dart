// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Pronto';

  @override
  String get home => 'Início';

  @override
  String get settings => 'Configurações';

  @override
  String get pause => 'Pausar';

  @override
  String get noThanks => 'Não, obrigado';

  @override
  String get reviveQuickTitle => 'Continuar?';

  @override
  String get reviveQuickBody =>
      'Assista a um anúncio curto para liberar espaço e continuar jogando.';

  @override
  String get reviveCloseTitle => 'Quase lá!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Você chegou a $percent% do seu recorde ($best). Assista a um anúncio curto para continuar esta partida.';
  }

  @override
  String get reviveGreatTitle => 'Ótima partida!';

  @override
  String reviveGreatBody(int score) {
    return 'Você tem $score pontos. Assista a um anúncio curto para continuar esta partida.';
  }

  @override
  String get reviveCalmTitle => 'Respire fundo';

  @override
  String get reviveCalmBody =>
      'Sem pressa. Se quiser, um anúncio curto libera espaço para você continuar.';

  @override
  String get watchAdContinue => 'Ver anúncio e continuar';

  @override
  String get adNotFinished =>
      'O anúncio não terminou, então desta vez não dá para continuar.';

  @override
  String get paused => 'Pausado';

  @override
  String get resume => 'Continuar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get sound => 'Som';

  @override
  String get music => 'Música';

  @override
  String get vibrate => 'Vibração';

  @override
  String get privacyOptions => 'Opções de privacidade';

  @override
  String get rateGame => 'Avaliar o Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sequência de $days dias',
      one: 'Sequência de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'A recompensa de hoje já foi coletada. Volte amanhã para a do dia $day.';
  }

  @override
  String get dailyReward => 'Recompensa diária';

  @override
  String get dailyRewardHint => 'Volte todo dia: o dia 7 é especial!';

  @override
  String dayShort(int day) {
    return 'D$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Coletar $coins';
  }

  @override
  String get dailyDoubleQuick => 'Ver anúncio: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Ver anúncio: ganhe $coins';
  }

  @override
  String get dailyDoubleCalm => 'Dobre com um anúncio curto';

  @override
  String get todaysGoals => 'Metas de hoje';

  @override
  String get goalsHint =>
      'Novas metas todo dia. As moedas são pagas automaticamente.';

  @override
  String get achievements => 'Conquistas';

  @override
  String achievementsCount(int have, int total) {
    return 'Conquistas  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    return '$have de $total desbloqueadas · +$reward moedas cada';
  }

  @override
  String achievementToast(String title, int reward) {
    return 'Conquista: $title  +$reward moedas';
  }

  @override
  String missionToast(String title, int reward) {
    return 'Meta concluída: $title  +$reward moedas';
  }

  @override
  String levelLabel(int number) {
    return 'Nível $number';
  }

  @override
  String comboSub(int combo) {
    return 'Combo ×$combo';
  }

  @override
  String get dragHint => 'Arraste um bloco para o tabuleiro';

  @override
  String get doubleCoinsQuick => 'Ver anúncio: ×2 moedas';

  @override
  String doubleCoinsProgress(int coins) {
    return 'Ver anúncio: +$coins moedas';
  }

  @override
  String get doubleCoinsCalm => 'Dobre as moedas com um anúncio curto';

  @override
  String get noMoreMoves => 'Sem jogadas possíveis';

  @override
  String get newBest => 'Novo recorde!';

  @override
  String get wellPlayed => 'Boa partida. Respire fundo.';

  @override
  String summaryBest(int best) {
    return 'Recorde $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas',
      one: '1 linha',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return 'combo ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    return 'Subiu de nível! Nível $level  (+$coins moedas)';
  }

  @override
  String get nextLevel => 'Próximo nível';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get map => 'Mapa';

  @override
  String levelComplete(int number) {
    return 'Nível $number concluído!';
  }

  @override
  String get noPiecesFit => 'Nenhuma das suas peças cabe.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: $percent% feito';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Sequência de vitórias ×$streak: moedas bônus!';
  }

  @override
  String get praiseNice => 'Boa!';

  @override
  String get praiseGreat => 'Ótimo!';

  @override
  String get praiseExcellent => 'Excelente!';

  @override
  String get praiseAmazing => 'Incrível!';

  @override
  String get praiseIncredible => 'Sensacional!';

  @override
  String get praiseLegendary => 'Lendário!';

  @override
  String get praisePerfect => 'Tabuleiro limpo!';

  @override
  String get continueClassic => 'Continuar Clássico';

  @override
  String get classic => 'Clássico';

  @override
  String journeyLevel(int level) {
    return 'Jornada · Nível $level';
  }

  @override
  String get newClassicGame => 'Nova partida clássica';

  @override
  String get daily => 'Diário';

  @override
  String get spin => 'Girar';

  @override
  String get goals => 'Metas';

  @override
  String get themes => 'Temas';

  @override
  String get journey => 'Jornada';

  @override
  String get spinning => 'Girando…';

  @override
  String get extraSpinOffer =>
      'Assista a um anúncio curto para girar mais uma vez.\nO prêmio é aleatório: de 10 a 200 moedas.';

  @override
  String get watchAdSpin => 'Ver anúncio e girar';

  @override
  String get comeBackTomorrow => 'Volte amanhã';

  @override
  String get dailySpin => 'Roleta diária';

  @override
  String youWonCoins(int coins) {
    return 'Você ganhou $coins moedas!';
  }

  @override
  String get freeDailySpin => 'Giro diário grátis: de 10 a 200 moedas';

  @override
  String freeCoinsOffer(int coins, int left) {
    return 'Assista a um anúncio curto e ganhe $coins moedas grátis (restam $left hoje)';
  }

  @override
  String get freeCoinsTomorrow => 'As moedas grátis voltam amanhã';

  @override
  String get inUse => 'Em uso';

  @override
  String get use => 'Usar';

  @override
  String get themeDawn => 'Aurora Lavanda';

  @override
  String get themeOcean => 'Oceano Calmo';

  @override
  String get themeForest => 'Musgo da Floresta';

  @override
  String get themeSunset => 'Brilho do Entardecer';

  @override
  String get themeNight => 'Estrelas da Meia-Noite';

  @override
  String get themeSakura => 'Brisa de Sakura';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Sequência de vitórias $streak: +$percent% de moedas na próxima vitória';
  }

  @override
  String playLevel(int level) {
    return 'Jogar nível $level';
  }

  @override
  String goalScore(int target) {
    return 'Faça $target pontos';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colete $count gemas',
      one: 'Colete 1 gema',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complete $count linhas',
      one: 'Complete 1 linha',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    return 'Faça $target pontos em uma partida';
  }

  @override
  String missionCombo(int target) {
    return 'Faça um combo ×$target';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jogue $count partidas',
      one: 'Jogue 1 partida',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Coloque $count blocos',
      one: 'Coloque 1 bloco',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Esvazie o tabuleiro inteiro';

  @override
  String get achFirstBlock => 'Primeiros passos';

  @override
  String get achFirstBlockDesc => 'Coloque seu primeiro bloco';

  @override
  String get achFirstLine => 'Na linha';

  @override
  String get achFirstLineDesc => 'Complete sua primeira linha';

  @override
  String get achDouble => 'Em dobro';

  @override
  String get achDoubleDesc => 'Complete 2 linhas com um bloco';

  @override
  String get achTriple => 'Trinca';

  @override
  String get achTripleDesc => 'Complete 3 linhas com um bloco';

  @override
  String get achCombo3 => 'No embalo';

  @override
  String get achCombo3Desc => 'Faça um combo ×3';

  @override
  String get achCombo6 => 'Mestre do combo';

  @override
  String get achCombo6Desc => 'Faça um combo ×6';

  @override
  String get achPerfect => 'Tudo limpo';

  @override
  String get achPerfectDesc => 'Esvazie o tabuleiro inteiro';

  @override
  String get achScore1k => 'Clube dos mil';

  @override
  String get achScore1kDesc => 'Faça 1.000 pontos em uma partida';

  @override
  String get achScore5k => 'Nas alturas';

  @override
  String get achScore5kDesc => 'Faça 5.000 pontos em uma partida';

  @override
  String get achLines500 => 'Colecionador de linhas';

  @override
  String get achLines500Desc => 'Complete 500 linhas no total';

  @override
  String get achJourney5 => 'No caminho';

  @override
  String get achJourney5Desc => 'Conclua o nível 5 da Jornada';

  @override
  String get achJourney25 => 'Viajante';

  @override
  String get achJourney25Desc => 'Conclua o nível 25 da Jornada';

  @override
  String get achStars30 => 'Observador de estrelas';

  @override
  String get achStars30Desc => 'Ganhe 30 estrelas na Jornada';

  @override
  String get achGems50 => 'Caçador de gemas';

  @override
  String get achGems50Desc => 'Colete 50 gemas no total';

  @override
  String get achStreak7 => 'Hábito diário';

  @override
  String get achStreak7Desc => 'Entre 7 dias seguidos';

  @override
  String get couldNotStart => 'Não foi possível iniciar o Calm Grid:';

  @override
  String get somethingWrong =>
      'Algo deu errado (tire um print para o desenvolvedor)';
}
