import '../../../core/network/api_client.dart';
import '../../../core/network/api_sources.dart';
import '../domain/cat_question.dart';

/// Independent confirmation of a generated answer (§8).
///
/// The generator already derives every answer twice offline. This adds a third
/// opinion from a source that shares no code with us at all, which is what
/// makes "never display an unverified mathematical answer" more than a slogan.
class MathVerifier {
  const MathVerifier(this._client);

  final ApiClient _client;

  /// Returns true when math.js agrees with [expected].
  ///
  /// Returns null when the check could not be made — offline, rate-limited, a
  /// malformed response. Null is not a failure: callers fall back to the
  /// offline cross-check rather than dropping the question.
  Future<bool?> agrees(String expression, double expected) async {
    final result = await _client.getText(
      ApiSources.mathJs,
      query: {'expr': expression},
    );

    final body = result.dataOrNull?.trim();
    if (body == null || body.isEmpty) return null;

    // math.js answers errors in prose ("Undefined symbol ..."), which parses
    // as neither a number nor agreement.
    final value = double.tryParse(body);
    if (value == null) return null;

    return Num.agree(expected, value);
  }
}
