import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:calm_grid/ads/ad_service.dart';
import 'package:calm_grid/app/app_scope.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/level.dart';
import 'package:calm_grid/game/piece.dart';
import 'package:calm_grid/l10n/l10n.dart';
import 'package:calm_grid/main.dart';
import 'package:calm_grid/services/achievements.dart';
import 'package:calm_grid/services/progression.dart';
import 'package:calm_grid/ui/game_screen.dart';
import 'package:calm_grid/ui/game_theme.dart';
import 'package:calm_grid/ui/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_test.dart' show makeServices, playUntilLost, setScreen;

Map<String, dynamic> readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> placeholders(String message) => {
  for (final m in RegExp(r'\{(\w+)[},]').allMatches(message)) m.group(1)!,
};

/// Makes the test device report [locale], like a phone set to that language.
void useLocale(WidgetTester tester, Locale locale) {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

void main() {
  test('every language has every message, with the same placeholders', () {
    final en = readArb('lib/l10n/app_en.arb');
    final keys = en.keys.where((k) => !k.startsWith('@')).toList();
    final files = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .toList();
    expect(files.length, L10n.supportedLocales.length);
    for (final f in files) {
      final arb = readArb(f.path);
      for (final k in keys) {
        expect(arb[k], isA<String>(), reason: '${f.path} is missing $k');
        expect(
          placeholders(arb[k] as String).containsAll(placeholders(en[k])),
          isTrue,
          reason: '${f.path}: $k lost a placeholder',
        );
      }
    }
  });

  test('English text matches the game\'s own wording', () {
    final l = lookupL10n(const Locale('en'));
    PlaceEvent ev(int lines, {bool perfect = false}) => PlaceEvent(
      id: 1,
      placedCells: const {},
      colorIndex: 0,
      clearedColors: const {},
      lines: lines,
      combo: 1,
      points: 0,
      perfect: perfect,
      origin: const Cell(0, 0),
    );
    for (var lines = 0; lines <= 6; lines++) {
      expect(ev(lines).praiseIn(l), ev(lines).praise);
    }
    expect(ev(2, perfect: true).praiseIn(l), ev(2, perfect: true).praise);
    for (final a in Achievement.values) {
      expect(a.titleIn(l), a.title);
      expect(a.descriptionIn(l), a.description);
    }
    for (final type in MissionType.values) {
      final m = Mission(type, 20, 50);
      expect(m.titleIn(l), m.title);
    }
    for (var n = 1; n <= 12; n++) {
      final level = LevelSpec.generate(n);
      expect(level.goalTextIn(l), level.goalText);
    }
    for (final t in GameTheme.all) {
      expect(t.nameIn(l), t.name);
    }
  });

  for (final locale in L10n.supportedLocales) {
    final lang = locale.languageCode;

    testWidgets('$lang: home, menus and dialogs fit a small phone', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 568));
      useLocale(tester, locale);
      final l = lookupL10n(locale);
      final services = makeServices();
      await tester.pumpWidget(CalmGridApp(services: services));
      await tester.pump();
      expect(find.text(l.classic), findsOneWidget);

      // Scrolls to the button first, as a player would on a small screen.
      Future<void> open(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pump();
        await tester.tap(f);
        // A new page's first frame is built offstage; the second shows it.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      }

      await open(find.text(l.goals));
      expect(find.text(l.todaysGoals), findsOneWidget);
      await open(find.textContaining(l.achievements));
      expect(find.text(l.achievements), findsOneWidget);
      await open(find.widgetWithText(SoftButton, l.ok));

      await open(find.text(l.daily));
      expect(find.text(l.dailyReward), findsOneWidget);
      await open(find.widgetWithText(SoftButton, l.claimCoins(20)));

      await open(find.byTooltip(l.settings));
      expect(find.text(l.settings), findsOneWidget);
      await open(find.widgetWithText(SoftButton, l.done));

      await open(find.text(l.spin));
      expect(find.text(l.dailySpin), findsOneWidget);
      await open(find.text(l.close).last);

      await open(find.text(l.themes));
      expect(find.text(l.inUse), findsOneWidget);
      await open(find.byTooltip(l.back));

      await open(find.text(l.journeyLevel(1)));
      expect(find.text(l.playLevel(1)), findsOneWidget);
      await open(find.byTooltip(l.back));

      await tester.tap(find.text(l.classic));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byTooltip(l.pause), findsOneWidget);
      expect(find.text(l.dragHint), findsOneWidget);
      // Overflows (text too long for its box) fail the test automatically.
    });

    testWidgets('$lang: losing, the revive offer and game over fit', (
      tester,
    ) async {
      setScreen(tester, const Size(320, 568));
      useLocale(tester, locale);
      final l = lookupL10n(locale);
      final services = makeServices();
      final game = GameState(random: Random(1));
      await tester.pumpWidget(
        AppScope(
          services: services,
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: GameScreen(game: game),
          ),
        ),
      );
      playUntilLost(game, Random(7));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text(l.noMoreMoves), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text(l.watchAdContinue), findsOneWidget);
      await tester.tap(find.text(l.noThanks));
      await tester.pumpAndSettle();
      expect(find.text(l.tryAgain), findsOneWidget);
      expect(find.textContaining(l.summaryBest(game.score)), findsOneWidget);
      expect(services.offers.ads, isA<SimulatedAdService>());
    });
  }
}
