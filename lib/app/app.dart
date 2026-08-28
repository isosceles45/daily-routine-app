import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/home/presentation/happy_new_day.dart';
import 'router.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) => buildRouter());

class DailyRitualApp extends ConsumerWidget {
  const DailyRitualApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DailyRolloverObserver(
      child: MaterialApp.router(
        title: 'Daily Ritual',
        debugShowCheckedModeBanner: false,
        theme: buildRitualTheme(),
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) =>
            GreetingGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
