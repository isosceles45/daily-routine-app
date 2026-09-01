import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../../../core/utils/daily_seed.dart';
import '../domain/trivia_question.dart';

/// Talks to OpenTDB. Knows nothing about caching or persistence.
class TriviaService {
  const TriviaService(this._client);

  final ApiClient _client;

  /// OpenTDB session tokens suppress repeats for ~6 hours of inactivity.
  /// Worth having, never worth failing over.
  Future<String?> requestToken() async {
    final result = await _client.getJson<String?>(
      ApiSources.openTriviaToken,
      query: const {'command': 'request'},
      parse: (json) {
        final map = json as Map<String, dynamic>;
        return map['response_code'] == 0 ? map['token'] as String? : null;
      },
    );
    return result.dataOrNull;
  }

  Future<ApiResult<TriviaQuestion>> fetchDaily({
    required String date,
    String? token,
  }) async {
    final category = TriviaCategory.forDate(date);
    final difficulty = dailyPick(date, 'trivia-difficulty', const [
      'easy',
      'medium',
      'hard',
    ]);

    return _client.getJson<TriviaQuestion>(
      ApiSources.openTrivia,
      query: {
        'amount': 1,
        'category': category.id,
        'difficulty': difficulty,
        'type': 'multiple',
        // Percent-encoding sidesteps OpenTDB's HTML entities, which would
        // otherwise surface as raw `&quot;` in the UI.
        'encode': 'url3986',
        'token': ?token,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final code = map['response_code'] as int? ?? -1;

        // 1 = no results, 3 = token missing, 4 = token exhausted. None are
        // HTTP errors, so they have to be caught here.
        if (code != 0) {
          throw FormatException('OpenTDB response_code $code');
        }

        final results = map['results'] as List<dynamic>? ?? const [];
        if (results.isEmpty) {
          throw const FormatException('OpenTDB returned no questions');
        }

        return TriviaQuestion.fromOpenTdb(
          results.first as Map<String, dynamic>,
          date: date,
        );
      },
    );
  }

  /// Fallback when OpenTDB has nothing for the chosen category/difficulty.
  Future<ApiResult<TriviaQuestion>> fetchBackup({required String date}) async {
    return _client.getJson<TriviaQuestion>(
      ApiSources.triviaApiBackup,
      query: const {'limit': 1},
      parse: (json) {
        final list = json as List<dynamic>;
        if (list.isEmpty) {
          throw const FormatException('The Trivia API returned no questions');
        }
        final item = list.first as Map<String, dynamic>;
        final question =
            (item['question'] as Map<String, dynamic>)['text'] as String;
        final correct = item['correctAnswer'] as String;
        final incorrect = (item['incorrectAnswers'] as List<dynamic>)
            .cast<String>();

        final answers = [correct, ...incorrect]
          ..shuffle(dailyRandom(date, 'trivia-answers'));

        return TriviaQuestion(
          id: TriviaQuestion.idFor(question),
          category: (item['category'] as String? ?? 'General Knowledge')
              .replaceAll('_', ' '),
          difficulty: item['difficulty'] as String? ?? 'medium',
          question: question,
          correctAnswer: correct,
          incorrectAnswers: incorrect,
          answers: List.unmodifiable(answers),
          source: 'The Trivia API',
        );
      },
    );
  }
}

/// Thrown when both trivia sources are exhausted.
const triviaUnavailable = ApiException(
  ApiErrorKind.empty,
  'No trivia source returned a question',
);
