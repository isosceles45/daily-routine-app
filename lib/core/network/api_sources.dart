/// The single place any remote URL is allowed to live (IMPLEMENTATION.md §24).
///
/// Every endpoint here was probed live during planning. Swapping a provider
/// should mean editing this file and its service — never hunting through
/// widgets. If you add one, record why and check §25's criteria first:
/// no auth, HTTPS, documented, permissive terms, sane rate limits.
abstract final class ApiSources {
  // --- Trivia -------------------------------------------------------------
  static const openTrivia = 'https://opentdb.com/api.php';
  static const openTriviaToken = 'https://opentdb.com/api_token.php';

  /// Backup when OpenTDB is exhausted or down.
  static const triviaApiBackup = 'https://the-trivia-api.com/v2/questions';

  // --- Pokémon ------------------------------------------------------------
  static const pokeApi = 'https://pokeapi.co/api/v2';

  /// National Dex count through Generation IX. Used for deterministic daily
  /// selection; raise this when a new generation lands.
  static const pokemonSpeciesCount = 1025;

  // --- Animals & fun ------------------------------------------------------
  static const cataas = 'https://cataas.com/cat';
  static const catFacts = 'https://catfact.ninja/fact';
  static const dogImage = 'https://dog.ceo/api/breeds/image/random';
  static const jokeApi = 'https://v2.jokeapi.dev/joke';
  static const uselessFacts =
      'https://uselessfacts.jsph.pl/api/v2/facts/random';

  // --- Japan (Phase 3) ----------------------------------------------------
  static const wikipediaSummary =
      'https://en.wikipedia.org/api/rest_v1/page/summary';

  // --- CAT Quant (Phase 2) ------------------------------------------------
  /// Used to independently verify generated answers before they are shown.
  static const mathJs = 'https://api.mathjs.org/v4/';

  /// Optional remote question bank. Null keeps the provider disabled; the
  /// generated tier covers CAT Quant without it.
  static const String? catQuestionBank = null;

  // --- Wordle (Phase 2) ---------------------------------------------------
  /// Opened externally. The app never scrapes this page (§6).
  static const wordle = 'https://www.nytimes.com/games/wordle/index.html';
}
