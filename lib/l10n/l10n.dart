import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import '../game/game_state.dart';
import '../game/level.dart';
import '../services/achievements.dart';
import '../services/progression.dart';
import '../ui/game_theme.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Translations live in lib/l10n/app_`language`.arb (English is the
/// template). `flutter pub get` regenerates app_localizations*.dart.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  L10n.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);
}

extension AchievementText on Achievement {
  String titleIn(L10n l) => switch (this) {
    Achievement.firstBlock => l.achFirstBlock,
    Achievement.firstLine => l.achFirstLine,
    Achievement.double => l.achDouble,
    Achievement.triple => l.achTriple,
    Achievement.combo3 => l.achCombo3,
    Achievement.combo6 => l.achCombo6,
    Achievement.perfect => l.achPerfect,
    Achievement.score1k => l.achScore1k,
    Achievement.score5k => l.achScore5k,
    Achievement.lines500 => l.achLines500,
    Achievement.journey5 => l.achJourney5,
    Achievement.journey25 => l.achJourney25,
    Achievement.stars30 => l.achStars30,
    Achievement.gems50 => l.achGems50,
    Achievement.streak7 => l.achStreak7,
  };

  String descriptionIn(L10n l) => switch (this) {
    Achievement.firstBlock => l.achFirstBlockDesc,
    Achievement.firstLine => l.achFirstLineDesc,
    Achievement.double => l.achDoubleDesc,
    Achievement.triple => l.achTripleDesc,
    Achievement.combo3 => l.achCombo3Desc,
    Achievement.combo6 => l.achCombo6Desc,
    Achievement.perfect => l.achPerfectDesc,
    Achievement.score1k => l.achScore1kDesc,
    Achievement.score5k => l.achScore5kDesc,
    Achievement.lines500 => l.achLines500Desc,
    Achievement.journey5 => l.achJourney5Desc,
    Achievement.journey25 => l.achJourney25Desc,
    Achievement.stars30 => l.achStars30Desc,
    Achievement.gems50 => l.achGems50Desc,
    Achievement.streak7 => l.achStreak7Desc,
  };
}

extension MissionText on Mission {
  String titleIn(L10n l) => switch (type) {
    MissionType.clearLines => l.missionClearLines(target),
    MissionType.scoreInGame => l.missionScore(target),
    MissionType.comboInGame => l.missionCombo(target),
    MissionType.playGames => l.missionPlayGames(target),
    MissionType.placePieces => l.missionPlaceBlocks(target),
    MissionType.perfectClear => l.missionPerfect,
  };
}

extension LevelText on LevelSpec {
  String goalTextIn(L10n l) =>
      goal == LevelGoal.score ? l.goalScore(target) : l.goalGems(target);
}

extension PraiseText on PlaceEvent {
  /// Big praise shown after a clear; it grows with the lines cleared.
  String? praiseIn(L10n l) {
    if (perfect) return l.praisePerfect;
    return switch (lines) {
      0 => null,
      1 => l.praiseNice,
      2 => l.praiseGreat,
      3 => l.praiseExcellent,
      4 => l.praiseAmazing,
      5 => l.praiseIncredible,
      _ => l.praiseLegendary,
    };
  }
}

extension ThemeText on GameTheme {
  String nameIn(L10n l) => switch (id) {
    'dawn' => l.themeDawn,
    'ocean' => l.themeOcean,
    'forest' => l.themeForest,
    'sunset' => l.themeSunset,
    'night' => l.themeNight,
    'sakura' => l.themeSakura,
    _ => name,
  };
}
