import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/account_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/decks/presentation/archetype_decks_screen.dart';
import '../features/decks/presentation/archetypes_screen.dart';
import '../features/decks/presentation/deck_editor_screen.dart';
import '../features/decks/presentation/decks_screen.dart';
import '../features/life/presentation/life_counter_screen.dart';
import '../features/settings/presentation/catalog_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tournaments/presentation/round_editor_screen.dart';
import '../features/tournaments/presentation/tournament_detail_screen.dart';
import '../features/tournaments/presentation/tournament_editor_screen.dart';
import '../features/tournaments/presentation/tournaments_screen.dart';
import 'routes.dart';
import 'shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Nothing is registered on the root navigator on purpose: every screen lives
/// inside a branch of the shell, so the navigation bar is reachable from
/// anywhere, including halfway through creating a tournament.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          _branch(
            AppRoute.home,
            (context, state) => const DashboardScreen(),
            children: [
              // The life counter belongs to no tournament: it is a tool for the
              // table, so it hangs off the dashboard branch.
              _route(
                AppRoute.newMatch,
                (context, state) => const LifeCounterScreen(),
              ),
            ],
          ),
          _branch(
            AppRoute.tournaments,
            (context, state) => const TournamentsScreen(),
            children: [
              // Literal before parameterised, so "new" is never read as an id.
              _route(
                AppRoute.newTournament,
                (context, state) => const TournamentEditorScreen(),
              ),
              GoRoute(
                path: AppRoute.tournamentDetail.subPath!,
                name: AppRoute.tournamentDetail.routeName,
                builder: (context, state) => TournamentDetailScreen(
                  tournamentId: state.pathParameters['id']!,
                ),
                routes: [
                  _route(
                    AppRoute.editTournament,
                    (context, state) => TournamentEditorScreen(
                      tournamentId: state.pathParameters['id'],
                    ),
                  ),
                  _route(
                    AppRoute.newRound,
                    (context, state) => RoundEditorScreen(
                      tournamentId: state.pathParameters['id']!,
                    ),
                  ),
                  _route(
                    AppRoute.editRound,
                    (context, state) => RoundEditorScreen(
                      tournamentId: state.pathParameters['id']!,
                      matchId: state.pathParameters['matchId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(
            AppRoute.analytics,
            (context, state) => const AnalyticsScreen(),
          ),
          _branch(
            AppRoute.decks,
            (context, state) => const DecksScreen(),
            children: [
              // Declared before the parameterised route so "new" and
              // "archetypes" are never read as a deck id.
              _route(
                AppRoute.newDeck,
                // The archetype travels as a query parameter so opening the
                // editor from inside an archetype starts on that archetype.
                (context, state) => DeckEditorScreen(
                  initialArchetype: state.uri.queryParameters['archetype'],
                ),
              ),
              _route(
                AppRoute.archetypeDecks,
                (context, state) => ArchetypeDecksScreen(
                  archetype: state.uri.queryParameters['name'] ?? '',
                ),
              ),
              _route(
                AppRoute.archetypes,
                (context, state) => const ArchetypesScreen(),
              ),
              _route(
                AppRoute.editDeck,
                (context, state) =>
                    DeckEditorScreen(deckId: state.pathParameters['id']),
              ),
            ],
          ),
          _branch(
            AppRoute.settings,
            (context, state) => const SettingsScreen(),
            children: [
              _route(
                AppRoute.account,
                (context, state) => const AccountScreen(),
              ),
              _route(
                AppRoute.catalog,
                (context, state) => const CatalogScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(
  AppRoute route,
  GoRouterWidgetBuilder builder, {
  List<RouteBase> children = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: route.path,
        name: route.routeName,
        builder: builder,
        routes: children,
      ),
    ],
  );
}

GoRoute _route(AppRoute route, GoRouterWidgetBuilder builder) {
  return GoRoute(path: route.subPath!, name: route.routeName, builder: builder);
}
