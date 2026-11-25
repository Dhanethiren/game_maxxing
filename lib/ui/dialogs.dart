import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import '../l10n/l10n.dart';
import '../audio/sound_service.dart';
import '../services/reward_offers.dart';
import '../services/achievements.dart';
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
    barrierLabel: context.l10n.close,
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
  final l = context.l10n;
  final (title, body) = switch (variant) {
    OfferVariant.quick => (l.reviveQuickTitle, l.reviveQuickBody),
    OfferVariant.progress =>
      bestScore > 0 && score < bestScore
          ? (
              l.reviveCloseTitle,
              l.reviveCloseBody((score * 100 / bestScore).round(), bestScore),
            )
          : (l.reviveGreatTitle, l.reviveGreatBody(score)),
    OfferVariant.calm => (l.reviveCalmTitle, l.reviveCalmBody),
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
          label: l.watchAdContinue,
          icon: Icons.play_circle_outline_rounded,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            l.noThanks,
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
        _title(context, context.l10n.paused),
        const SizedBox(height: 18),
        SoftButton(
          label: context.l10n.resume,
          icon: Icons.play_arrow_rounded,
          onPressed: () => Navigator.pop(context, PauseChoice.resume),
        ),
        const SizedBox(height: 10),
        SoftButton(
          label: context.l10n.restart,
          icon: Icons.refresh_rounded,
          outlined: true,
          onPressed: () => Navigator.pop(context, PauseChoice.restart),
        ),
        const SizedBox(height: 10),
        SoftButton(
          label: context.l10n.home,
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
      // Equal thirds; a long translated label shrinks instead of overflowing.
      return Expanded(
        child: Column(
          children: [
            RoundIconButton(
              icon: value ? on : off,
              tooltip: label,
              onPressed: () => set(!value),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(fontSize: 12, color: app.theme.textSoft),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        toggle(
          Icons.volume_up_rounded,
          Icons.volume_off_rounded,
          context.l10n.sound,
          p.soundOn,
          p.setSoundOn,
        ),
        toggle(
          Icons.music_note_rounded,
          Icons.music_off_rounded,
          context.l10n.music,
          p.musicOn,
          p.setMusicOn,
        ),
        toggle(
          Icons.vibration_rounded,
          Icons.mobile_off_rounded,
          context.l10n.vibrate,
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
        _title(context, context.l10n.settings),
        const SizedBox(height: 18),
        const _SettingsToggles(),
        if (privacy) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: app.offers.ads.showPrivacyOptions,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: Text(context.l10n.privacyOptions),
          ),
        ],
        if (app.review.canOpenStore) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: app.review.openStoreListing,
            icon: const Icon(Icons.star_rate_rounded),
            label: Text(context.l10n.rateGame),
          ),
        ],
        const SizedBox(height: 8),
        SoftButton(
          label: context.l10n.done,
          onPressed: () => Navigator.pop(context),
        ),
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
  if (day == null) {
    // Already claimed today: show the streak instead.
    await _softDialog<void>(
      context,
      (context) => _DialogCard(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: const Color(0xFFF08A5D),
            size: 48 * uiScale(context),
          ),
          const SizedBox(height: 8),
          _title(context, context.l10n.dayStreak(app.profile.dailyStreak)),
          const SizedBox(height: 8),
          _body(
            context,
            context.l10n.rewardCollected(app.profile.dailyStreak % 7 + 1),
          ),
          const SizedBox(height: 18),
          SoftButton(
            label: context.l10n.ok,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    return 0;
  }
  final base = Progression.dailyRewards[day - 1];
  final decision = app.offers.decide(OfferPlacement.dailyBonus);
  final l = context.l10n;
  final adLabel = switch (decision.variant) {
    OfferVariant.quick => l.dailyDoubleQuick,
    OfferVariant.progress => l.dailyDoubleProgress(base * 2),
    OfferVariant.calm => l.dailyDoubleCalm,
  };
  var answered = false;

  final claimed = await _softDialog<int>(context, dismissible: false, (
    context,
  ) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return _DialogCard(
      children: [
        _title(context, l.dailyReward),
        const SizedBox(height: 6),
        _body(context, l.dailyRewardHint),
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
                      l.dayShort(d),
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
          label: l.claimCoins(base),
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
  if ((claimed ?? 0) > 0) {
    app.sound.play(Sfx.levelup);
    await app.checkStatAchievements(); // 7-day streak
  }
  return claimed ?? 0;
}

// -------------------------------------------------------------------- goals

/// Today's three goals with progress bars.
Future<void> showGoals(BuildContext context) {
  final app = AppScope.read(context);
  final missions = app.profile.missions().missions;
  return _softDialog<void>(
    context,
    (context) => _DialogCard(
      children: [
        _title(context, context.l10n.todaysGoals),
        const SizedBox(height: 6),
        _body(context, context.l10n.goalsHint),
        const SizedBox(height: 16),
        for (final m in missions) _MissionRow(m),
        const SizedBox(height: 8),
        SoftButton(
          label: context.l10n.ok,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showAchievements(context);
          },
          icon: const Icon(Icons.emoji_events_rounded),
          label: Text(
            context.l10n.achievementsCount(
              app.profile.unlockedAchievements.length,
              Achievement.values.length,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MissionRow extends StatelessWidget {
  const _MissionRow(this.mission);
  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: Row(
        children: [
          Icon(
            mission.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: mission.done ? theme.accent : theme.textSoft,
            size: 22 * s,
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.titleIn(context.l10n),
                  style: TextStyle(fontSize: 14 * s, color: theme.text),
                ),
                SizedBox(height: 4 * s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.fraction,
                    minHeight: 5 * s,
                    backgroundColor: theme.emptyCell,
                    color: theme.accent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          Icon(Icons.circle, color: const Color(0xFFF2C14E), size: 14 * s),
          SizedBox(width: 4 * s),
          Text(
            '${mission.reward}',
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- achievements

Future<void> showAchievements(BuildContext context) {
  final app = AppScope.read(context);
  final have = app.profile.unlockedAchievements;
  return _softDialog<void>(context, (context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return _DialogCard(
      children: [
        _title(context, context.l10n.achievements),
        const SizedBox(height: 4),
        _body(
          context,
          context.l10n.achievementsSummary(
            have.length,
            Achievement.values.length,
            Achievement.reward,
          ),
        ),
        const SizedBox(height: 14),
        for (final a in Achievement.values)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * s),
            child: Row(
              children: [
                Icon(
                  have.contains(a.id)
                      ? Icons.emoji_events_rounded
                      : Icons.lock_outline_rounded,
                  color: have.contains(a.id)
                      ? const Color(0xFFF2C14E)
                      : theme.textSoft,
                  size: 24 * s,
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.titleIn(context.l10n),
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      Text(
                        a.descriptionIn(context.l10n),
                        style: TextStyle(
                          fontSize: 12.5 * s,
                          color: theme.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SoftButton(
          label: context.l10n.ok,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  });
}
