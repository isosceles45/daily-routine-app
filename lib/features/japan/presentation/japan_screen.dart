import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/japan_entry.dart';
import '../providers/japan_providers.dart';

class JapanScreen extends ConsumerWidget {
  const JapanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japan = ref.watch(japanOfTheDayProvider);
    final accent = context.features.japan;

    return DetailScaffold(
      title: 'Japan Of The Day',
      child: japan.when(
        loading: () => LoadingCard(title: 'Japan', accent: accent, lines: 3),
        error: (error, _) => ErrorCard(
          title: 'Japan',
          error: error,
          accent: accent,
          onRetry: () => ref.invalidate(japanOfTheDayProvider),
        ),
        data: (entry) {
          if (entry == null) {
            return ErrorCard(
              title: 'Japan',
              error: 'unavailable',
              accent: accent,
              onRetry: () => ref.invalidate(japanOfTheDayProvider),
            );
          }
          return _Entry(entry: entry, accent: accent);
        },
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.entry, required this.accent});

  final JapanEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final didYouKnow = entry.didYouKnow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(RitualShape.cardRadius),
            child: AdaptivePhoto(url: entry.imageUrl!),
          ),
        const SizedBox(height: 16),
        Eyebrow('Japan of the day', color: accent, letterSpacing: 0.1),
        const SizedBox(height: 4),
        Text(entry.title, style: RitualText.stat(24)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final tag in entry.tags) FeatureChip(tag)],
        ),
        const SizedBox(height: 14),
        Text(
          entry.lead,
          style: outfit(
            size: 14,
            color: RitualColors.textSecondary,
            height: 1.65,
          ),
        ),
        if (didYouKnow != null) ...[
          const SizedBox(height: 16),
          const RitualDivider(strong: false),
          const SizedBox(height: 14),
          Eyebrow('Did you know?', letterSpacing: 0.08),
          const SizedBox(height: 8),
          Text(
            didYouKnow,
            style: outfit(
              size: 14,
              color: RitualColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (entry.pageUrl != null)
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              label: 'Read on Wikipedia',
              expand: false,
              trailingArrow: true,
              onPressed: () => launchUrl(
                Uri.parse(entry.pageUrl!),
                mode: LaunchMode.inAppBrowserView,
              ),
            ),
          ),
        const SizedBox(height: 14),
        Text(
          'Source: Wikipedia · CC BY-SA',
          style: outfit(size: 11, color: RitualColors.textTertiary),
        ),
      ],
    );
  }
}
