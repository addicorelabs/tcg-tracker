/// Every route in the app, declared in one place so paths and names are never
/// written as bare strings at call sites.
///
/// The creation flows are nested inside a navigation branch rather than sitting
/// at the root, so the navigation bar stays on screen everywhere in the app.
enum AppRoute {
  home('/'),
  tournaments('/tournaments'),
  analytics('/analytics'),
  decks('/decks'),
  settings('/settings'),
  account('/settings/account', subPath: 'account'),
  catalog('/settings/catalog', subPath: 'catalog'),
  newTournament('/tournaments/new', subPath: 'new'),
  tournamentDetail('/tournaments/detail', subPath: 'detail/:id'),
  editTournament('/tournaments/detail/edit', subPath: 'edit'),
  newRound('/tournaments/detail/round', subPath: 'round'),
  editRound('/tournaments/detail/round/edit', subPath: 'round/:matchId'),
  newMatch('/match', subPath: 'match'),
  newDeck('/decks/new', subPath: 'new'),
  archetypeDecks('/decks/group', subPath: 'group'),
  editDeck('/decks/edit', subPath: 'edit/:id'),
  archetypes('/decks/archetypes', subPath: 'archetypes');

  const AppRoute(this.path, {this.subPath});

  /// Full location, used when navigating.
  final String path;

  /// Path fragment used when declaring the route under its parent. Null for
  /// top-level destinations, whose [path] is already absolute.
  final String? subPath;

  String get routeName => name;
}
