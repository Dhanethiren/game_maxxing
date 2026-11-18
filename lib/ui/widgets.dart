import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';

/// Rounded pill button with a gentle press animation, tap sound and haptic.
class SoftButton extends StatefulWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor = Colors.white,
    this.large = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color textColor;
  final bool large;
  final bool outlined;

  @override
  State<SoftButton> createState() => _SoftButtonState();
}

class _SoftButtonState extends State<SoftButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = uiScale(context);
    final color = widget.color ?? app.theme.accent;
    final enabled = widget.onPressed != null;
    final fg = widget.outlined ? color : widget.textColor;
    final height = (widget.large ? 60.0 : 48.0) * s;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                app.tap();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.95 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.5,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: height,
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              decoration: BoxDecoration(
                color: widget.outlined ? Colors.transparent : color,
                borderRadius: BorderRadius.circular(height / 2),
                border: widget.outlined
                    ? Border.all(color: color, width: 2)
                    : null,
                boxShadow: widget.outlined
                    ? null
                    : [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: fg,
                      size: (widget.large ? 28 : 22) * s,
                    ),
                    SizedBox(width: 8 * s),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: (widget.large ? 22 : 16) * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded chip, e.g. coins or level.
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: theme.card.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18 * s, color: iconColor ?? theme.accent),
            SizedBox(width: 6 * s),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15 * s,
                color: theme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoinChip extends StatelessWidget {
  const CoinChip({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = AppScope.of(context).profile.coins;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: coins.toDouble()),
      duration: const Duration(milliseconds: 600),
      builder: (context, v, _) => InfoChip(
        icon: Icons.circle,
        iconColor: const Color(0xFFF2C14E),
        text: '${v.round()}',
      ),
    );
  }
}

/// Soft translucent card.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final s = uiScale(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: theme.dark ? 0.7 : 0.75),
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Round icon button for top bars.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = uiScale(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: app.theme.card.withValues(alpha: 0.8),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed == null
              ? null
              : () {
                  app.tap();
                  onPressed!();
                },
          child: Padding(
            padding: EdgeInsets.all(10 * s),
            child: Icon(icon, size: 22 * s, color: app.theme.textSoft),
          ),
        ),
      ),
    );
  }
}
