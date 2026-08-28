import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../settings/providers/settings_providers.dart';
import 'onboarding_screen.dart';

/// Shows onboarding on first launch, then never again.
///
/// Sits outside the router so it covers the whole app, including the bottom
/// navigation.
class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  bool _justFinished = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);

    // Preferences come from the database, so there is a frame or two before we
    // know. Showing the app and then yanking it away for onboarding would be
    // worse than a moment of the background colour.
    if (prefs.isLoading) {
      return const ColoredBox(color: RitualColors.bg, child: SizedBox.expand());
    }

    final done = _justFinished || (prefs.value?.onboardingComplete ?? true);
    if (done) return widget.child;

    return OnboardingScreen(onDone: () => setState(() => _justFinished = true));
  }
}
