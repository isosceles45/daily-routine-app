import 'dart:math';

enum SwipeDirection { left, right, up, down }

/// An immutable 2048 board.
///
/// Every move returns a new board rather than mutating this one, which is what
/// lets the UI animate from one state to the next and lets the tests assert on
/// exact boards instead of on side effects.
class Game2048 {
  const Game2048({
    required this.tiles,
    required this.score,
    this.best2048Reached = false,
  });

  static const size = 4;
  static const cells = 16;

  /// 16 cells, row-major. 0 is empty; every other value is a power of two.
  final List<int> tiles;

  final int score;

  /// Whether a 2048 tile has been made. The game deliberately continues after
  /// it — stopping at the nominal win throws away the actual high score.
  final bool best2048Reached;

  static Game2048 start([Random? random]) {
    final rng = random ?? Random();
    var tiles = List.filled(cells, 0);
    tiles = _spawn(tiles, rng);
    tiles = _spawn(tiles, rng);
    return Game2048(tiles: tiles, score: 0);
  }

  /// Applies a swipe. Returns the same instance when nothing moved, so the
  /// caller can tell a no-op apart from a real move — a tile must only spawn
  /// when the board actually changed.
  Game2048 move(SwipeDirection direction, [Random? random]) {
    final rng = random ?? Random();
    final moved = List.filled(cells, 0);
    var gained = 0;

    for (var line = 0; line < size; line++) {
      final indices = _lineIndices(direction, line);
      final values = [for (final i in indices) tiles[i]];

      final (collapsed, points) = _collapse(values);
      gained += points;

      for (var i = 0; i < size; i++) {
        moved[indices[i]] = collapsed[i];
      }
    }

    if (_same(moved, tiles)) return this;

    return Game2048(
      tiles: _spawn(moved, rng),
      score: score + gained,
      best2048Reached: best2048Reached || moved.any((v) => v >= 2048),
    );
  }

  /// Slides one line towards the start and merges equal neighbours once each.
  ///
  /// Merging is single-pass on purpose: `[2, 2, 4]` becomes `[4, 4]`, never
  /// `[8]`. A tile produced by a merge cannot merge again in the same move.
  static (List<int>, int) _collapse(List<int> line) {
    final packed = [
      for (final v in line)
        if (v != 0) v,
    ];
    final result = <int>[];
    var points = 0;

    for (var i = 0; i < packed.length; i++) {
      if (i + 1 < packed.length && packed[i] == packed[i + 1]) {
        final merged = packed[i] * 2;
        result.add(merged);
        points += merged;
        i++;
      } else {
        result.add(packed[i]);
      }
    }

    while (result.length < size) {
      result.add(0);
    }
    return (result, points);
  }

  /// The cell indices of one row or column, ordered so that index 0 is the
  /// end tiles slide *towards*.
  static List<int> _lineIndices(SwipeDirection direction, int line) {
    return switch (direction) {
      SwipeDirection.left => [for (var c = 0; c < size; c++) line * size + c],
      SwipeDirection.right => [
        for (var c = size - 1; c >= 0; c--) line * size + c,
      ],
      SwipeDirection.up => [for (var r = 0; r < size; r++) r * size + line],
      SwipeDirection.down => [
        for (var r = size - 1; r >= 0; r--) r * size + line,
      ],
    };
  }

  static List<int> _spawn(List<int> tiles, Random rng) {
    final empty = [
      for (var i = 0; i < cells; i++)
        if (tiles[i] == 0) i,
    ];
    if (empty.isEmpty) return tiles;

    final next = [...tiles];
    // The original game's distribution: a 4 one time in ten.
    next[empty[rng.nextInt(empty.length)]] = rng.nextInt(10) == 0 ? 4 : 2;
    return next;
  }

  static bool _same(List<int> a, List<int> b) {
    for (var i = 0; i < cells; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// True when no swipe would change anything.
  bool get isGameOver {
    if (tiles.contains(0)) return false;

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final value = tiles[r * size + c];
        if (c + 1 < size && tiles[r * size + c + 1] == value) return false;
        if (r + 1 < size && tiles[(r + 1) * size + c] == value) return false;
      }
    }
    return true;
  }

  int get highestTile => tiles.fold(0, (a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
    'tiles': tiles,
    'score': score,
    'reached2048': best2048Reached,
  };

  factory Game2048.fromJson(Map<String, dynamic> json) => Game2048(
    tiles: (json['tiles'] as List<dynamic>).cast<int>(),
    score: json['score'] as int,
    best2048Reached: json['reached2048'] as bool? ?? false,
  );
}
