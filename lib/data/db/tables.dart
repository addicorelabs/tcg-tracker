import 'package:drift/drift.dart';

import '../models/enums.dart';

/// Identifiers are text everywhere: the seeded rows use readable slugs and
/// everything the user creates gets a uuid, which keeps them unique across
/// devices, which is what lets one device's snapshot restore onto another.

/// Supported card games.
///
/// Yu-Gi-Oh! and Magic ship with the app and carry rules written against their
/// ids — starting life totals, tournament circuits, accent colour. A game the
/// user adds has none of that, and falls back to neutral defaults; see
/// `core/life/life_rules.dart` and `core/tournaments/event_options.dart`.
class Games extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Ships with the app, and therefore cannot be deleted.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Formats belonging to a game.
///
/// System formats ship with the app and cannot be deleted; the user can add
/// their own and hide any of them.
class Formats extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get name => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The user's deck library, scoped to one game and one format.
///
/// [archetype] is the canonical name used by the analytics section, while
/// [name] is whatever the user wants to call this particular build.
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get formatId => text().references(Formats, #id)();
  TextColumn get name => text()();
  TextColumn get archetype => text()();

  /// Magic only, e.g. "UR". Null for Yu-Gi-Oh!.
  TextColumn get colors => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Photo of the physical deck, already downscaled by the picker.
  ///
  /// Stored inline rather than in a separate blob store so it travels with the
  /// backup: a restore that lost every deck photo would be a poor restore.
  BlobColumn get photo => blob().nullable()();
  TextColumn get photoMimeType => text().nullable()();

  /// Decks are archived rather than deleted, so past tournaments stay readable.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One line of an imported decklist.
///
/// The app does not check card names against any database: the list is there to
/// be read back, not validated, so whatever the text file said is kept as is.
class DeckCards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get section => textEnum<DeckSection>()();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// Position within its section, preserving the order of the source file.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Known opponent archetypes for a format.
///
/// A controlled list rather than free text: without it the matchup matrix
/// splinters into dozens of hand-typed spellings of the same deck.
class OpponentArchetypes extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get formatId => text().references(Formats, #id)();
  TextColumn get name => text()();

  /// Denormalised counter that orders the suggestions by how often the
  /// archetype actually shows up at the tables the user plays at.
  IntColumn get timesFaced => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A tournament the user played.
///
/// The win-loss record is deliberately absent: it is always derived from
/// [Matches], so the two can never disagree.
class Tournaments extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get formatId => text().references(Formats, #id)();
  TextColumn get deckId => text().references(Decks, #id)();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get eventType => textEnum<EventType>()();
  IntColumn get participantCount => integer().nullable()();
  IntColumn get roundsPlanned => integer()();
  BoolColumn get hasTopCut => boolean().withDefault(const Constant(false))();
  IntColumn get topCutSize => integer().nullable()();
  IntColumn get finalStanding => integer().nullable()();
  TextColumn get status => textEnum<TournamentStatus>()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One match: either a tournament round or a casual game.
///
/// [gameId], [formatId] and [deckId] repeat what the tournament already knows.
/// That redundancy is the point: it lets every statistic query tournament
/// rounds and casual matches through the same columns, with no conditional
/// joins and no null handling in the analytics layer.
// Named explicitly: drift would otherwise strip the trailing "s" and generate
// a row class called `Matche`.
@DataClassName('Match')
class Matches extends Table {
  TextColumn get id => text()();

  /// Null for a casual match played outside any tournament.
  TextColumn get tournamentId =>
      text().nullable().references(Tournaments, #id)();

  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get formatId => text().references(Formats, #id)();
  TextColumn get deckId => text().references(Decks, #id)();

  /// Null for a casual match.
  IntColumn get roundNumber => integer().nullable()();

  /// Kept even though top cut has no dedicated filter: it is what lets the
  /// tournament detail screen rebuild the bracket.
  BoolColumn get isTopCut => boolean().withDefault(const Constant(false))();

  TextColumn get opponentName => text().nullable()();
  TextColumn get opponentArchetypeId =>
      text().nullable().references(OpponentArchetypes, #id)();

  /// Whether the user went first in game one. Null when not recorded.
  BoolColumn get onThePlay => boolean().nullable()();

  IntColumn get gamesWon => integer().withDefault(const Constant(0))();
  IntColumn get gamesLost => integer().withDefault(const Constant(0))();
  IntColumn get gamesDrawn => integer().withDefault(const Constant(0))();

  /// Derivable from the game counts, but stored so statistics can filter on it
  /// without recomputing, and so a bye can be recorded with no games at all.
  TextColumn get result => textEnum<MatchResult>()();

  DateTimeColumn get playedAt => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
