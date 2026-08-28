import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/domain/daily_completion.dart';
import '../../home/providers/completion_providers.dart';
import '../../pokemon/presentation/pokemon_screen.dart';
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
            if (data.imageUrl != null) AnimalPhoto(url: data.imageUrl!),
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

/// Animal photos arrive at wildly different aspect ratios, and these are
/// pictures of a specific animal — a fixed band either lops off heads and
/// tails (cover) or strands the photo in wide grey margins (contain).
///
/// Instead the card takes the photo's own shape, clamped only at the extremes
/// so a panorama or a tower can't dominate the screen. Inside the clamp there
/// is no crop at all, which is where nearly every photo lands.
class AnimalPhoto extends StatefulWidget {
  const AnimalPhoto({super.key, required this.url});

  final String url;

  /// Tall-portrait and wide-landscape limits for the card.
  static const minRatio = 0.72;
  static const maxRatio = 1.9;
  static const fallbackRatio = 4 / 3;

  @override
  State<AnimalPhoto> createState() => _AnimalPhotoState();
}

class _AnimalPhotoState extends State<AnimalPhoto> {
  late CachedNetworkImageProvider _provider;
  ImageStreamListener? _listener;
  ImageStream? _stream;
  double? _ratio;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _provider = CachedNetworkImageProvider(widget.url);
    _resolve();
  }

  void _resolve() {
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _ratio = info.image.width / info.image.height);
      },
      onError: (error, stack) {
        if (mounted) setState(() => _failed = true);
      },
    );
    _listener = listener;
    _stream = _provider.resolve(const ImageConfiguration())
      ..addListener(listener);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (_ratio ?? AnimalPhoto.fallbackRatio).clamp(
      AnimalPhoto.minRatio,
      AnimalPhoto.maxRatio,
    );

    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        color: RitualColors.surfaceRaised,
        child: _failed
            ? const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: RitualColors.textTertiary,
                ),
              )
            : _ratio == null
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RitualColors.textTertiary,
                  ),
                ),
              )
            : Image(
                image: _provider,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }
}
