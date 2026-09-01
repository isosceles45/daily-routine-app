import '../../../core/utils/daily_seed.dart';
import '../../animals/domain/daily_fun.dart';
import '../../places/domain/place_entry.dart';
import '../../pokemon/domain/daily_pokemon.dart';

/// A small thing to actually do today (§4).
class DailyChallenge {
  const DailyChallenge({required this.text, required this.origin});

  final String text;

  /// Which of the day's sections the challenge was built from, so the UI can
  /// hint at where to go. Null for the content-independent ones.
  final String? origin;

  Map<String, dynamic> toJson() => {'text': text, 'origin': origin};

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
    text: json['text'] as String,
    origin: json['origin'] as String?,
  );
}

/// Builds the day's challenge out of the day's own content.
///
/// Deriving from what is already on screen keeps the app feeling joined up —
/// the challenge points at today's Pokémon or today's place rather than
/// arriving from nowhere. Only when nothing has loaded does it fall back to
/// the handful of content-independent prompts.
abstract final class ChallengeGenerator {
  static DailyChallenge build({
    required String date,
    PlaceEntry? place,
    DailyPokemon? pokemon,
    DailyFun? fun,
  }) {
    final candidates = <DailyChallenge>[
      if (place != null) ...[
        DailyChallenge(
          text: 'Find ${place.title} on a map, and see what is nearby.',
          origin: 'Places',
        ),
        DailyChallenge(
          text: 'Learn how to say the name "${place.title}" out loud.',
          origin: 'Places',
        ),
        DailyChallenge(
          text:
              'Read one more paragraph about ${place.title} than the app '
              'shows you.',
          origin: 'Places',
        ),
        DailyChallenge(
          text:
              'Work out roughly how far ${place.region} is from where you '
              'are standing.',
          origin: 'Places',
        ),
      ],
      if (pokemon != null) ...[
        DailyChallenge(
          text: 'Find out what ${pokemon.displayName} evolves into — or from.',
          origin: 'Pokémon',
        ),
        DailyChallenge(
          text: 'Work out one type that beats ${pokemon.types.first}.',
          origin: 'Pokémon',
        ),
      ],
      if (fun?.text != null)
        DailyChallenge(
          text:
              "Send today's ${fun!.kind.label.toLowerCase()} to someone who "
              'would enjoy it.',
          origin: 'Explore',
        ),
      // Always available, so there is never a day without a challenge.
      const DailyChallenge(
        text: 'Write down one thing that went better than expected today.',
        origin: null,
      ),
      const DailyChallenge(
        text: 'Step outside for ten minutes without your phone.',
        origin: null,
      ),
      const DailyChallenge(
        text: 'Learn one word in a language you do not speak.',
        origin: null,
      ),
    ];

    return dailyPick(date, 'challenge', candidates);
  }
}
