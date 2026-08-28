import 'package:flutter/material.dart';

/// The canvas's `riseIn` / `popIn` entry animations.
///
/// Both are honoured only when the platform hasn't asked for reduced motion —
/// `@media (prefers-reduced-motion)` in the design maps to
/// [MediaQueryData.disableAnimations].
class RiseIn extends StatelessWidget {
  const RiseIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offset = 10,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, offset * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Scale-and-fade reveal, used when a result appears (correct/incorrect).
class PopIn extends StatelessWidget {
  const PopIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(scale: 0.94 + (0.06 * t), child: child),
      ),
      child: child,
    );
  }
}
