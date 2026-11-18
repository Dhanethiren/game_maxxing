import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'ads/ad_service.dart';
import 'app/app_scope.dart';
import 'audio/sound_service.dart';
import 'services/player_profile.dart';
import 'services/reward_offers.dart';
import 'ui/game_theme.dart';
import 'ui/home_screen.dart';

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
    // Draw something straight away. Everything that can fail loads after.
    runApp(const CalmGridApp());
  }, _report);
}

class CalmGridApp extends StatefulWidget {
  const CalmGridApp({super.key, this.services});

  /// Injected in tests.
  final AppServices? services;

  @override
  State<CalmGridApp> createState() => _CalmGridAppState();
}

class _CalmGridAppState extends State<CalmGridApp> {
  AppServices? _services;
  String? _bootError;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _services = widget.services;
    if (_services == null) _boot();
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      // Phones play in portrait. Tablets and foldables may rotate: Play ranks
      // apps that meet its large-screen quality guidelines (both orientations,
      // no letterboxing) higher on those devices, and the game has a
      // landscape layout for them.
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final shortest = view.physicalSize.shortestSide / view.devicePixelRatio;
      if (shortest < 600) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    } catch (e, s) {
      _report(e, s);
    }

    PlayerProfile profile;
    try {
      profile = await PlayerProfile.load().timeout(const Duration(seconds: 5));
    } catch (e, s) {
      // Storage failed: keep playing with an in-memory store (progress won't
      // be saved this session) rather than not starting at all.
      _report('Storage unavailable: $e', s);
      profile = PlayerProfile(MemoryStore());
    }

    try {
      final sound = SoundService.create();
      final services = AppServices(
        profile: profile,
        offers: RewardOffers(ads: AdService.create(), profile: profile),
        sound: sound,
      );
      if (mounted) setState(() => _services = services);

      // Music pauses when the app goes to the background.
      _lifecycle = AppLifecycleListener(
        onResume: () => sound.updateMusic(appInForeground: true),
        onPause: () => sound.updateMusic(appInForeground: false),
      );
      unawaited(sound.init());
      // Ads (and the consent form) start after the first frame is on screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        services.offers.ads
            .init()
            .timeout(const Duration(seconds: 20))
            .catchError((Object e) => debugPrint('Ads unavailable: $e'));
      });
    } catch (e, s) {
      _report(e, s);
      if (mounted) setState(() => _bootError = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) {
      final theme = GameTheme.all.first;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: Scaffold(
          body: DecoratedBox(
            decoration: theme.background,
            child: Center(
              child: _bootError == null
                  ? CircularProgressIndicator(color: theme.accent)
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Calm Grid could not start:\n\n$_bootError'),
                    ),
            ),
          ),
        ),
      );
    }
    return AppScope(
      services: services,
      child: Builder(
        builder: (context) {
          final theme = AppScope.of(context).theme;
          return MaterialApp(
            title: 'Calm Grid',
            debugShowCheckedModeBanner: false,
            theme: theme.toThemeData(),
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              // Large system fonts are respected, but capped so the board and
              // buttons still fit on small phones.
              maxScaleFactor: 1.25,
              child: Stack(
                children: [
                  ?child,
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _ErrorBanner(),
                  ),
                ],
              ),
            ),
            home: const HomeScreen(),
          );
        },
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
                        child: Text(
                          'Something went wrong (screenshot this for the developer)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
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
                      child: SelectableText(
                        errors.join('\n\n'),
                        style: const TextStyle(fontSize: 10),
                      ),
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
