import 'dart:math';

import 'package:calm_grid/ads/ad_service.dart';
import 'package:calm_grid/app/app_scope.dart';
import 'package:calm_grid/audio/sound_service.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/game/level.dart';
import 'package:calm_grid/l10n/l10n.dart';
import 'package:calm_grid/main.dart';
import 'package:calm_grid/services/pacing.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/reward_offers.dart';
import 'package:calm_grid/services/review_prompter.dart';
import 'package:calm_grid/ui/board_painter.dart';
import 'package:calm_grid/ui/game_screen.dart';
import 'package:calm_grid/ui/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

AppServices makeServices({Map<String, Object>? stored}) {
  final profile = PlayerProfile(MemoryStore(stored));
  return AppServices(
    profile: profile,
    offers: RewardOffers(
      ads: SimulatedAdService(delay: Duration.zero),
      profile: profile,
      pacer: Pacer(random: Random(1)),
    ),
    sound: SilentSoundService(),
    review: NoReviewService(),
  );
}

Widget gameApp(AppServices services, GameState game) => AppScope(
  services: services,
  child: MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: GameScreen(game: game),
  ),
);

void playUntilLost(GameState game, Random rnd) {
  while (!game.isGameOver) {
    final moves = [
      for (var i = 0; i < GameState.traySize; i++)
        for (var r = 0; r < 8; r++)
          for (var c = 0; c < 8; c++)
            if (game.canPlace(i, r, c)) (i, r, c),
    ];
    final (i, r, c) = moves[rnd.nextInt(moves.length)];
    game.place(i, r, c);
  }
}

