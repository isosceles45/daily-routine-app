import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/home/presentation/happy_new_day.dart';
import '../features/onboarding/presentation/onboarding_gate.dart';
import 'router.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) => buildRouter());

class DailyRitualApp extends ConsumerWidget {
  const DailyRitualApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DailyRolloverObserver(
      child: MaterialApp.router(
        title: 'Ritual',
        debugShowCheckedModeBanner: false,
        theme: buildRitualTheme(),
        routerConfig: ref.watch(routerProvider),
        // Onboarding wraps the greeting, not the other way round: a brand new
        // user should be asked their name before being welcomed by it.
        builder: (context, child) => OnboardingGate(
          child: GreetingGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
