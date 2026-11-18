import 'dart:math';

import 'package:calm_grid/ads/ad_service.dart';
import 'package:calm_grid/app/app_scope.dart';
import 'package:calm_grid/audio/sound_service.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/main.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/reward_offers.dart';
import 'package:calm_grid/ui/board_painter.dart';
import 'package:calm_grid/ui/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

AppServices makeServices({Map<String, Object>? stored}) {
  final profile = PlayerProfile(MemoryStore(stored));
  return AppServices(
    profile: profile,
    offers: RewardOffers(
      ads: SimulatedAdService(delay: Duration.zero),
      profile: profile,
    ),
    sound: SilentSoundService(),
  );
}

Widget gameApp(AppServices services, GameState game) => AppScope(
  services: services,
  child: MaterialApp(home: GameScreen(game: game)),
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
      await tester.binding.setSurfaceSize(size);
      final services = makeServices();
      await tester.pumpWidget(CalmGridApp(services: services));
      await tester.pump();
      expect(find.text('Calm Grid'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text("Today's goals"), findsOneWidget);

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byTooltip('Pause'), findsOneWidget);
      // Exceptions such as RenderFlex overflows fail the test automatically.
    });
  }

  testWidgets(
    'drag a piece into the bottom-right corner (whole 8x8 reachable)',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
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
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final services = makeServices();
    final ads = services.offers.ads as SimulatedAdService;
    final game = GameState(random: Random(1));
    await tester.pumpWidget(gameApp(services, game));

    playUntilLost(game, Random(7));
    await tester.pump();
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
    expect(find.text('Play again'), findsOneWidget);
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

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(
      ads.interstitialsShown,
      0,
      reason: 'new players never see interstitials',
    );
    expect(game.score, 0);
  });

  testWidgets('saved game shows Continue on the home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final services = makeServices();
    final game = GameState(random: Random(2));
    final i = game.tray.indexWhere((p) => p != null);
    game.place(i, 0, 0);
    await services.profile.saveGame(game.toJson());
    await tester.pumpWidget(CalmGridApp(services: services));
    await tester.pump();
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
  });
}
