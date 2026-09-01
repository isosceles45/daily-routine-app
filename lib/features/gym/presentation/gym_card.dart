import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/gym_providers.dart';

/// The gym summary on the Todos tab — today's focus and how far through it
/// you are. The session itself lives on [Routes.gym].
class GymCard extends ConsumerWidget {
  const GymCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(todayFocusProvider);
    final done = ref.watch(todayDoneProvider);
    final session = ref.watch(todaySessionProvider).value ?? const [];

    final subtitle = switch ((focus.isRest, done.length)) {
      (true, _) => 'Rest day',
      (false, 0) when session.isEmpty => 'Tap to plan the session',
      (false, 0) => '${session.length} exercises suggested',
      (false, final n) => '$n logged',
    };

    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      onTap: () => context.push(Routes.gym),
      child: Row(
        children: [
          RitualIcon(focus.icon, size: 22, color: RitualColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(
                  'Gym today',
                  color: RitualColors.accent,
                  size: 10,
                  letterSpacing: 0.08,
                ),
                const SizedBox(height: 3),
                Text(focus.label, style: RitualText.stat(17)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: outfit(
                    size: 12,
                    color: done.isEmpty
                        ? RitualColors.textTertiary
                        : RitualColors.success,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            size: 16,
            color: RitualColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
