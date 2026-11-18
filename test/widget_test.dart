import 'dart:math';

import 'package:calm_grid/ads/ad_service.dart';
import 'package:calm_grid/game/game_state.dart';
import 'package:calm_grid/services/player_profile.dart';
import 'package:calm_grid/services/reward_offers.dart';
import 'package:calm_grid/ui/game_screen.dart';
import 'package:calm_grid/ui/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game screen renders board, score and tray', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final profile = await PlayerProfile.load();
    final offers = RewardOffers(
      ads: SimulatedAdService(delay: Duration.zero),
      profile: profile,
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(MaterialApp(
      theme: CalmPalette.theme(),
      home: GameScreen(offers: offers, game: GameState(random: Random(1))),
    ));
    await tester.pump();

    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.byType(Draggable<int>), findsNWidgets(GameState.traySize));
  });

  testWidgets('losing offers a revive; watching the ad revives once', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final profile = await PlayerProfile.load();
    final offers = RewardOffers(
      ads: SimulatedAdService(delay: Duration.zero),
      profile: profile,
    );
    final game = GameState(random: Random(1));
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(MaterialApp(
      home: GameScreen(offers: offers, game: game),
    ));

    // Play random legal moves until the game is lost.
    final rnd = Random(7);
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Watch ad & continue'), findsOneWidget);

    await tester.tap(find.text('Watch ad & continue'));
    await tester.pumpAndSettle();
    expect(game.isGameOver, isFalse);
    expect(game.revivesUsed, 1);
    expect(profile.lifetimeAccepts, 1);
    expect(offers.optimizer.stats().values.fold<int>(0, (s, v) => s + v.accepted), 1);
  });
}
