import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/wordle_share.dart';

/// Renders an imported Wordle grid.
///
/// The board is read-only by design: the game is played on the NYT site and
/// the result is imported (§6), so there are no letters to show — only the
/// pattern the share text carries.
class WordleBoard extends StatefulWidget {
  const WordleBoard({
    super.key,
    required this.rows,
    this.tileSize = 44,
    this.gap = 5,
  });

  /// Emoji rows from [WordleShare.grid]. Empty renders a blank six-row board.
  final List<String> rows;

  final double tileSize;
  final double gap;

  static const _rowCount = 6;
  static const _columnCount = 5;

  @override
  State<WordleBoard> createState() => _WordleBoardState();
}

class _WordleBoardState extends State<WordleBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.rows.isNotEmpty) _controller.forward();
  }

  @override
  void didUpdateWidget(WordleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replay only when the board actually changes — importing a result should
    // reveal, a rebuild should not.
    if (widget.rows.join() != oldWidget.rows.join()) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.rows;
    final display = rows.isEmpty
        ? List.filled(WordleBoard._rowCount, '')
        : [
            ...rows,
            // Pad a solved board out to six rows so the grid keeps its shape.
            ...List.filled(WordleBoard._rowCount - rows.length, ''),
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < display.length; i++) ...[
          _Row(
            tiles: display[i],
            tileSize: widget.tileSize,
            gap: widget.gap,
            columns: WordleBoard._columnCount,
            rowIndex: i,
            controller: _controller,
            animate: rows.isNotEmpty,
          ),
          if (i != display.length - 1) SizedBox(height: widget.gap),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.tiles,
    required this.tileSize,
    required this.gap,
    required this.columns,
    required this.rowIndex,
    required this.controller,
    required this.animate,
  });

  final String tiles;
  final double tileSize;
  final double gap;
  final int columns;
  final int rowIndex;
  final AnimationController controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final states = <String?>[];
    for (final rune in tiles.runes) {
      states.add(WordleShareParser.tileState(String.fromCharCode(rune)));
    }
    while (states.length < columns) {
      states.add(null);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < columns; i++) ...[
          _Tile(
            state: states[i],
            size: tileSize,
            // Left to right, top to bottom — the order the tiles were earned.
            step: rowIndex * columns + i,
            controller: controller,
            animate: animate,
          ),
          if (i != columns - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.state,
    required this.size,
    required this.step,
    required this.controller,
    required this.animate,
  });

  /// 'correct', 'present', 'absent', or null for an unplayed square.
  final String? state;
  final double size;

  /// Position in the reveal order.
  final int step;

  final AnimationController controller;
  final bool animate;

  static const _totalSteps = 30;

  @override
  Widget build(BuildContext context) {
    // Green for correct, amber for present — the convention the game itself
    // established, so the board is readable without a legend.
    final (background, border) = switch (state) {
      'correct' => (RitualColors.success, null),
      'present' => (RitualColors.wordlePresent, null),
      'absent' => (Colors.transparent, RitualColors.border),
      _ => (Colors.transparent, RitualColors.borderStrong),
    };

    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: border == null ? null : Border.all(color: border, width: 1.5),
      ),
    );

    if (!animate || MediaQuery.disableAnimationsOf(context)) return tile;

    // Each tile flips in slightly after the one before it, so an imported
    // board reveals the way it was played rather than appearing all at once.
    final start = (step / _totalSteps) * 0.6;
    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.scale(scale: 0.7 + (0.3 * curve.value), child: child),
      ),
      child: tile,
    );
  }
}
