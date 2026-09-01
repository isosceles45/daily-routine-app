import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/ritual_icon.dart';
import '../../settings/providers/settings_providers.dart';

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
  /// How long an ordinary day's greeting holds the screen.
  static const _ordinaryHold = Duration(milliseconds: 2600);

  /// The 1st opens with a video, and decoding it takes a moment. Holding a
  /// little longer up front means the celebration is never cut off before it
  /// starts; once the video reports its real duration this is replaced.
  static const _celebrationGrace = Duration(seconds: 6);

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss, but a tap anywhere skips it — nobody should have to wait
    // out an animation to reach their day.
    _holdFor(
      ref.read(isFirstOfMonthProvider) ? _celebrationGrace : _ordinaryHold,
    );
  }

  /// (Re)arms the auto-dismiss. Called again once the video knows how long it
  /// runs, or when it turns out there is no video to wait for.
  void _holdFor(Duration duration) {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(duration, () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(preferencesProvider).value?.userName ?? 'there';
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
                    _FirstOfMonthCelebration(
                      // Let the video play out — it is a once-a-month moment —
                      // then move on. A tap still skips it immediately.
                      onReady: (duration) => _holdFor(
                        duration + const Duration(milliseconds: 600),
                      ),
                      onUnavailable: () => _holdFor(_ordinaryHold),
                    ),
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

/// The first-of-the-month celebration.
///
/// Plays `assets/video/first-of-the-month.mp4` above the greeting, falling back
/// to [_FirstOfMonthBanner] whenever it cannot — a missing asset, a codec the
/// device won't decode, anything at all. The 1st is never a broken screen, and
/// the greeting underneath is never gated on the video arriving.
class _FirstOfMonthCelebration extends StatefulWidget {
  const _FirstOfMonthCelebration({
    required this.onReady,
    required this.onUnavailable,
  });

  /// Reports the clip's real duration, so the overlay can hold long enough to
  /// let it finish.
  final void Function(Duration duration) onReady;

  /// There will be no video. The overlay should go back to its ordinary hold
  /// rather than sitting on a static banner for the length of a clip.
  final VoidCallback onUnavailable;

  @override
  State<_FirstOfMonthCelebration> createState() =>
      _FirstOfMonthCelebrationState();
}

class _FirstOfMonthCelebrationState extends State<_FirstOfMonthCelebration> {
  static const _asset = 'assets/video/first-of-the-month.mp4';

  /// Tall enough to be a moment, short enough to leave the greeting on screen
  /// with it on a small phone.
  static const _maxHeight = 340.0;

  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Animations off means a screen reader or a reduced-motion setting; an
    // autoplaying video is exactly what that asks us not to do.
    if (WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      widget.onUnavailable();
      return;
    }

    final controller = VideoPlayerController.asset(_asset);
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Sound on: this is the one moment in the app that gets to be loud.
      // It plays at most once per open, and only on the 1st.
      await controller.setVolume(1);
      await controller.play();

      setState(() => _ready = true);
      widget.onReady(controller.value.duration);
    } catch (_) {
      // Nothing here is worth failing the day over.
      if (mounted) widget.onUnavailable();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // The banner shows first and stays until the video is genuinely playable,
    // so there is never an empty box where the celebration should be.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: !_ready || controller == null
          ? const _FirstOfMonthBanner()
          : LayoutBuilder(
              builder: (context, constraints) {
                // Fill the column's width, but never so tall that the greeting
                // itself is pushed off a small screen — the video is the
                // flourish, the greeting is the point.
                final aspect = controller.value.aspectRatio;
                final height = math.min(
                  constraints.maxWidth / aspect,
                  _maxHeight,
                );

                return ClipRRect(
                  borderRadius: BorderRadius.circular(
                    RitualShape.accentCardRadius,
                  ),
                  child: SizedBox(
                    width: height * aspect,
                    height: height,
                    child: VideoPlayer(controller),
                  ),
                );
              },
            ),
    );
  }
}

/// Shown on the 1st while the video loads, and instead of it if it never does.
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
          const RitualIcon(
            RitualIcons.party,
            size: 22,
            color: RitualColors.accentSoftText,
          ),
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

class _GreetingGateState extends ConsumerState<GreetingGate>
    with WidgetsBindingObserver {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On the 1st the celebration is meant to greet every arrival, so coming
    // back to the app re-arms it. On any other day the greeting stays a
    // once-a-day thing and this does nothing.
    if (state == AppLifecycleState.resumed &&
        _dismissed &&
        ref.read(isFirstOfMonthProvider)) {
      setState(() => _dismissed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(currentDateProvider);
    final dailyState = ref.watch(dailyStateProvider);

    // While the row loads we show the app rather than a spinner — the greeting
    // is a flourish, never a gate on reaching your day.
    //
    // The 1st ignores the once-a-day flag entirely: the celebration plays
    // every time the app is opened that day, not just the first time.
    final show =
        !_dismissed &&
        (ref.watch(isFirstOfMonthProvider) ||
            dailyState.value?.greetingShown == false);

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
