import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/game_repository.dart';
import '../domain/game_kind.dart';
import '../providers/game_providers.dart';

/// The Play tab: the part of the app that is never "done for today".
class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gameStatsProvider);

    return SafeArea(
      bottom: false,
      child: RiseIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text('Play', style: RitualText.tabTitle),
            const SizedBox(height: 4),
            Text(
              'No streaks, no daily limit. Play as much as you like.',
              style: outfit(size: 12.5, color: RitualColors.textTertiary),
            ),
            const SizedBox(height: 14),
            const RitualDivider(),
            const SizedBox(height: 20),
            for (final game in GameKind.values) ...[
              _GameTile(
                game: game,
                stats: stats[game] ?? GameStats.empty,
                onTap: () => context.push(_routeFor(game)),
              ),
              const SizedBox(height: RitualShape.stackGap),
            ],
          ],
        ),
      ),
    );
  }

  static String _routeFor(GameKind game) => switch (game) {
    GameKind.quantRush => Routes.quantRush,
    GameKind.sudoku => Routes.sudoku,
    GameKind.twenty48 => Routes.twenty48,
  };
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.game,
    required this.stats,
    required this.onTap,
  });

  final GameKind game;
  final GameStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      onTap: onTap,
      child: Row(
        children: [
          RitualIcon(game.icon, size: 26, color: RitualColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.label, style: RitualText.stat(18)),
                const SizedBox(height: 3),
                Text(
                  game.tagline,
                  style: outfit(size: 12, color: RitualColors.textTertiary),
                ),
                if (stats.best != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Best ${game.scoreLabel(stats.best!)} · '
                    '${stats.plays} play${stats.plays == 1 ? '' : 's'}',
                    style: outfit(
                      size: 11.5,
                      weight: FontWeight.w700,
                      color: RitualColors.accent,
                    ),
                  ),
                ],
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
