import '../../../core/dates/daily_date_service.dart';

/// A parsed Wordle share, as produced by the NYT "Share" button (§6).
///
/// The app never scrapes the NYT page — this is the only way results enter the
/// app, and the answer itself is deliberately absent because the share text
/// does not contain it.
class WordleShare {
  const WordleShare({
    required this.number,
    required this.score,
    required this.hardMode,
    required this.grid,
    required this.date,
  });

  final int number;

  /// Guesses used, 1–6. Null when the puzzle was failed (`X/6`).
  final int? score;

  final bool hardMode;

  /// Emoji rows, one per guess. Empty when the share omitted the grid.
  final List<String> grid;

  /// The calendar date this puzzle belongs to, derived from [number] — not
  /// from "today". Pasting yesterday's result files it under yesterday, which
  /// is what makes the streak honest.
  final String date;

  bool get completed => score != null;

  String get scoreLabel => '${score ?? 'X'}/6';
}

/// Parses Wordle share text.
///
/// Handles the shapes the NYT actually emits: thousands separators
/// (`Wordle 1,234`), the hard-mode asterisk, failures (`X/6`), light/dark
/// squares, and the colour-blind palette. Anything else returns null rather
/// than guessing.
abstract final class WordleShareParser {
  /// The original Wordle indexed from **zero**: puzzle #0 was 19 June 2021,
  /// so #N is N days later. Getting this wrong by one silently files every
  /// imported result under the previous day — verified against #1896 falling
  /// on 28 August 2026.
  static final DateTime epoch = DateTime(2021, 6, 19);

  static final _header = RegExp(
    r'Wordle\s+([\d,\.\s]+?)\s+([1-6X])\s*/\s*6(\*?)',
    caseSensitive: false,
  );

  /// Grey/black (absent), yellow/blue (present), green/orange (correct).
  static const _tiles = {
    '⬛': 'absent',
    '⬜': 'absent',
    '\u{1F7E8}': 'present',
    '\u{1F7E6}': 'present',
    '\u{1F7E9}': 'correct',
    '\u{1F7E7}': 'correct',
  };

  static bool isTile(String char) => _tiles.containsKey(char);

  static String? tileState(String char) => _tiles[char];

  /// Returns null when [text] isn't a Wordle share.
  static WordleShare? parse(String text) {
    final match = _header.firstMatch(text);
    if (match == null) return null;

    // "1,234" and "1 234" both appear depending on locale.
    final digits = match.group(1)!.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;

    final number = int.tryParse(digits);
    if (number == null || number < 1) return null;

    final scoreToken = match.group(2)!.toUpperCase();
    final score = scoreToken == 'X' ? null : int.parse(scoreToken);
    final hardMode = match.group(3) == '*';

    final grid = _parseGrid(text);

    // A failed board takes all six guesses; a solved one takes exactly as many
    // rows as its score. A grid that disagrees is not trustworthy, so it is
    // dropped while the score — which we can read directly — is kept.
    final expectedRows = score ?? 6;
    final trustedGrid = grid.length == expectedRows ? grid : const <String>[];

    return WordleShare(
      number: number,
      score: score,
      hardMode: hardMode,
      grid: trustedGrid,
      date: dateFor(number),
    );
  }

  static List<String> _parseGrid(String text) {
    final rows = <String>[];

    for (final line in text.split(RegExp(r'\r?\n'))) {
      final tiles = <String>[];
      // Every Wordle tile is a single rune, so runes are enough here and
      // avoid pulling in a grapheme-cluster dependency.
      for (final rune in line.runes) {
        final char = String.fromCharCode(rune);
        if (isTile(char)) tiles.add(char);
      }
      // Wordle rows are always exactly five tiles. Anything else is a stray
      // emoji in surrounding chatter.
      if (tiles.length == 5) rows.add(tiles.join());
    }

    return rows;
  }

  /// The date puzzle [number] was published.
  static String dateFor(int number) =>
      DailyDateService.format(epoch.add(Duration(days: number)));

  /// The puzzle number published on [date].
  static int numberFor(String date) =>
      DailyDateService.daysBetween(DailyDateService.format(epoch), date);
}
