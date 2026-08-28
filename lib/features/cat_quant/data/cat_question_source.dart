import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../../../core/utils/daily_seed.dart';
import '../domain/cat_question.dart';
import '../domain/cat_templates.dart';
import 'math_verifier.dart';

/// One tier of the `CatQuestionProvider` chain (§8).
abstract class CatQuestionSource {
  const CatQuestionSource();

  String get name;

  /// Returns null when this tier has nothing suitable for [date], so the chain
  /// moves on.
  Future<CatQuestion?> questionFor(String date);
}

/// OpenTDB's mathematics category, filtered hard.
///
/// In practice this almost always rejects: OpenTDB's "Science: Mathematics"
/// is general trivia ("Integration is the reverse of what operation?"), not
/// quantitative aptitude. It stays in the chain because the spec asks for a
/// public-API tier first, and on the rare day it yields something numeric and
/// non-trivial that is a better answer than a generated one.
class OpenTdbMathSource extends CatQuestionSource {
  const OpenTdbMathSource(this._client);

  final ApiClient _client;

  @override
  String get name => 'OpenTDB';

  static const _mathematicsCategory = 19;

  @override
  Future<CatQuestion?> questionFor(String date) async {
    final result = await _client.getJson<Map<String, dynamic>>(
      ApiSources.openTrivia,
      query: const {
        'amount': 1,
        'category': _mathematicsCategory,
        'difficulty': 'hard',
        'type': 'multiple',
        'encode': 'url3986',
      },
      parse: (json) => json as Map<String, dynamic>,
    );

    if (result case Success<Map<String, dynamic>>(:final data)) {
      if (data['response_code'] != 0) return null;

      final results = data['results'] as List<dynamic>? ?? const [];
      if (results.isEmpty) return null;

      final item = results.first as Map<String, dynamic>;
      String decode(Object? v) => Uri.decodeComponent('${v ?? ''}');

      final stem = decode(item['question']);
      final correct = decode(item['correct_answer']);
      final wrong = (item['incorrect_answers'] as List<dynamic>).map(decode);

      if (!_isQuantitative(stem, correct)) return null;

      final options = [correct, ...wrong]
        ..shuffle(dailyRandom(date, 'cat-options'));

      return CatQuestion(
        id: CatQuestion.idFor(stem),
        topic: 'Mathematics',
        difficulty: 'Hard',
        stem: stem,
        options: options,
        answerIndex: options.indexOf(correct),
        // OpenTDB never ships a worked solution, and inventing one would be
        // exactly the fabrication §8 forbids.
        solution: null,
        source: CatSource.openTdb,
        verification: CatVerification.sourceProvided,
      );
    }

    return null;
  }

  /// Keeps only questions that are actually computational.
  static bool _isQuantitative(String stem, String answer) {
    // The answer has to be a number — a word answer means it is trivia about
    // mathematics rather than a quantitative problem.
    final numeric = RegExp(r'^-?[\d,]+(\.\d+)?%?$');
    if (!numeric.hasMatch(answer.trim())) return false;

    // And the question has to pose a calculation, not ask for a fact.
    const factual = ['who', 'when was', 'named after', 'discovered', 'invented'];
    final lower = stem.toLowerCase();
    if (factual.any(lower.contains)) return false;

    return stem.contains(RegExp(r'\d'));
  }
}

/// An optional remote question bank, disabled while
/// [ApiSources.catQuestionBank] is null.
class RemoteBankSource extends CatQuestionSource {
  const RemoteBankSource(this._client);

  final ApiClient _client;

  @override
  String get name => 'Question bank';

  @override
  Future<CatQuestion?> questionFor(String date) async {
    final url = ApiSources.catQuestionBank;
    if (url == null) return null;

    final result = await _client.getJson<List<dynamic>>(
      url,
      parse: (json) => (json as Map<String, dynamic>)['questions'] as List<dynamic>,
    );

    if (result case Success<List<dynamic>>(:final data)) {
      if (data.isEmpty) return null;
      final item = dailyPick(date, 'cat-bank', data) as Map<String, dynamic>;

      return CatQuestion(
        id: item['id'] as String? ?? CatQuestion.idFor('${item['stem']}'),
        topic: item['topic'] as String? ?? 'Quantitative Aptitude',
        difficulty: item['difficulty'] as String? ?? 'Medium',
        stem: item['stem'] as String,
        options: (item['options'] as List<dynamic>).cast<String>(),
        answerIndex: item['answerIndex'] as int,
        solution: item['solution'] as String?,
        source: CatSource.remoteBank,
        verification: CatVerification.sourceProvided,
      );
    }

    return null;
  }
}

/// The floor of the chain: parametric CAT-level questions, seeded by the date.
///
/// This tier always succeeds, which is what keeps the card from showing an
/// empty state on most days. Every answer is derived twice offline and, when
/// there is a connection, confirmed a third time against math.js — a question
/// that fails either check is discarded and the next seed is tried.
class GeneratedSource extends CatQuestionSource {
  const GeneratedSource(this._verifier);

  final MathVerifier _verifier;

  @override
  String get name => 'Generated';

  /// How many (template, parameter) draws to try before giving up entirely.
  static const _maxAttempts = 24;

  @override
  Future<CatQuestion?> questionFor(String date) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final rng = Random(dailySeed(date, 'cat-quant') + attempt);
      final template = catTemplates[rng.nextInt(catTemplates.length)];

      final generated = template.generate(rng);
      if (generated == null) continue;

      // Offline gate: the two derivations must agree before we even ask.
      if (!generated.selfConsistent) continue;

      final agrees =
          await _verifier.agrees(generated.verifyExpr, generated.answer);

      // False means math.js actively disagreed — drop the question, it is not
      // going on screen. Null means we could not reach it, in which case the
      // offline cross-check stands on its own.
      if (agrees == false) continue;

      return CatQuestion(
        id: CatQuestion.idFor(generated.stem),
        topic: generated.topic,
        difficulty: generated.difficulty,
        stem: generated.stem,
        options: generated.options,
        answerIndex: generated.answerIndex,
        solution: generated.solution,
        source: CatSource.generated,
        verification: agrees == true
            ? CatVerification.mathJs
            : CatVerification.crossChecked,
      );
    }

    return null;
  }
}

/// Walks the tiers in order and returns the first question that survives.
class CatQuestionChain {
  const CatQuestionChain(this.sources);

  final List<CatQuestionSource> sources;

  Future<CatQuestion?> questionFor(String date) async {
    for (final source in sources) {
      try {
        final question = await source.questionFor(date);
        if (question != null) return question;
      } catch (_) {
        // A broken tier must not stop the chain — that is the whole point of
        // having one.
        continue;
      }
    }
    return null;
  }
}
