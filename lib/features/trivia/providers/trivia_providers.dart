import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/network/api_result.dart';
import '../../../core/providers.dart';
import '../data/trivia_repository.dart';
import '../data/trivia_service.dart';
import '../domain/trivia_question.dart';

final triviaServiceProvider = Provider<TriviaService>(
  (ref) => TriviaService(ref.watch(apiClientProvider)),
);

final triviaRepositoryProvider = Provider<TriviaRepository>(
  (ref) => TriviaRepository(
    ref.watch(triviaServiceProvider),
    ref.watch(databaseProvider),
  ),
);

/// Today's question. Rethrows the [ApiException] so the UI can distinguish
/// "offline" from "the source broke" when choosing what to show.
final dailyTriviaProvider = FutureProvider<TriviaQuestion>((ref) async {
  final date = ref.watch(currentDateProvider);
  final result = await ref.watch(triviaRepositoryProvider).questionFor(date);
  return switch (result) {
    Success<TriviaQuestion>(:final data) => data,
    Failure<TriviaQuestion>(:final error) => throw error,
  };
});

/// The saved answer for today, if any. Streamed so the card and the detail
/// screen stay in step without either owning the state.
final triviaResultProvider = StreamProvider<TriviaResult?>((ref) {
  final date = ref.watch(currentDateProvider);
  return ref.watch(triviaRepositoryProvider).watchResult(date);
});

/// Every trivia result ever, for the History timeline and streaks.
final triviaAllResultsProvider = StreamProvider<List<TriviaResult>>(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).triviaResults)
      .watch(),
);

/// Records the user's answer. Answering is one-way — the row is written once
/// and the UI stops offering options afterwards.
Future<void> answerTrivia(WidgetRef ref, String answer) async {
  final date = ref.read(currentDateProvider);
  final question = await ref.read(dailyTriviaProvider.future);
  await ref
      .read(triviaRepositoryProvider)
      .saveAnswer(date: date, question: question, answer: answer);
}
