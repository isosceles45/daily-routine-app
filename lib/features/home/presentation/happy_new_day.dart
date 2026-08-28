import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';

/// The "Happy New Day" greeting (§5), shown once per calendar day.
///
/// It is a local, instant transition — never gated on a network call — so the
/// app greets you the moment it opens, whether or not today's content has
/// arrived yet.
class HappyNewDayOverlay extends ConsumerStatefulWidget {
  const HappyNewDayOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  ConsumerState<HappyNewDayOverlay> createState() => _HappyNewDayOverlayState();
}

class _HappyNewDayOverlayState extends ConsumerState<HappyNewDayOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss, but a tap anywhere skips it — nobody should have to wait
    // out an animation to reach their day.
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userNameProvider).value ?? 'there';
    final isFirstOfMonth = ref.watch(isFirstOfMonthProvider);

    // Sits above the Navigator via MaterialApp.builder, so it has no Material
    // ancestor of its own — without one, Text falls back to the debug style
    // and renders underlined.
    return Material(
      color: RitualColors.bg,
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: RitualColors.bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstOfMonth) ...[
                    const _FirstOfMonthBanner(),
                    const SizedBox(height: 28),
                  ],
                  _FadeUp(
                    delay: Duration.zero,
                    child: Text(
                      'Happy New Day, $name.',
                      style: RitualText.greeting,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FadeUp(
                    delay: const Duration(milliseconds: 320),
                    child: Text(
                      'Your daily ritual is ready.',
                      style: outfit(
                        size: 15,
                        color: RitualColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _FadeUp(
                    delay: const Duration(milliseconds: 640),
                    child: Text(
                      'Tap to begin',
                      style: RitualText.eyebrow(color: RitualColors.accent),
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

/// Placeholder for the first-of-the-month celebration.
///
/// The video drops in at `assets/video/first-of-the-month.mp4`; until it
/// exists this renders the same message without it, so the 1st is never a
/// broken screen.
class _FirstOfMonthBanner extends StatelessWidget {
  const _FirstOfMonthBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: RitualColors.accentSoft,
        borderRadius: BorderRadius.circular(RitualShape.accentCardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              "It's the first of the month.",
              style: outfit(
                size: 15,
                weight: FontWeight.w800,
                color: RitualColors.accentSoftText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return FutureBuilder<void>(
      future: Future<void>.delayed(delay),
      builder: (context, snapshot) {
        final visible = snapshot.connectionState == ConnectionState.done;
        return AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.25),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 420),
            child: child,
          ),
        );
      },
    );
  }
}

/// Wraps the entire app so the greeting covers the bottom navigation as well
/// as the page body — it is a full-screen moment, not a panel inside a tab.
class GreetingGate extends ConsumerStatefulWidget {
  const GreetingGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GreetingGate> createState() => _GreetingGateState();
}

class _GreetingGateState extends ConsumerState<GreetingGate> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(currentDateProvider);
    final dailyState = ref.watch(dailyStateProvider);

    // While the row loads we show the app rather than a spinner — the greeting
    // is a flourish, never a gate on reaching your day.
    final show = !_dismissed && dailyState.value?.greetingShown == false;

    return Stack(
      children: [
        widget.child,
        if (show)
          HappyNewDayOverlay(
            onDismiss: () async {
              if (_dismissed) return;
              setState(() => _dismissed = true);
              await ref.read(databaseProvider).markGreetingShown(date);
              ref.invalidate(dailyStateProvider);
            },
          ),
      ],
    );
  }
}
