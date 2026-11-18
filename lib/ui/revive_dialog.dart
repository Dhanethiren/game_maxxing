import 'package:material_ui/material_ui.dart';

import '../ml/offer_optimizer.dart';
import 'theme.dart';

/// The "watch an ad to continue" offer. Its wording comes from the variant the
/// ML optimizer picked. There is deliberately no countdown timer and the
/// "No thanks" button is always clear: the game is meant to lower stress, and
/// Google Play bans misleading ad prompts.
///
/// Returns true if the player chose to watch the ad.
Future<bool> showReviveOffer(
  BuildContext context, {
  required OfferVariant variant,
  required int score,
  required int bestScore,
}) async {
  final (title, body) = switch (variant) {
    OfferVariant.quick => ('Continue?', 'Watch a short ad to clear some space and keep playing.'),
    OfferVariant.progress => bestScore > 0 && score < bestScore
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

  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFFBFAFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 4,
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Watch ad & continue'),
          style: FilledButton.styleFrom(backgroundColor: CalmPalette.accent),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No thanks'),
        ),
      ],
    ),
  );
  return accepted ?? false;
}
