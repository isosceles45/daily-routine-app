import 'package:go_router/go_router.dart';

import '../features/animals/presentation/explore_screen.dart';
import '../features/cat_quant/presentation/cat_screen.dart';
import '../features/games/presentation/game_2048_screen.dart';
import '../features/games/presentation/games_screen.dart';
import '../features/games/presentation/quant_rush_screen.dart';
import '../features/games/presentation/sudoku_screen.dart';
import '../features/gym/presentation/gym_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/places/presentation/place_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/pokemon/presentation/pokemon_screen.dart';
import '../features/surprise/presentation/surprise_screen.dart';
import '../features/todos/presentation/todos_screen.dart';
import '../features/trivia/presentation/trivia_screen.dart';
import '../features/wordle/presentation/wordle_screen.dart';

abstract final class Routes {
  static const today = '/today';
  static const explore = '/explore';
  static const play = '/play';
  static const todos = '/todos';

  /// History and settings share one tab.
  static const you = '/you';

  static const trivia = '/trivia';
  static const pokemon = '/pokemon';
  static const wordle = '/wordle';
  static const catQuant = '/cat-quant';
  static const place = '/place';
  static const surprise = '/surprise';
  static const gym = '/gym';

  static const quantRush = '/play/quant-rush';
  static const sudoku = '/play/sudoku';
  static const twenty48 = '/play/2048';

  /// Opens Wordle immediately on arrival.
  static const wordlePlay = '$wordle?play=1';

  /// Rolls a new pack on arrival.
  static const surpriseRoll = '$surprise?roll=1';
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.today,
    routes: [
      // The tabs keep independent navigation stacks and stay alive when you
      // switch between them — the canvas's bottom nav, not a page swap.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.play,
                builder: (context, state) => const GamesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.todos,
                builder: (context, state) => const TodosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.you,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail screens sit outside the shell so they cover the bottom nav,
      // matching the canvas's full-bleed overlay with a back chevron.
      GoRoute(
        path: Routes.trivia,
        builder: (context, state) => const TriviaScreen(),
      ),
      GoRoute(
        path: Routes.pokemon,
        builder: (context, state) => const PokemonScreen(),
      ),
      GoRoute(
        path: Routes.wordle,
        builder: (context, state) =>
            WordleScreen(autoPlay: state.uri.queryParameters['play'] == '1'),
      ),
      GoRoute(
        path: Routes.catQuant,
        builder: (context, state) => const CatScreen(),
      ),
      GoRoute(
        path: Routes.place,
        builder: (context, state) => const PlaceScreen(),
      ),
      GoRoute(
        path: Routes.quantRush,
        builder: (context, state) => const QuantRushScreen(),
      ),
      GoRoute(
        path: Routes.sudoku,
        builder: (context, state) => const SudokuScreen(),
      ),
      GoRoute(
        path: Routes.twenty48,
        builder: (context, state) => const Game2048Screen(),
      ),
      GoRoute(path: Routes.gym, builder: (context, state) => const GymScreen()),
      GoRoute(
        path: Routes.surprise,
        builder: (context, state) =>
            SurpriseScreen(autoRoll: state.uri.queryParameters['roll'] == '1'),
      ),
    ],
  );
}
