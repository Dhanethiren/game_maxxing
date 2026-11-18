import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'ads/ad_service.dart';
import 'services/player_profile.dart';
import 'services/reward_offers.dart';
import 'ui/game_screen.dart';
import 'ui/theme.dart';

/// Errors nobody caught. They are shown on screen instead of failing silently,
/// so a problem on a real phone can be screenshotted and fixed.
final ValueNotifier<List<String>> uncaughtErrors = ValueNotifier([]);

void _report(Object error, StackTrace? stack) {
  final lines = '$stack'.split('\n').take(8).join('\n');
  uncaughtErrors.value = [...uncaughtErrors.value, '$error\n$lines'];
  debugPrint('Uncaught: $error\n$stack');
}

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _report(details.exception, details.stack);
    };
    ErrorWidget.builder = (details) => Container(
          color: const Color(0xFFFFF4F4),
          padding: const EdgeInsets.all(8),
          child: Text('${details.exception}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A2020))),
        );
    // Draw something straight away. Everything that can fail loads after.
    runApp(const CalmGridApp());
  }, _report);
}

class CalmGridApp extends StatefulWidget {
  const CalmGridApp({super.key});

  @override
  State<CalmGridApp> createState() => _CalmGridAppState();
}

class _CalmGridAppState extends State<CalmGridApp> {
  RewardOffers? _offers;
  String? _bootError;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (e, s) {
      _report(e, s);
    }

    PlayerProfile profile;
    try {
      profile = await PlayerProfile.load().timeout(const Duration(seconds: 5));
    } catch (e, s) {
      // Storage failed: keep playing with an in-memory store (scores won't be
      // saved this session) rather than not starting at all.
      _report('Storage unavailable: $e', s);
      profile = PlayerProfile(MemoryStore());
    }

    try {
      final offers = RewardOffers(ads: RewardedAdService.create(), profile: profile);
      if (mounted) setState(() => _offers = offers);
    } catch (e, s) {
      _report(e, s);
      if (mounted) setState(() => _bootError = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = _offers;
    return MaterialApp(
      title: 'Calm Grid',
      debugShowCheckedModeBanner: false,
      theme: CalmPalette.theme(),
      builder: (context, child) => Stack(
        children: [
          ?child,
          const Positioned(left: 0, right: 0, bottom: 0, child: _ErrorBanner()),
        ],
      ),
      home: offers != null
          ? GameScreen(offers: offers)
          : Scaffold(
              body: DecoratedBox(
                decoration: CalmPalette.backgroundGradient,
                child: Center(
                  child: _bootError == null
                      ? const CircularProgressIndicator(color: CalmPalette.accent)
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Calm Grid could not start:\n\n$_bootError'),
                        ),
                ),
              ),
            ),
    );
  }
}

/// Small dismissible panel listing uncaught errors, if any.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: uncaughtErrors,
      builder: (context, errors, _) {
        if (errors.isEmpty) return const SizedBox.shrink();
        return Material(
          color: const Color(0xF2FFF4F4),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Something went wrong (screenshot this for the developer)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => uncaughtErrors.value = [],
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: SelectableText(errors.join('\n\n'),
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
