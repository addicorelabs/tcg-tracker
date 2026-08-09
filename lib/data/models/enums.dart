/// Part of a decklist a card belongs to.
///
/// Covers both games: Yu-Gi-Oh! has an extra deck, Magic has a sideboard, and
/// commander decks name a single card as the commander.
enum DeckSection { main, side, extra, commander }

/// Kind of event a tournament was.
///
/// Stored by name, never by index, so reordering this enum cannot silently
/// rewrite existing rows.
///
/// The list covers both games, because one column stores both. Which of these
/// a given game actually offers lives in `core/tournaments/event_options.dart`:
/// a Yu-Gi-Oh! event is never a PTQ, and a Magic one is never an OTS.
enum EventType {
  local,
  online,
  ots,
  storeChampionship,
  showdown,
  regional,
  ptq,
  national,
  continental,
  worlds,
}

/// Where a tournament is in its lifecycle.
enum TournamentStatus { planned, ongoing, finished }

/// Outcome of a match.
///
/// [bye] is excluded from every winrate calculation and shows up separately in
/// the tournament record. It does score 3 tournament points like a win, which
/// is the single exception. See `docs/architettura.md`, section 7.
enum MatchResult { win, loss, draw, bye }

extension MatchResultRules on MatchResult {
  /// Whether this match has an opponent and therefore counts towards statistics.
  bool get countsTowardsWinrate => this != MatchResult.bye;
}
