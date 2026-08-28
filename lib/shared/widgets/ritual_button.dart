import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Accent call-to-action. Disabled state matches the canvas: the fill drops to
/// `--surface-raised` and the label to `--text-tertiary`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingArrow = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool trailingArrow;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background =
        enabled ? RitualColors.accent : RitualColors.surfaceRaised;
    final foreground =
        enabled ? RitualColors.onAccent : RitualColors.textTertiary;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: trailingArrow
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: outfit(
            size: 13,
            weight: FontWeight.w800,
            color: foreground,
            letterSpacing: 0.04,
          ),
        ),
        if (trailingArrow) Icon(Icons.arrow_forward, size: 16, color: foreground),
      ],
    );

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: content,
        ),
      ),
    );
  }
}

/// The "Solve →" / "Answer →" affordance at the bottom of a teaser card.
class InlineAction extends StatelessWidget {
  const InlineAction(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: outfit(
            size: 12,
            weight: FontWeight.w800,
            color: color,
            letterSpacing: 0.04,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.arrow_forward, size: 13, color: color),
      ],
    );
  }
}

/// 18×18 checkbox, radius 5. Checked state fills with accent and draws the
/// tick in the page background colour.
class RitualCheckbox extends StatelessWidget {
  const RitualCheckbox({super.key, required this.checked, this.size = 18});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? RitualColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(RitualShape.checkboxRadius),
        border: checked
            ? null
            : Border.all(color: RitualColors.borderStrong, width: 1.5),
      ),
      child: checked
          ? Icon(Icons.check, size: size * 0.62, color: RitualColors.bg)
          : null,
    );
  }
}
