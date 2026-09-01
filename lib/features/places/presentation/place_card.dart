import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/place_providers.dart';

/// Japan teaser, used on Explore and on the tablet layout's second column.
class PlaceCard extends ConsumerWidget {
  const PlaceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japan = ref.watch(placeOfTheDayProvider);
    final accent = context.features.place;

    return japan.when(
      loading: () => LoadingCard(title: 'Place of the day', accent: accent),
      error: (error, _) => ErrorCard(
        title: 'Place of the day',
        error: error,
        accent: accent,
        onRetry: () => ref.invalidate(placeOfTheDayProvider),
      ),
      data: (entry) {
        if (entry == null) {
          return ErrorCard(
            title: 'Place of the day',
            error: 'unavailable',
            accent: accent,
            onRetry: () => ref.invalidate(placeOfTheDayProvider),
          );
        }

        return RitualCard(
          padding: EdgeInsets.zero,
          clipContents: true,
          onTap: () => context.push(Routes.place),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.imageUrl != null) AdaptivePhoto(url: entry.imageUrl!),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(
                      'Place of the day',
                      color: accent,
                      letterSpacing: 0.1,
                    ),
                    const SizedBox(height: 4),
                    Text(entry.title, style: RitualText.stat(18)),
                    const SizedBox(height: 6),
                    Text(
                      entry.lead,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: RitualText.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
