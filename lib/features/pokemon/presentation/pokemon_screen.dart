import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/domain/daily_completion.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/providers/completion_providers.dart';
import '../domain/daily_pokemon.dart';
import '../providers/pokemon_providers.dart';

class PokemonScreen extends ConsumerStatefulWidget {
  const PokemonScreen({super.key});

  @override
  ConsumerState<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends ConsumerState<PokemonScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the screen is what "doing" this activity means — there is
    // nothing to answer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seenActivitiesProvider.notifier).markSeen(DailyActivity.pokemon);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = ref.watch(pokemonOfTheDayProvider);
    final accent = context.features.pokemon;

    return DetailScaffold(
      title: 'Pokémon Of The Day',
      child: pokemon.when(
        loading: () => LoadingCard(title: 'Pokémon', accent: accent, lines: 3),
        error: (error, _) => ErrorCard(
          title: 'Pokémon',
          error: error,
          accent: accent,
          onRetry: () => ref.invalidate(pokemonOfTheDayProvider),
        ),
        data: (data) => _Details(pokemon: data, accent: accent),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.pokemon, required this.accent});

  final DailyPokemon pokemon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: PokemonArtwork(url: pokemon.artworkUrl, size: 220)),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                'No. ${pokemon.id}',
                style: outfit(
                  size: 12,
                  weight: FontWeight.w700,
                  color: RitualColors.textTertiary,
                ),
              ),
              Text(pokemon.displayName, style: RitualText.stat(26)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  for (final type in pokemon.types)
                    FeatureChip(type, color: accent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (pokemon.flavorText != null) ...[
          Text(pokemon.flavorText!, style: RitualText.body),
          const SizedBox(height: 14),
          const RitualDivider(strong: false),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: StatBlock(
                value: pokemon.heightLabel,
                label: 'Height',
                size: 16,
              ),
            ),
            Expanded(
              child: StatBlock(
                value: pokemon.weightLabel,
                label: 'Weight',
                size: 16,
              ),
            ),
            Expanded(
              child: StatBlock(
                value: '${pokemon.abilities.length}',
                label: 'Abilities',
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final stat in pokemon.stats)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    stat.label,
                    style: outfit(
                      size: 11,
                      weight: FontWeight.w800,
                      color: RitualColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stat.fraction,
                      minHeight: 8,
                      backgroundColor: RitualColors.surface,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${stat.value}',
                    textAlign: TextAlign.right,
                    style: outfit(size: 12, color: RitualColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        if (pokemon.abilities.isNotEmpty) ...[
          const SizedBox(height: 8),
          Eyebrow('Abilities'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ability in pokemon.abilities)
                FeatureChip(ability.replaceAll('-', ' ')),
            ],
          ),
        ],
      ],
    );
  }
}

/// Artwork with its own loading and failure states, so a slow or missing
/// sprite never leaves a blank hole in the layout.
class PokemonArtwork extends StatelessWidget {
  const PokemonArtwork({super.key, required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, _) => _placeholder(),
      errorWidget: (context, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: RitualColors.surface,
      borderRadius: BorderRadius.circular(RitualShape.cardRadius),
    ),
    child: const Icon(
      Icons.catching_pokemon,
      color: RitualColors.textTertiary,
      size: 32,
    ),
  );
}
