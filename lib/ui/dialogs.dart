import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../audio/sound_service.dart';
import '../ml/offer_optimizer.dart';
import '../services/progression.dart';
import 'widgets.dart';

Future<T?> _softDialog<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool dismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: child,
      ),
    ),
  );
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380 * s),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: theme.card,
            borderRadius: BorderRadius.circular(28 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(22 * s, 24 * s, 22 * s, 18 * s),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _title(BuildContext context, String text) => Text(
  text,
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 26 * uiScale(context),
    fontWeight: FontWeight.w800,
    color: AppScope.of(context).theme.text,
  ),
);

Widget _body(BuildContext context, String text) => Text(
  text,
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 16 * uiScale(context),
    color: AppScope.of(context).theme.textSoft,
    height: 1.35,
  ),
);

// ------------------------------------------------------------------- revive

/// "Watch an ad to continue?" Wording comes from the ML-chosen [variant].
/// No countdown timer and a clear "No thanks": the game is meant to lower
/// stress, and Google Play bans misleading ad prompts.
Future<bool> showReviveOffer(
  BuildContext context, {
  required OfferVariant variant,
  required int score,
  required int bestScore,
}) async {
  final (title, body) = switch (variant) {
    OfferVariant.quick => (
      'Continue?',
      'Watch a short ad to clear some space and keep playing.',
    ),
    OfferVariant.progress =>
      bestScore > 0 && score < bestScore
          ? (
              'So close!',
              'You\'re ${(score * 100 / bestScore).round()}% of the way to your best '
                  '($bestScore). Watch a short ad to keep this run going.',
            )
          : (
              'Great run!',
              'You\'re on $score points. Watch a short ad to keep this run going.',
            ),
    OfferVariant.calm => (
      'Take a breath',
      'No rush. If you\'d like, a short ad will clear some space so you can continue.',
    ),
  };
  final result = await _softDialog<bool>(
    context,
    dismissible: false,
    (context) => _DialogCard(
      children: [
        Icon(
          Icons.favorite_rounded,
          color: AppScope.of(context).theme.accent,
          size: 44,
        ),
        const SizedBox(height: 8),
        _title(context, title),
        const SizedBox(height: 10),
        _body(context, body),
        const SizedBox(height: 22),
        SoftButton(
          label: 'Watch ad & continue',
          icon: Icons.play_circle_outline_rounded,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'No thanks',
            style: TextStyle(color: AppScope.of(context).theme.textSoft),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

// -------------------------------------------------------------------- pause

enum PauseChoice { resume, restart, home }

Future<PauseChoice> showPauseMenu(BuildContext context) async {
  final choice = await _softDialog<PauseChoice>(
    context,
    (context) => _DialogCard(
      children: [
        _title(context, 'Paused'),
        const SizedBox(height: 18),
        SoftButton(
          label: 'Resume',
          icon: Icons.play_arrow_rounded,
          onPressed: () => Navigator.pop(context, PauseChoice.resume),
        ),
        const SizedBox(height: 10),
        SoftButton(
          label: 'Restart',
          icon: Icons.refresh_rounded,
          outlined: true,
          onPressed: () => Navigator.pop(context, PauseChoice.restart),
        ),
        const SizedBox(height: 10),
        SoftButton(
          label: 'Home',
          icon: Icons.home_rounded,
          outlined: true,
          onPressed: () => Navigator.pop(context, PauseChoice.home),
        ),
        const SizedBox(height: 14),
        const _SettingsToggles(),
      ],
    ),
  );
  return choice ?? PauseChoice.resume;
}

// ----------------------------------------------------------------- settings

class _SettingsToggles extends StatelessWidget {
  const _SettingsToggles();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.profile;
    Widget toggle(
      IconData on,
      IconData off,
      String label,
      bool value,
      ValueChanged<bool> set,
    ) {
      return Column(
        children: [
          RoundIconButton(
            icon: value ? on : off,
            tooltip: label,
            onPressed: () => set(!value),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: app.theme.textSoft),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        toggle(
          Icons.volume_up_rounded,
          Icons.volume_off_rounded,
          'Sound',
          p.soundOn,
          p.setSoundOn,
        ),
        toggle(
          Icons.music_note_rounded,
          Icons.music_off_rounded,
          'Music',
          p.musicOn,
          p.setMusicOn,
        ),
        toggle(
          Icons.vibration_rounded,
          Icons.mobile_off_rounded,
          'Vibrate',
          p.hapticsOn,
          p.setHapticsOn,
        ),
      ],
    );
  }
}

Future<void> showSettings(BuildContext context) async {
  final app = AppScope.read(context);
  final privacy = await app.offers.ads.privacyOptionsRequired().catchError(
    (_) => false,
  );
  if (!context.mounted) return;
  await _softDialog<void>(
    context,
    (context) => _DialogCard(
      children: [
        _title(context, 'Settings'),
        const SizedBox(height: 18),
        const _SettingsToggles(),
        if (privacy) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: app.offers.ads.showPrivacyOptions,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy options'),
          ),
        ],
        const SizedBox(height: 16),
        SoftButton(label: 'Done', onPressed: () => Navigator.pop(context)),
      ],
    ),
  );
}

// ------------------------------------------------------------- daily reward

/// Shows the 7-day login streak and lets the player claim today's coins,
/// optionally doubled with a rewarded ad. Returns the coins claimed.
Future<int> showDailyReward(BuildContext context) async {
  final app = AppScope.read(context);
  final day = app.profile.claimableDailyDay();
  if (day == null) return 0;
  final base = Progression.dailyRewards[day - 1];
  final decision = app.offers.decide(OfferPlacement.dailyBonus);
  final adLabel = switch (decision.variant) {
    OfferVariant.quick => 'Watch ad: ×2',
    OfferVariant.progress => 'Watch ad: get ${base * 2}',
    OfferVariant.calm => 'Double it with a short ad',
  };
  var answered = false;

  final claimed = await _softDialog<int>(context, dismissible: false, (
    context,
  ) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return _DialogCard(
      children: [
        _title(context, 'Daily reward'),
        const SizedBox(height: 6),
        _body(context, 'Come back every day: day 7 is a big one.'),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6 * s,
          runSpacing: 6 * s,
          children: [
            for (var d = 1; d <= 7; d++)
              Container(
                width: 40 * s,
                padding: EdgeInsets.symmetric(vertical: 6 * s),
                decoration: BoxDecoration(
                  color: d == day
                      ? theme.accent
                      : (d < day
                            ? theme.accent.withValues(alpha: 0.25)
                            : theme.emptyCell),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'D$d',
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                        color: d == day ? Colors.white : theme.textSoft,
                      ),
                    ),
                    Icon(
                      d < day
                          ? Icons.check_rounded
                          : (d == 7 ? Icons.redeem_rounded : Icons.circle),
                      size: 16 * s,
                      color: d == day ? Colors.white : const Color(0xFFF2C14E),
                    ),
                    Text(
                      '${Progression.dailyRewards[d - 1]}',
                      style: TextStyle(
                        fontSize: 11 * s,
                        color: d == day ? Colors.white : theme.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SoftButton(
          label: adLabel,
          icon: Icons.play_circle_outline_rounded,
          onPressed: app.offers.ads.isReady
              ? () async {
                  answered = true;
                  await app.offers.recordAnswer(decision, accepted: true);
                  final earned = await app.offers.watchAd();
                  final coins = await app.profile.claimDaily(
                    multiplier: earned ? 2 : 1,
                  );
                  if (context.mounted) Navigator.pop(context, coins);
                }
              : null,
        ),
        const SizedBox(height: 10),
        SoftButton(
          label: 'Claim $base',
          outlined: true,
          onPressed: () async {
            final coins = await app.profile.claimDaily();
            if (context.mounted) Navigator.pop(context, coins);
          },
        ),
      ],
    );
  });
  if (!answered && app.offers.ads.isReady) {
    await app.offers.recordAnswer(decision, accepted: false);
  }
  if ((claimed ?? 0) > 0) app.sound.play(Sfx.levelup);
  return claimed ?? 0;
}
