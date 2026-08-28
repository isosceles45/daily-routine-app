import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The small uppercase section label above every card.
class Eyebrow extends StatelessWidget {
  const Eyebrow(
    this.text, {
    super.key,
    this.color = RitualColors.textTertiary,
    this.size = 11,
    this.letterSpacing = 0.12,
  });

  final String text;
  final Color color;
  final double size;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: RitualText.eyebrow(
          size: size,
          color: color,
          letterSpacing: letterSpacing,
        ),
      );
}

/// Outlined pill: `1.5px solid <feature colour>`, radius 6, uppercase.
class FeatureChip extends StatelessWidget {
  const FeatureChip(
    this.label, {
    super.key,
    this.color = RitualColors.textSecondary,
    this.borderColor,
  });

  final String label;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? color, width: 1.5),
        borderRadius: BorderRadius.circular(RitualShape.chipRadius),
      ),
      child: Text(
        label.toUpperCase(),
        style: outfit(
          size: 10,
          weight: FontWeight.w700,
          color: color,
          letterSpacing: 0.04,
        ),
      ),
    );
  }
}

/// A number over a small uppercase caption — the Streak / Average / Games
/// blocks on the Wordle card and History tab.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.value,
    required this.label,
    this.size = 18,
  });

  final String value;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: RitualText.stat(size)),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: outfit(
            size: 10,
            weight: FontWeight.w700,
            color: RitualColors.textTertiary,
            letterSpacing: 0.06,
          ),
        ),
      ],
    );
  }
}
