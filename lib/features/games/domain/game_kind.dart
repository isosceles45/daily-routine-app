import '../../../shared/widgets/ritual_icon.dart';

/// The games. Every one of them is infinitely replayable and works offline —
/// which is the entire point of the section: the daily content is finished
/// once you have seen it, and these are not.
enum GameKind {
  quantRush('Quant Rush', RitualIcons.bolt, 'Beat the clock at mental maths'),
  sudoku('Sudoku', RitualIcons.grid, 'Classic 9×9, four difficulties'),
  twenty48('2048', RitualIcons.tiles, 'Swipe, merge, chase the tile');

  const GameKind(this.label, this.icon, this.tagline);

  final String label;
  final RitualIcons icon;
  final String tagline;

  /// How a score reads for this game. They are all "higher is better", but
  /// they are not all counts of the same thing.
  String scoreLabel(int score) => switch (this) {
    GameKind.quantRush => '$score correct',
    GameKind.sudoku => '$score pts',
    GameKind.twenty48 => '$score',
  };

  static GameKind fromName(String name) =>
      GameKind.values.firstWhere((g) => g.name == name);
}
