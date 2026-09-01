import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../data/cat_question_source.dart';
import '../data/cat_repository.dart';
import '../data/math_verifier.dart';
import '../domain/cat_question.dart';

final mathVerifierProvider = Provider<MathVerifier>(
  (ref) => MathVerifier(ref.watch(apiClientProvider)),
);

/// The chain from §8, in order. The generated tier is last and always answers.
final catQuestionChainProvider = Provider<CatQuestionChain>((ref) {
  final client = ref.watch(apiClientProvider);
  return CatQuestionChain([
    OpenTdbMathSource(client),
    RemoteBankSource(client),
    GeneratedSource(ref.watch(mathVerifierProvider)),
  ]);
});

final catRepositoryProvider = Provider<CatRepository>(
  (ref) => CatRepository(
    ref.watch(catQuestionChainProvider),
    ref.watch(databaseProvider),
  ),
);

/// Today's CAT question, or null when every tier came up empty — in which case
/// the UI shows the spec's `TRY AGAIN` state rather than a fabricated question.
final catQuestionProvider = FutureProvider<CatQuestion?>((ref) async {
  final date = ref.watch(currentDateProvider);
  return ref.watch(catRepositoryProvider).questionFor(date);
});

final catResultProvider = StreamProvider<CatQuantResult?>((ref) {
  final date = ref.watch(currentDateProvider);
  return ref.watch(catRepositoryProvider).watchResult(date);
});

final catAccuracyProvider = Provider<CatAccuracy>((ref) {
  final results = ref.watch(catAllResultsProvider).value;
  return results == null ? CatAccuracy.empty : CatAccuracy.from(results);
});

final catAllResultsProvider = StreamProvider<List<CatQuantResult>>(
  (ref) => ref.watch(catRepositoryProvider).watchAllResults(),
);

Future<void> answerCatQuestion(WidgetRef ref, int index) async {
  final date = ref.read(currentDateProvider);
  final question = await ref.read(catQuestionProvider.future);
  if (question == null) return;

  await ref
      .read(catRepositoryProvider)
      .saveAnswer(date: date, question: question, selectedIndex: index);
}

/// Drops the cached question and fetches a new one — the `TRY AGAIN` action.
Future<void> retryCatQuestion(WidgetRef ref) async {
  final date = ref.read(currentDateProvider);
  await ref.read(catRepositoryProvider).invalidate(date);
  ref.invalidate(catQuestionProvider);
}
