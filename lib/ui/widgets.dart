import 'package:material_ui/material_ui.dart';

import '../app/app_scope.dart';
import 'game_theme.dart';

/// Shifts a colour's lightness (-1..1) for highlights and shadows.
Color shiftColor(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Two-layer shadow used across the app: a soft tinted ambient shadow plus a
/// tight contact shadow. This is what makes cards and buttons "lift" off the
/// background instead of looking flat.
List<BoxShadow> liftShadow(Color tint, {double strength = 1}) => [
  BoxShadow(
    color: tint.withValues(alpha: 0.18 * strength),
    blurRadius: 18 * strength,
    offset: Offset(0, 8 * strength),
  ),
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.06 * strength),
    blurRadius: 3,
    offset: const Offset(0, 1),
  ),
];

/// Embossed look for big titles: a bright edge below and a soft tinted shadow.
List<Shadow> titleShadows(GameTheme theme) => [
  Shadow(
    color: Colors.white.withValues(alpha: theme.dark ? 0.15 : 0.95),
    offset: const Offset(0, 2),
  ),
  Shadow(
    color: theme.accent.withValues(alpha: 0.3),
    offset: const Offset(0, 6),
    blurRadius: 12,
  ),
];

/// Gradient background with a few large, soft glows for depth. Painted once
/// per size (no per-frame cost).
class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return DecoratedBox(
      decoration: theme.background,
      child: CustomPaint(painter: _GlowPainter(theme), child: child),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.theme);
  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    void glow(Offset c, double r, Color color, double alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final w = size.width, h = size.height, m = size.shortestSide;
    final light = theme.dark ? 0.10 : 0.55;
    glow(Offset(w * 0.15, h * 0.12), m * 0.7, Colors.white, light);
    glow(Offset(w * 0.95, h * 0.35), m * 0.55, theme.blocks[4], 0.16);
    glow(Offset(w * 0.05, h * 0.75), m * 0.5, theme.blocks[3], 0.12);
    glow(Offset(w * 0.85, h * 0.95), m * 0.6, theme.blocks[6], 0.16);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.theme != theme;
}

/// Raised, pressable "3D" pill button with a coloured lip underneath, tap
/// sound and haptic. Pressing pushes the face down onto the lip.
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

  /// Secondary style: light face with coloured text.
  final bool outlined;

  @override
  State<SoftButton> createState() => _SoftButtonState();
}

class _SoftButtonState extends State<SoftButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.theme;
    final s = uiScale(context);
    final color = widget.color ?? theme.accent;
    final enabled = widget.onPressed != null;
    final secondary = widget.outlined;
    final fg = secondary ? shiftColor(color, -0.08) : widget.textColor;
    final height = (widget.large ? 58.0 : 46.0) * s;
    final lip = (widget.large ? 6.0 : 5.0) * s;
    final radius = BorderRadius.circular(height / 2);

    final faceTop = secondary ? Colors.white : shiftColor(color, 0.07);
    final faceBottom = secondary ? theme.card : color;
    final lipColor = secondary
        ? color.withValues(alpha: 0.35)
        : shiftColor(color, -0.16);

    final face = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 22 * s),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [faceTop, faceBottom],
        ),
        border: Border.all(
          color: secondary
              ? color.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.28),
          width: secondary ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: fg, size: (widget.large ? 28 : 22) * s),
            SizedBox(width: 8 * s),
          ],
          // Long (e.g. translated) labels shrink to fit instead of being cut.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                maxLines: 1,
                style: TextStyle(
                  color: fg,
                  fontSize: (widget.large ? 22 : 16) * s,
                  fontWeight: FontWeight.w800,
                  shadows: secondary
                      ? null
                      : [
                          Shadow(
                            color: shiftColor(
                              color,
                              -0.25,
                            ).withValues(alpha: 0.5),
                            offset: const Offset(0, 1.5),
                            blurRadius: 1,
                          ),
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
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
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: Stack(
            // The face gets the same width constraints as the button, so a
            // full-width button has a full-width face.
            fit: StackFit.passthrough,
            children: [
              // The lip: the darker "side" of the button, visible below the face.
              Positioned.fill(
                top: lip,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: lipColor,
                    borderRadius: radius,
                    boxShadow: _down ? null : liftShadow(color, strength: 0.7),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 70),
                margin: EdgeInsets.only(
                  top: _down ? lip * 0.75 : 0,
                  bottom: _down ? lip * 0.25 : lip,
                ),
                child: face,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small raised chip, e.g. coins or level.
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: theme.dark ? 0.16 : 0.95),
              theme.card.withValues(alpha: theme.dark ? 0.6 : 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: liftShadow(theme.accent, strength: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18 * s, color: iconColor ?? theme.accent),
            SizedBox(width: 6 * s),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
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

/// Raised card: lit from the top (gradient + bright top edge) with a soft
/// tinted shadow underneath.
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.dark
              ? [
                  theme.card.withValues(alpha: 0.85),
                  theme.card.withValues(alpha: 0.65),
                ]
              : [
                  Colors.white.withValues(alpha: 0.92),
                  theme.card.withValues(alpha: 0.72),
                ],
        ),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: Colors.white.withValues(alpha: theme.dark ? 0.12 : 0.7),
        ),
        boxShadow: liftShadow(theme.accent),
      ),
      child: child,
    );
  }
}

/// Raised round icon button for top bars.
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
    final theme = app.theme;
    final s = uiScale(context);
    return Tooltip(
      message: tooltip ?? '',
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: theme.dark ? 0.18 : 0.98),
              theme.card.withValues(alpha: theme.dark ? 0.6 : 0.82),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: liftShadow(theme.accent, strength: 0.55),
        ),
        child: Material(
          color: Colors.transparent,
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
              child: Icon(icon, size: 22 * s, color: theme.textSoft),
            ),
          ),
        ),
      ),
    );
  }
}
