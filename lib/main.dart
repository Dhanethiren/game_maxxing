import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'ads/ad_service.dart';
import 'services/player_profile.dart';
import 'services/reward_offers.dart';
import 'ui/game_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final profile = await PlayerProfile.load();
  final offers = RewardOffers(ads: RewardedAdService.create(), profile: profile);
  runApp(CalmGridApp(offers: offers));
}

class CalmGridApp extends StatelessWidget {
  const CalmGridApp({super.key, required this.offers});

  final RewardOffers offers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calm Grid',
      debugShowCheckedModeBanner: false,
      theme: CalmPalette.theme(),
      home: GameScreen(offers: offers),
    );
  }
}
