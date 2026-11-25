// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Calm Grid';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get ok => 'ОК';

  @override
  String get done => 'Готово';

  @override
  String get home => 'Главная';

  @override
  String get settings => 'Настройки';

  @override
  String get pause => 'Пауза';

  @override
  String get noThanks => 'Нет, спасибо';

  @override
  String get reviveQuickTitle => 'Продолжить?';

  @override
  String get reviveQuickBody =>
      'Посмотрите короткую рекламу, чтобы освободить место и играть дальше.';

  @override
  String get reviveCloseTitle => 'Почти получилось!';

  @override
  String reviveCloseBody(int percent, int best) {
    return 'Вы набрали $percent% от своего рекорда ($best). Посмотрите короткую рекламу, чтобы продолжить эту игру.';
  }

  @override
  String get reviveGreatTitle => 'Отличная игра!';

  @override
  String reviveGreatBody(int score) {
    return 'Ваш счёт: $score. Посмотрите короткую рекламу, чтобы продолжить эту игру.';
  }

  @override
  String get reviveCalmTitle => 'Сделайте вдох';

  @override
  String get reviveCalmBody =>
      'Не спешите. Если хотите, короткая реклама освободит место, и вы сможете продолжить.';

  @override
  String get watchAdContinue => 'Смотреть рекламу и продолжить';

  @override
  String get adNotFinished =>
      'Реклама не была досмотрена, поэтому в этот раз продолжить нельзя.';

  @override
  String get paused => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get restart => 'Заново';

  @override
  String get sound => 'Звук';

  @override
  String get music => 'Музыка';

  @override
  String get vibrate => 'Вибрация';

  @override
  String get privacyOptions => 'Настройки конфиденциальности';

  @override
  String get rateGame => 'Оценить Calm Grid';

  @override
  String dayStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня подряд',
      many: '$days дней подряд',
      few: '$days дня подряд',
      one: '$days день подряд',
    );
    return '$_temp0';
  }

  @override
  String rewardCollected(int day) {
    return 'Сегодняшняя награда получена. Возвращайтесь завтра за наградой дня $day.';
  }

  @override
  String get dailyReward => 'Ежедневная награда';

  @override
  String get dailyRewardHint =>
      'Заходите каждый день: на 7-й день — большой подарок!';

  @override
  String dayShort(int day) {
    return 'Д$day';
  }

  @override
  String claimCoins(int coins) {
    return 'Забрать $coins';
  }

  @override
  String get dailyDoubleQuick => 'Смотреть рекламу: ×2';

  @override
  String dailyDoubleProgress(int coins) {
    return 'Смотреть рекламу: получить $coins';
  }

  @override
  String get dailyDoubleCalm => 'Удвоить за короткую рекламу';

  @override
  String get todaysGoals => 'Цели на сегодня';

  @override
  String get goalsHint =>
      'Новые цели каждый день. Монеты начисляются автоматически.';

  @override
  String get achievements => 'Достижения';

  @override
  String achievementsCount(int have, int total) {
    return 'Достижения  $have/$total';
  }

  @override
  String achievementsSummary(int have, int total, int reward) {
    String _temp0 = intl.Intl.pluralLogic(
      reward,
      locale: localeName,
      other: '$reward монеты',
      many: '$reward монет',
      few: '$reward монеты',
      one: '$reward монете',
    );
    return 'Открыто $have из $total · по $_temp0 за каждое';
  }

  @override
  String achievementToast(String title, int reward) {
    String _temp0 = intl.Intl.pluralLogic(
      reward,
      locale: localeName,
      other: '$reward монеты',
      many: '$reward монет',
      few: '$reward монеты',
      one: '$reward монета',
    );
    return 'Достижение: $title  +$_temp0';
  }

  @override
  String missionToast(String title, int reward) {
    String _temp0 = intl.Intl.pluralLogic(
      reward,
      locale: localeName,
      other: '$reward монеты',
      many: '$reward монет',
      few: '$reward монеты',
      one: '$reward монета',
    );
    return 'Цель выполнена: $title  +$_temp0';
  }

  @override
  String levelLabel(int number) {
    return 'Уровень $number';
  }

  @override
  String comboSub(int combo) {
    return 'Комбо ×$combo';
  }

  @override
  String get dragHint => 'Перетащите блок на поле';

  @override
  String get doubleCoinsQuick => 'Смотреть рекламу: монеты ×2';

  @override
  String doubleCoinsProgress(int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coins монеты',
      many: '$coins монет',
      few: '$coins монеты',
      one: '$coins монета',
    );
    return 'Смотреть рекламу: +$_temp0';
  }

  @override
  String get doubleCoinsCalm => 'Удвоить монеты за короткую рекламу';

  @override
  String get noMoreMoves => 'Ходов больше нет';

  @override
  String get newBest => 'Новый рекорд!';

  @override
  String get wellPlayed => 'Хорошая игра. Сделайте вдох.';

  @override
  String summaryBest(int best) {
    return 'Рекорд $best';
  }

  @override
  String summaryLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count линии',
      many: '$count линий',
      few: '$count линии',
      one: '$count линия',
    );
    return '$_temp0';
  }

  @override
  String summaryCombo(int combo) {
    return 'комбо ×$combo';
  }

  @override
  String levelUpLine(int level, int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coins монеты',
      many: '$coins монет',
      few: '$coins монеты',
      one: '$coins монета',
    );
    return 'Новый уровень! Уровень $level  (+$_temp0)';
  }

  @override
  String get nextLevel => 'Следующий уровень';

  @override
  String get tryAgain => 'Ещё раз';

  @override
  String get map => 'Карта';

  @override
  String levelComplete(int number) {
    return 'Уровень $number пройден!';
  }

  @override
  String get noPiecesFit => 'Ни одна фигура больше не помещается.';

  @override
  String goalProgress(String goal, int percent) {
    return '$goal: выполнено $percent%';
  }

  @override
  String winStreakBonus(int streak) {
    return 'Серия побед ×$streak: бонусные монеты!';
  }

  @override
  String get praiseNice => 'Неплохо!';

  @override
  String get praiseGreat => 'Отлично!';

  @override
  String get praiseExcellent => 'Превосходно!';

  @override
  String get praiseAmazing => 'Потрясающе!';

  @override
  String get praiseIncredible => 'Невероятно!';

  @override
  String get praiseLegendary => 'Легендарно!';

  @override
  String get praisePerfect => 'Поле очищено!';

  @override
  String get continueClassic => 'Продолжить классику';

  @override
  String get classic => 'Классика';

  @override
  String journeyLevel(int level) {
    return 'Путешествие · Уровень $level';
  }

  @override
  String get newClassicGame => 'Новая классическая игра';

  @override
  String get daily => 'Награда';

  @override
  String get spin => 'Крутить';

  @override
  String get goals => 'Цели';

  @override
  String get themes => 'Темы';

  @override
  String get journey => 'Путешествие';

  @override
  String get spinning => 'Крутится…';

  @override
  String get extraSpinOffer =>
      'Посмотрите короткую рекламу, чтобы крутить ещё раз.\nПриз случайный: от 10 до 200 монет.';

  @override
  String get watchAdSpin => 'Смотреть рекламу и крутить';

  @override
  String get comeBackTomorrow => 'Возвращайтесь завтра';

  @override
  String get dailySpin => 'Колесо дня';

  @override
  String youWonCoins(int coins) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coins монеты',
      many: '$coins монет',
      few: '$coins монеты',
      one: '$coins монету',
    );
    return 'Вы выиграли $_temp0!';
  }

  @override
  String get freeDailySpin =>
      'Бесплатное вращение каждый день: от 10 до 200 монет';

  @override
  String freeCoinsOffer(int coins, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      coins,
      locale: localeName,
      other: '$coins бесплатные монеты',
      many: '$coins бесплатных монет',
      few: '$coins бесплатные монеты',
      one: '$coins бесплатную монету',
    );
    return 'Посмотрите короткую рекламу и получите $_temp0 (осталось сегодня: $left)';
  }

  @override
  String get freeCoinsTomorrow => 'Бесплатные монеты вернутся завтра';

  @override
  String get inUse => 'Выбрана';

  @override
  String get use => 'Выбрать';

  @override
  String get themeDawn => 'Лавандовый рассвет';

  @override
  String get themeOcean => 'Спокойный океан';

  @override
  String get themeForest => 'Лесной мох';

  @override
  String get themeSunset => 'Закатное сияние';

  @override
  String get themeNight => 'Полночные звёзды';

  @override
  String get themeSakura => 'Бриз сакуры';

  @override
  String journeyStreak(int streak, int percent) {
    return 'Серия побед $streak: +$percent% монет за следующую победу';
  }

  @override
  String playLevel(int level) {
    return 'Играть уровень $level';
  }

  @override
  String goalScore(int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target очка',
      many: '$target очков',
      few: '$target очка',
      one: '$target очко',
    );
    return 'Наберите $_temp0';
  }

  @override
  String goalGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Соберите $count кристалла',
      many: 'Соберите $count кристаллов',
      few: 'Соберите $count кристалла',
      one: 'Соберите $count кристалл',
    );
    return '$_temp0';
  }

  @override
  String missionClearLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Соберите $count линии',
      many: 'Соберите $count линий',
      few: 'Соберите $count линии',
      one: 'Соберите $count линию',
    );
    return '$_temp0';
  }

  @override
  String missionScore(int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target очка',
      many: '$target очков',
      few: '$target очка',
      one: '$target очко',
    );
    return 'Наберите $_temp0 за одну игру';
  }

  @override
  String missionCombo(int target) {
    return 'Сделайте комбо ×$target';
  }

  @override
  String missionPlayGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сыграйте $count игры',
      many: 'Сыграйте $count игр',
      few: 'Сыграйте $count игры',
      one: 'Сыграйте $count игру',
    );
    return '$_temp0';
  }

  @override
  String missionPlaceBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Поставьте $count блока',
      many: 'Поставьте $count блоков',
      few: 'Поставьте $count блока',
      one: 'Поставьте $count блок',
    );
    return '$_temp0';
  }

  @override
  String get missionPerfect => 'Очистите всё поле';

  @override
  String get achFirstBlock => 'Первые шаги';

  @override
  String get achFirstBlockDesc => 'Поставьте свой первый блок';

  @override
  String get achFirstLine => 'В линию';

  @override
  String get achFirstLineDesc => 'Соберите свою первую линию';

  @override
  String get achDouble => 'Дубль';

  @override
  String get achDoubleDesc => 'Соберите 2 линии одним блоком';

  @override
  String get achTriple => 'Тройной удар';

  @override
  String get achTripleDesc => 'Соберите 3 линии одним блоком';

  @override
  String get achCombo3 => 'В потоке';

  @override
  String get achCombo3Desc => 'Сделайте комбо ×3';

  @override
  String get achCombo6 => 'Мастер комбо';

  @override
  String get achCombo6Desc => 'Сделайте комбо ×6';

  @override
  String get achPerfect => 'С чистого листа';

  @override
  String get achPerfectDesc => 'Очистите всё поле';

  @override
  String get achScore1k => 'Клуб тысячи';

  @override
  String get achScore1kDesc => 'Наберите 1000 очков за одну игру';

  @override
  String get achScore5k => 'Высокий полёт';

  @override
  String get achScore5kDesc => 'Наберите 5000 очков за одну игру';

  @override
  String get achLines500 => 'Собиратель линий';

  @override
  String get achLines500Desc => 'Соберите всего 500 линий';

  @override
  String get achJourney5 => 'В пути';

  @override
  String get achJourney5Desc => 'Пройдите 5-й уровень Путешествия';

  @override
  String get achJourney25 => 'Странник';

  @override
  String get achJourney25Desc => 'Пройдите 25-й уровень Путешествия';

  @override
  String get achStars30 => 'Звездочёт';

  @override
  String get achStars30Desc => 'Получите 30 звёзд в Путешествии';

  @override
  String get achGems50 => 'Охотник за кристаллами';

  @override
  String get achGems50Desc => 'Соберите всего 50 кристаллов';

  @override
  String get achStreak7 => 'Ежедневная привычка';

  @override
  String get achStreak7Desc => 'Заходите 7 дней подряд';

  @override
  String get couldNotStart => 'Не удалось запустить Calm Grid:';

  @override
  String get somethingWrong =>
      'Что-то пошло не так (сделайте скриншот для разработчика)';
}