/// Simulates a real phone screen: the app sees this logical size (so its
/// own scaling matches a real device), not just a resized test window.
void setScreen(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  const sizes = {
    'small phone 320x568': Size(320, 568),
    'phone 360x800': Size(360, 800),
    'tall phone 412x915': Size(412, 915),
    'tablet 800x1280': Size(800, 1280),
    'landscape tablet 1280x800': Size(1280, 800),
  };

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('home and game fit without overflow on $name', (tester) async {
      setScreen(tester, size);
      final services = makeServices();
      await tester.pumpWidget(CalmGridApp(services: services));
      await tester.pump();
      expect(find.text('Calm Grid'), findsOneWidget);
      expect(find.text('Classic'), findsOneWidget);
      expect(find.textContaining('Journey'), findsOneWidget);
      for (final label in ['Daily', 'Spin', 'Goals', 'Themes']) {
        expect(find.text(label), findsOneWidget);
      }
      // Simple home: everything fits on one screen, no scrolling.
      expect(find.byType(Scrollable), findsNothing);

      await tester.tap(find.text('Classic'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byTooltip('Pause'), findsOneWidget);
      // Exceptions such as RenderFlex overflows fail the test automatically.
    });
  }

  testWidgets(
    'drag a piece into the bottom-right corner (whole 8x8 reachable)',
    (tester) async {
      setScreen(tester, const Size(390, 844));
      final services = makeServices();
      final game = GameState(random: Random(4));
      await tester.pumpWidget(gameApp(services, game));
      await tester.pump();

      final board = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BoardPainter,
      );
      final rect = tester.getRect(board);
      final cell = BoardPainter.cellSize(rect.width, 8);
      final pad = cell * BoardPainter.framePadding;

      final index = game.tray.indexWhere((p) => p != null);
      final piece = game.tray[index]!;
      final row = 8 - piece.rows, col = 8 - piece.cols;
      // The piece floats 0.9 cells above the finger, so for the bottom row the
      // finger is below the board: this used to be impossible.
      final target =
          rect.topLeft +
          Offset(
            pad + col * cell + piece.cols * cell / 2,
            pad + row * cell + piece.rows * cell + cell * 0.9,
          );
      expect(target.dy, greaterThan(rect.bottom - cell * 0.2));

      final slotWidth = 390 / 3;
      final start = Offset(
        slotWidth * (index + 0.5),
        tester.getRect(board).bottom + 80,
      );
      final gesture = await tester.startGesture(start);
      for (var i = 1; i <= 10; i++) {
        await gesture.moveTo(Offset.lerp(start, target, i / 10)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(game.movesMade, 1);
      for (final c in piece.cells) {
        expect(game.board.isEmpty(row + c.row, col + c.col), isFalse);
      }
      await tester.pumpAndSettle();
    },
  );

  testWidgets('lose -> revive with ad -> lose -> game over -> double coins', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    final services = makeServices();
    final ads = services.offers.ads as SimulatedAdService;
    final game = GameState(random: Random(1));
    await tester.pumpWidget(gameApp(services, game));

    playUntilLost(game, Random(7));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    // Losing first shows a clear "No more moves" moment on the greyed board.
    expect(find.text('No more moves'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Watch ad & continue'), findsOneWidget);

    await tester.tap(find.text('Watch ad & continue'));
    await tester.pumpAndSettle();
    expect(game.isGameOver, isFalse);
    expect(game.revivesUsed, 1);
    expect(ads.rewardedShown, 1);
    expect(services.profile.hasSavedGame, isTrue);

    playUntilLost(game, Random(8));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(
      find.text('Watch ad & continue'),
      findsNothing,
      reason: 'one revive per game',
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(services.profile.hasSavedGame, isFalse);
    expect(services.profile.bestScore, game.score);
    final coinsBefore = services.profile.coins;
    expect(coinsBefore, greaterThan(0));

    final doubleButton = find.byIcon(Icons.play_circle_outline_rounded);
    expect(doubleButton, findsOneWidget);
    await tester.tap(doubleButton);
    await tester.pumpAndSettle();
    expect(services.profile.coins, greaterThan(coinsBefore));
    expect(ads.rewardedShown, 2);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      ads.interstitialsShown,
      0,
      reason: 'new players never see interstitials',
    );
    expect(game.score, 0);
  });

  testWidgets('saved game shows Continue on the home screen', (tester) async {
    setScreen(tester, const Size(390, 844));
    final services = makeServices();
    final game = GameState(random: Random(2));
    final i = game.tray.indexWhere((p) => p != null);
    game.place(i, 0, 0);
    await services.profile.saveGame(game.toJson());
    await tester.pumpWidget(CalmGridApp(services: services));
    await tester.pump();
    expect(find.text('Continue Classic'), findsOneWidget);
    expect(find.text('New Classic game'), findsOneWidget);
  });

  testWidgets('Journey: win a level, earn stars and coins, go to the next', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    final services = makeServices(stored: {'tutorialDone': true});
    final level = LevelSpec.generate(1);
    // Play legal moves until the score goal is met (re-deal on a stuck board).
    GameState? won;
    for (var seed = 0; seed < 20 && won == null; seed++) {
      final g = GameState(random: Random(seed), level: level);
      final rnd = Random(seed);
      while (!g.isGameOver && !g.levelComplete) {
        final moves = [
          for (var i = 0; i < GameState.traySize; i++)
            for (var r = 0; r < 8; r++)
              for (var c = 0; c < 8; c++)
                if (g.canPlace(i, r, c)) (i, r, c),
        ];
        final (i, r, c) = moves[rnd.nextInt(moves.length)];
        g.place(i, r, c);
      }
      if (g.levelComplete) won = g;
    }
    expect(won, isNotNull);

    // Open the game screen on the won game: it shows the result.
    await tester.pumpWidget(gameApp(services, won!));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Level 1 complete!'), findsOneWidget);
    expect(find.text('Next level'), findsOneWidget);
    expect(services.profile.journeyLevel, 2);
    expect(services.profile.journeyStars[1], inInclusiveRange(1, 3));
    expect(services.profile.coins, greaterThan(0));
    expect(
      services.profile.hasSavedGame,
      isFalse,
      reason: 'Journey never overwrites Classic save',
    );

    await tester.tap(find.text('Next level'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Level 2'), findsOneWidget);
  });

  testWidgets('daily spin: free spin, then one extra spin for an ad', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    final services = makeServices();
    await tester.pumpWidget(CalmGridApp(services: services));
    await tester.pump();
    await tester.tap(find.text('Spin'));
    await tester.pump(const Duration(seconds: 1));

    final spinButton = find.widgetWithText(SoftButton, 'Spin');
    await tester.ensureVisible(spinButton);
    await tester.tap(spinButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    final afterFirst = services.profile.coins;
    expect(afterFirst, greaterThan(0));
    expect(services.profile.freeSpinAvailable, isFalse);
    expect(find.textContaining('You won'), findsOneWidget);

    expect(find.textContaining('Prize is random'), findsOneWidget);
    await tester.ensureVisible(find.text('Watch ad & spin'));
    await tester.tap(find.text('Watch ad & spin'));
    // Simulated ad, then the 3.8 s wheel animation.
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(services.profile.coins, greaterThan(afterFirst));
    expect(services.profile.extraSpinAvailable, isFalse);
    expect(find.text('Come back tomorrow'), findsOneWidget);
  });

  testWidgets('home icons open goals and the already-claimed daily view', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    final services = makeServices();
    await tester.pumpWidget(CalmGridApp(services: services));
    await tester.pump();

    await tester.tap(find.text('Goals'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Today's goals"), findsOneWidget);
    await tester.tap(find.widgetWithText(SoftButton, 'OK'));
    await tester.pump(const Duration(seconds: 1));

    await services.profile.claimDaily();
    await tester.pump();
    await tester.tap(find.text('Daily'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('day streak'), findsOneWidget);
  });

  testWidgets('new best score asks for a review only for settled players', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844));
    // A player who installed a week ago and has played plenty.
    final services = makeServices(
      stored: {
        'gamesPlayed': 12,
        'firstOpenAt': DateTime.now()
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch,
      },
    );
    final review = services.review as NoReviewService;
    final game = GameState(random: Random(1));
    await tester.pumpWidget(gameApp(services, game));
    playUntilLost(game, Random(8));
    await tester.pump();
    // The "calm" wording waits 0.9 s longer before the revive offer appears.
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('No thanks'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Try again'), findsOneWidget);
    expect(
      services.profile.bestScore,
      game.score,
      reason: 'first game = new best',
    );
    expect(review.requests, 1);
    expect(services.profile.unlockedAchievements, contains('first_block'));
  });
}
