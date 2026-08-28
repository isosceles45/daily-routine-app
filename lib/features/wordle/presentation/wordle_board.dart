import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/wordle_share.dart';

/// Renders an imported Wordle grid.
///
/// The board is read-only by design: the game is played on the NYT site and
/// the result is imported (§6), so there are no letters to show — only the
/// pattern the share text carries.
class WordleBoard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final display = rows.isEmpty
        ? List.filled(_rowCount, '')
        : [
            ...rows,
            // Pad a solved board out to six rows so the grid keeps its shape.
            ...List.filled(_rowCount - rows.length, ''),
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < display.length; i++) ...[
          _Row(
            tiles: display[i],
            tileSize: tileSize,
            gap: gap,
            columns: _columnCount,
          ),
          if (i != display.length - 1) SizedBox(height: gap),
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
  });

  final String tiles;
  final double tileSize;
  final double gap;
  final int columns;

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
          _Tile(state: states[i], size: tileSize),
          if (i != columns - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.state, required this.size});

  /// 'correct', 'present', 'absent', or null for an unplayed square.
  final String? state;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Colours come straight from the canvas's `wordleTile` map.
    final (background, border) = switch (state) {
      'correct' => (RitualColors.success, null),
      'present' => (RitualColors.surfaceRaised, RitualColors.accent),
      'absent' => (Colors.transparent, RitualColors.border),
      _ => (Colors.transparent, RitualColors.borderStrong),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: border == null ? null : Border.all(color: border, width: 1.5),
      ),
    );
  }
}
