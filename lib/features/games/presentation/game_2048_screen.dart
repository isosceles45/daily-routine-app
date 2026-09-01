import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/game_2048.dart';
import '../domain/game_kind.dart';
import '../providers/game_providers.dart';

class Game2048Screen extends ConsumerStatefulWidget {
  const Game2048Screen({super.key});

  @override
  ConsumerState<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends ConsumerState<Game2048Screen> {
  Game2048? _game;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    final saved = await ref
        .read(gameRepositoryProvider)
        .readState(GameKind.twenty48);
    if (!mounted) return;

    if (saved == null) {
      setState(() => _game = Game2048.start());
      return;
    }

    try {
      setState(() => _game = Game2048.fromJson(saved));
    } on Object {
      await ref.read(gameRepositoryProvider).clearState(GameKind.twenty48);
      if (mounted) setState(() => _game = Game2048.start());
    }
  }

  Future<void> _swipe(SwipeDirection direction) async {
    final game = _game;
    if (game == null || game.isGameOver) return;

    final next = game.move(direction);
    // Identity means nothing moved, so there is nothing to save or redraw.
    if (identical(next, game)) return;

    setState(() => _game = next);

    final repo = ref.read(gameRepositoryProvider);
    if (next.isGameOver) {
      await _record(next);
    } else {
      await repo.saveState(GameKind.twenty48, next.toJson());
    }
  }

  Future<void> _record(Game2048 game) async {
    if (_recorded) return;
    _recorded = true;

    final repo = ref.read(gameRepositoryProvider);
    await repo.recordScore(
      game: GameKind.twenty48,
      score: game.score,
      date: ref.read(currentDateProvider),
      detail: {'highestTile': game.highestTile},
    );
    await repo.clearState(GameKind.twenty48);
  }

  Future<void> _restart() async {
    _recorded = false;
    setState(() => _game = Game2048.start());
    await ref.read(gameRepositoryProvider).clearState(GameKind.twenty48);
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final best = ref.watch(gameStatsProvider)[GameKind.twenty48]?.best ?? 0;

    return DetailScaffold(
      title: '2048',
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      // Column rather than ListView: DetailScaffold supplies the scrolling.
      child: game == null
          ? const Center(
              child: CircularProgressIndicator(color: RitualColors.accent),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Score(label: 'Score', value: '${game.score}'),
                    const SizedBox(width: 10),
                    _Score(label: 'Best', value: '$best'),
                    const Spacer(),
                    TextButton(
                      onPressed: _restart,
                      child: Text(
                        'New game',
                        style: outfit(
                          size: 13,
                          weight: FontWeight.w700,
                          color: RitualColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SwipeArea(
                  onSwipe: _swipe,
                  child: _Board(game: game),
                ),
                const SizedBox(height: 16),
                if (game.isGameOver)
                  _GameOver(score: game.score, onRestart: _restart)
                else
                  Text(
                    'Swipe to move. Tiles with the same number merge.',
                    style: outfit(size: 12, color: RitualColors.textTertiary),
                  ),
              ],
            ),
    );
  }
}

/// Turns a drag into one of four moves, on whichever axis dominated.
class _SwipeArea extends StatelessWidget {
  const _SwipeArea({required this.onSwipe, required this.child});

  final void Function(SwipeDirection) onSwipe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v.abs() < 100) return;
        onSwipe(v < 0 ? SwipeDirection.left : SwipeDirection.right);
      },
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v.abs() < 100) return;
        onSwipe(v < 0 ? SwipeDirection.up : SwipeDirection.down);
      },
      child: child,
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.game});

  final Game2048 game;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: RitualColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RitualColors.border),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: Game2048.cells,
          itemBuilder: (context, i) => _Tile(value: game.tiles[i]),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value});

  final int value;

  /// Warmer and brighter as the value climbs, so progress is visible at a
  /// glance without reading a single number.
  static Color _colorFor(int value) => switch (value) {
    0 => RitualColors.surfaceRaised,
    2 => const Color(0xFF2E2C3A),
    4 => const Color(0xFF3A3550),
    8 => const Color(0xFF4A3A66),
    16 => const Color(0xFF5E3D74),
    32 => const Color(0xFF7A3E78),
    64 => const Color(0xFF9B3F72),
    128 => const Color(0xFFBF4470),
    256 => const Color(0xFFDB4A6E),
    512 => const Color(0xFFF05475),
    1024 => const Color(0xFFFF5CA8),
    _ => const Color(0xFFFFC24D),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: _colorFor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: value == 0
          ? null
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  '$value',
                  style: outfit(
                    size: value >= 1024 ? 20 : 24,
                    weight: FontWeight.w800,
                    color: value >= 1024
                        ? RitualColors.onAccent
                        : RitualColors.text,
                  ),
                ),
              ),
            ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: RitualColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RitualColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label, size: 9, letterSpacing: 0.1),
          Text(value, style: RitualText.stat(17)),
        ],
      ),
    );
  }
}

class _GameOver extends StatelessWidget {
  const _GameOver({required this.score, required this.onRestart});

  final int score;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No moves left', style: RitualText.stat(22)),
        const SizedBox(height: 4),
        Text('Final score $score', style: RitualText.bodySmall),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Play again', onPressed: onRestart),
      ],
    );
  }
}
