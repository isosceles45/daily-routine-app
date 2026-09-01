import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/domain/daily_completion.dart';
import '../../home/providers/completion_providers.dart';
import '../../pokemon/presentation/pokemon_screen.dart';
import '../../places/presentation/place_card.dart';
import '../../pokemon/providers/pokemon_providers.dart';
import '../domain/daily_fun.dart';
import '../providers/fun_providers.dart';

/// The Explore tab: the day's place, Pokémon and animal, plus Surprise Me.
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
            const PlaceCard(),
            const SizedBox(height: RitualShape.stackGap),
            const _PokemonCard(),
            const SizedBox(height: RitualShape.stackGap),
            const _MenagerieCard(),
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

/// The animal card, with the whole menagerie behind it.
///
/// The day's animal is shown from the daily cache, so it is there offline and
/// does not change underfoot. Picking a species — or asking for another —
/// fetches fresh, outside the cache: that is the part you can keep pulling on
/// rather than a card that is finished the moment you have seen it.
class _MenagerieCard extends ConsumerStatefulWidget {
  const _MenagerieCard();

  @override
  ConsumerState<_MenagerieCard> createState() => _MenagerieCardState();
}

class _MenagerieCardState extends ConsumerState<_MenagerieCard> {
  /// Null means "today's animal, from the cache". Non-null means the user has
  /// asked for something specific and we are fetching live.
  FunKind? _picked;

  /// Bumped on every "another one", so the family key changes and the request
  /// actually goes out again instead of replaying a cached future.
  int _nonce = 0;

  void _select(FunKind kind) {
    setState(() {
      // Tapping the species you are already looking at means "another one".
      if (_picked == kind) {
        _nonce++;
      } else {
        _picked = kind;
        _nonce++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.features.fun;
    final todayKind = ref.watch(animalOfTheDayKindProvider);
    final showing = _picked ?? todayKind;

    final fun = _picked == null
        ? ref.watch(animalOfTheDayProvider)
        : ref.watch(freshAnimalProvider((kind: _picked!, nonce: _nonce)));

    void retry() {
      if (_picked == null) {
        ref.invalidate(animalOfTheDayProvider);
      } else {
        ref.invalidate(freshAnimalProvider((kind: _picked!, nonce: _nonce)));
      }
    }

    final title = _picked == null
        ? 'Animal of the day'
        : '${showing.label} on demand';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fun.when(
          loading: () => LoadingCard(title: title, accent: accent),
          error: (error, _) => ErrorCard(
            title: title,
            error: error,
            accent: accent,
            onRetry: retry,
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
                          RitualIcon(data.kind.icon, size: 15, color: accent),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Eyebrow(
                              title,
                              color: accent,
                              letterSpacing: 0.1,
                            ),
                          ),
                          _AnotherButton(onTap: () => _select(showing)),
                        ],
                      ),
                      if (data.text != null) ...[
                        const SizedBox(height: 10),
                        // Cat Facts really is about cats. Every other species
                        // borrows a general trivia source, so it gets a label
                        // that does not pretend otherwise.
                        Eyebrow(
                          data.kind == FunKind.cat
                              ? 'Cat fact'
                              : 'Did you know?',
                          size: 10,
                          letterSpacing: 0.08,
                        ),
                        const SizedBox(height: 5),
                        Text(data.text!, style: RitualText.bodySmall),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Source: ${data.source}',
                        style: outfit(
                          size: 11,
                          color: RitualColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _SpeciesPicker(
          selected: showing,
          isLive: _picked != null,
          onSelect: _select,
          onBackToToday: () => setState(() => _picked = null),
        ),
      ],
    );
  }
}

/// The row of species chips under the animal card.
class _SpeciesPicker extends StatelessWidget {
  const _SpeciesPicker({
    required this.selected,
    required this.isLive,
    required this.onSelect,
    required this.onBackToToday,
  });

  final FunKind selected;
  final bool isLive;
  final void Function(FunKind) onSelect;
  final VoidCallback onBackToToday;

  @override
  Widget build(BuildContext context) {
    final accent = context.features.fun;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final kind in FunKind.animals)
          _Chip(
            icon: kind.icon,
            label: kind.label,
            selected: kind == selected,
            accent: accent,
            onTap: () => onSelect(kind),
          ),
        if (isLive)
          _Chip(
            icon: RitualIcons.calendar,
            label: "Today's",
            selected: false,
            accent: accent,
            onTap: onBackToToday,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final RitualIcons icon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accent.withValues(alpha: 0.18) : RitualColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? accent : RitualColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RitualIcon(
                icon,
                size: 14,
                color: selected ? accent : RitualColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: outfit(
                  size: 12,
                  weight: FontWeight.w700,
                  color: selected ? accent : RitualColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnotherButton extends StatelessWidget {
  const _AnotherButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.refresh,
            size: 16,
            color: RitualColors.textTertiary,
          ),
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
                RitualIcon(data.kind.icon, size: 15, color: accent),
                const SizedBox(width: 7),
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
