import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../app/router.dart';
import '../../../core/providers.dart';
import '../data/wordle_repository.dart';
import '../domain/wordle_share.dart';
import '../domain/wordle_stats.dart';

final wordleRepositoryProvider = Provider<WordleRepository>(
  (ref) => WordleRepository(ref.watch(databaseProvider)),
);

final wordleResultsProvider = StreamProvider<List<WordleResult>>(
  (ref) => ref.watch(wordleRepositoryProvider).watchAll(),
);

final wordleStatsProvider = Provider<WordleStats>((ref) {
  final results = ref.watch(wordleResultsProvider).value;
  if (results == null) return WordleStats.empty;
  return WordleStats.from(results, ref.watch(currentDateProvider));
});

/// Today's result, if it has been imported yet.
final todayWordleProvider = StreamProvider<WordleResult?>((ref) {
  final date = ref.watch(currentDateProvider);
  return ref.watch(wordleRepositoryProvider).watchFor(date);
});

/// The puzzle number published today, shown on the card before you play.
final todayWordleNumberProvider = Provider<int>(
  (ref) => WordleShareParser.numberFor(ref.watch(currentDateProvider)),
);

/// Where a Wordle entry point should go.
///
/// Before today's puzzle is imported, every tap means "play" — so it opens
/// Wordle directly rather than landing on a screen with another Play button.
/// Once there is a result there is nothing to play, so it opens the result.
String wordleRouteFor(WordleResult? todayResult) =>
    todayResult == null ? Routes.wordlePlay : Routes.wordle;

/// Outcome of pasting share text.
sealed class ImportOutcome {
  const ImportOutcome();
}

class ImportedResult extends ImportOutcome {
  const ImportedResult(this.share, {required this.isToday});
  final WordleShare share;

  /// False when an older puzzle was pasted — it is still saved, just filed
  /// under its own date.
  final bool isToday;
}

class ImportRejected extends ImportOutcome {
  const ImportRejected(this.reason);
  final String reason;
}

/// Parses and stores pasted share text (§6).
Future<ImportOutcome> importWordleShare(WidgetRef ref, String text) async {
  if (text.trim().isEmpty) {
    return const ImportRejected('Paste your Wordle result first.');
  }

  final share = WordleShareParser.parse(text);
  if (share == null) {
    return const ImportRejected(
      "That doesn't look like a Wordle share. Use Wordle's Share button and "
      'paste the whole thing.',
    );
  }

  final today = ref.read(currentDateProvider);
  // A puzzle dated after today means a wrong number, a wrong clock, or a
  // paste from somewhere else. Saving it would corrupt the streak.
  if (share.date.compareTo(today) > 0) {
    return const ImportRejected(
      "That puzzle hasn't been published yet — check the number.",
    );
  }

  await ref.read(wordleRepositoryProvider).save(share);
  return ImportedResult(share, isToday: share.date == today);
}
