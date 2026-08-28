import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/domain/daily_completion.dart';
import '../../home/providers/completion_providers.dart';
import '../../pokemon/presentation/pokemon_screen.dart';
import '../../japan/presentation/japan_card.dart';
import '../../pokemon/providers/pokemon_providers.dart';
import '../domain/daily_fun.dart';
import '../providers/fun_providers.dart';

/// The Explore tab. Japan and Surprise Me join these in Phase 3.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // Reaching Explore is what completing the fun slot means — there is
    // nothing here to answer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(seenActivitiesProvider.notifier).markSeen(DailyActivity.fun);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final extra = ref.watch(dailyExtraFunProvider);

    return SafeArea(
      bottom: false,
      child: RiseIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text('Explore', style: RitualText.tabTitle),
            const SizedBox(height: 14),
            const RitualDivider(),
            const SizedBox(height: 20),
            // Today owns the big Surprise call to action; Explore only
            // needs a way in. Repeating the full accent card here was what
            // made the two screens feel like the same page.
            const _SurpriseStrip(),
            const SizedBox(height: RitualShape.stackGap),
            const JapanCard(),
            const SizedBox(height: RitualShape.stackGap),
            const _PokemonCard(),
            const SizedBox(height: RitualShape.stackGap),
            _AnimalCard(provider: dailyCatProvider, title: 'Cat of the day'),
            const SizedBox(height: RitualShape.stackGap),
            _AnimalCard(provider: dailyDogProvider, title: 'Dog of the day'),
            if (extra != null) ...[
              const SizedBox(height: RitualShape.stackGap),
              _ExtraFunCard(kind: extra),
            ],
          ],
        ),
      ),
    );
  }
}

class _PokemonCard extends ConsumerWidget {
  const _PokemonCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonOfTheDayProvider);
    final accent = context.features.pokemon;

    return pokemon.when(
      loading: () => LoadingCard(title: 'Pokémon of the day', accent: accent),
      error: (error, _) => ErrorCard(
        title: 'Pokémon of the day',
        error: error,
        accent: accent,
        onRetry: () => ref.invalidate(pokemonOfTheDayProvider),
      ),
      data: (data) => RitualCard(
        padding: RitualShape.cardPaddingCompact,
        onTap: () => context.push(Routes.pokemon),
        child: Row(
          children: [
            PokemonArtwork(url: data.artworkUrl, size: 76),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(
                    'Pokémon of the day',
                    color: accent,
                    size: 10,
                    letterSpacing: 0.08,
                  ),
                  const SizedBox(height: 3),
                  Text(data.displayName, style: RitualText.stat(18)),
                  const SizedBox(height: 4),
                  Text(
                    '${data.dexNumber} · ${data.types.join(' / ')}',
                    style: outfit(size: 12, color: RitualColors.textTertiary),
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
      ),
    );
  }
}

/// A photo card for the cat or the dog.
class _AnimalCard extends ConsumerWidget {
  const _AnimalCard({required this.provider, required this.title});

  final FutureProvider<DailyFun> provider;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fun = ref.watch(provider);
    final accent = context.features.fun;

    return fun.when(
      loading: () => LoadingCard(title: title, accent: accent),
      error: (error, _) => ErrorCard(
        title: title,
        error: error,
        accent: accent,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (data) => RitualCard(
        padding: EdgeInsets.zero,
        clipContents: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.imageUrl != null) AdaptivePhoto(url: data.imageUrl!),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${data.kind.emoji} ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Eyebrow(title, color: accent, letterSpacing: 0.1),
                    ],
                  ),
                  if (data.text != null) ...[
                    const SizedBox(height: 10),
                    // Cat Facts really is about cats. The dog card's text
                    // comes from a general trivia source, because the dog
                    // facts API is dead — so it gets a label that doesn't
                    // pretend otherwise.
                    Eyebrow(
                      data.kind == FunKind.cat ? 'Cat fact' : 'Did you know?',
                      size: 10,
                      letterSpacing: 0.08,
                    ),
                    const SizedBox(height: 5),
                    Text(data.text!, style: RitualText.bodySmall),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Source: ${data.source}',
                    style: outfit(size: 11, color: RitualColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The rotating joke or fact, when the day isn't already an animal day.
class _ExtraFunCard extends ConsumerWidget {
  const _ExtraFunCard({required this.kind});

  final FunKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fun = ref.watch(dailyFunProvider);
    final accent = context.features.fun;

    return fun.when(
      loading: () => LoadingCard(title: kind.label, accent: accent),
      error: (error, _) => ErrorCard(
        title: kind.label,
        error: error,
        accent: accent,
        onRetry: () => ref.invalidate(dailyFunProvider),
      ),
      data: (data) => RitualCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${data.kind.emoji} ',
                  style: const TextStyle(fontSize: 13),
                ),
                Eyebrow(data.kind.label, color: accent, letterSpacing: 0.1),
              ],
            ),
            if (data.text != null) ...[
              const SizedBox(height: 8),
              Text(data.text!, style: RitualText.bodySmall),
            ],
            const SizedBox(height: 10),
            Text(
              'Source: ${data.source}',
              style: outfit(size: 11, color: RitualColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim entry point to Surprise Me.
class _SurpriseStrip extends StatelessWidget {
  const _SurpriseStrip();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RitualColors.accent,
      borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
      child: InkWell(
        onTap: () => context.push(Routes.surprise),
        borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 18,
                color: RitualColors.onAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Surprise me',
                  style: outfit(
                    size: 14,
                    weight: FontWeight.w800,
                    color: RitualColors.onAccent,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: RitualColors.onAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
