import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/network/connectivity.dart';
import 'labels.dart';

/// A quiet strip shown while the device has no connection.
///
/// Cached content stays on screen underneath — this explains why nothing new
/// is arriving, rather than replacing the day with an error (§17).
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOfflineProvider)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: RitualColors.accentSoft,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 14, color: RitualColors.accentSoftText),
          const SizedBox(width: 8),
          Eyebrow(
            "Offline — showing what's saved",
            color: RitualColors.accentSoftText,
            size: 10,
            letterSpacing: 0.08,
          ),
        ],
      ),
    );
  }
}
