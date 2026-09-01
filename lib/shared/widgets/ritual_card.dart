import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The standard surface card: `background:var(--surface)`, radius 16,
/// `box-shadow:0 1px 2px rgba(0,0,0,0.4)`.
class RitualCard extends StatelessWidget {
  const RitualCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = RitualShape.cardPadding,
    this.clipContents = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// Set when the card holds a full-bleed image that must follow the corners.
  final bool clipContents;

  @override
  Widget build(BuildContext context) {
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: RitualColors.surface,
        borderRadius: BorderRadius.circular(RitualShape.cardRadius),
        boxShadow: RitualShape.cardShadow,
      ),
      child: clipContents
          ? ClipRRect(
              borderRadius: BorderRadius.circular(RitualShape.cardRadius),
              child: Padding(padding: padding, child: child),
            )
          : Padding(padding: padding, child: child),
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RitualShape.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitualShape.cardRadius),
        child: decorated,
      ),
    );
  }
}

/// The accent-filled card used for Surprise Me — accent background, radius 20,
/// everything inside drawn in `--on-accent`.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RitualColors.accent,
      borderRadius: BorderRadius.circular(RitualShape.accentCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitualShape.accentCardRadius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 2px `--border-strong` rule used for structural breaks; the 1px
/// `--border` variant separates rows inside a card.
class RitualDivider extends StatelessWidget {
  const RitualDivider({super.key, this.strong = true});

  final bool strong;

  @override
  Widget build(BuildContext context) => Container(
    height: strong ? 2 : 1,
    color: strong ? RitualColors.borderStrong : RitualColors.border,
  );
}
