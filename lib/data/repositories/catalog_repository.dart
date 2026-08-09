import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

/// How much history points at a game or a format, and therefore what may be
/// done to it.
typedef CatalogUsage = ({int decks, int tournaments, int matches});

/// Why a game or a format could not be deleted.
///
/// These are refusals rather than errors: each one is a state the user can see
/// coming from the screen, which is why the reason travels back instead of an
/// exception. [lastOne] only ever applies to a game — the app has to be left
/// with something to record a tournament under.
enum CatalogDeletionResult { deleted, system, inUse, lastOne }

/// Read and write access to games and formats: the catalogue every other
/// feature hangs off.
///
/// Neither is deleted once it carries history; both are hidden instead, which
/// keeps old tournaments readable.
class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Games, ordered as they are meant to be shown.
  ///
  /// [includeInactive] is for the catalogue screen, which has to show hidden
  /// games in order to let the user bring them back.
  Stream<List<Game>> watchGames({bool includeInactive = false}) {
    final query = _db.select(_db.games)
      ..orderBy([
        (g) => OrderingTerm(expression: g.sortOrder),
        (g) => OrderingTerm(expression: g.name),
      ]);

    if (!includeInactive) {
      query.where((g) => g.isActive.equals(true));
    }

    return query.watch();
  }

  /// Formats of [gameId], ordered as they are meant to be shown.
  Stream<List<Format>> watchFormats(
    String gameId, {
    bool includeInactive = false,
  }) {
    final query = _db.select(_db.formats)
      ..where((f) => f.gameId.equals(gameId))
      ..orderBy([
        (f) => OrderingTerm(expression: f.sortOrder),
        (f) => OrderingTerm(expression: f.name),
      ]);

    if (!includeInactive) {
      query.where((f) => f.isActive.equals(true));
    }

    return query.watch();
  }

  /// Adds a game, placed after the ones already there.
  ///
  /// It arrives with no formats: a game nobody has told the app anything about
  /// has no formats to guess at, and the catalogue screen is where they get
  /// added, one row below.
  Future<Game> addGame({required String name}) async {
    final lastOrder =
        await (_db.selectOnly(_db.games)
              ..addColumns([_db.games.sortOrder.max()]))
            .map((row) => row.read(_db.games.sortOrder.max()))
            .getSingleOrNull();

    return _db
        .into(_db.games)
        .insertReturning(
          GamesCompanion.insert(
            id: _uuid.v4(),
            name: name.trim(),
            sortOrder: Value((lastOrder ?? -1) + 1),
          ),
        );
  }

  Future<void> renameGame(String gameId, String name) {
    return (_db.update(_db.games)..where((g) => g.id.equals(gameId))).write(
      GamesCompanion(name: Value(name.trim())),
    );
  }

  /// Hides or shows a game, refusing to hide the last visible one.
  ///
  /// With no game left, the deck and tournament editors would have nothing to
  /// offer and no way back: the screen that could undo it is reached through
  /// the same catalogue.
  Future<CatalogDeletionResult> setGameActive(
    String gameId, {
    required bool isActive,
  }) async {
    if (!isActive && await _isLastActiveGame(gameId)) {
      return CatalogDeletionResult.lastOne;
    }

    await (_db.update(_db.games)..where((g) => g.id.equals(gameId))).write(
      GamesCompanion(isActive: Value(isActive)),
    );

    return CatalogDeletionResult.deleted;
  }

  /// Removes a user-created game that nothing points at.
  ///
  /// Its formats and their archetypes go with it, in the same transaction:
  /// both are lists of names belonging to a game that will not exist, and
  /// leaving them behind would only make them unreachable.
  Future<CatalogDeletionResult> deleteGame(String gameId) async {
    final game = await (_db.select(
      _db.games,
    )..where((g) => g.id.equals(gameId))).getSingleOrNull();

    if (game == null) return CatalogDeletionResult.deleted;
    if (game.isSystem) return CatalogDeletionResult.system;
    if (game.isActive && await _isLastActiveGame(gameId)) {
      return CatalogDeletionResult.lastOne;
    }

    final usage = await gameUsage(gameId);
    if (usage.decks + usage.tournaments + usage.matches > 0) {
      return CatalogDeletionResult.inUse;
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.opponentArchetypes,
      )..where((a) => a.gameId.equals(gameId))).go();
      await (_db.delete(
        _db.formats,
      )..where((f) => f.gameId.equals(gameId))).go();
      await (_db.delete(_db.games)..where((g) => g.id.equals(gameId))).go();
    });

    return CatalogDeletionResult.deleted;
  }

  Future<bool> _isLastActiveGame(String gameId) async {
    final others =
        await (_db.select(_db.games)
              ..where(
                (g) => g.isActive.equals(true) & g.id.equals(gameId).not(),
              )
              ..limit(1))
            .get();

    return others.isEmpty;
  }

  /// Adds a user-defined format, placed after the ones already there.
  Future<Format> addFormat({
    required String gameId,
    required String name,
  }) async {
    final lastOrder =
        await (_db.selectOnly(_db.formats)
              ..addColumns([_db.formats.sortOrder.max()])
              ..where(_db.formats.gameId.equals(gameId)))
            .map((row) => row.read(_db.formats.sortOrder.max()))
            .getSingleOrNull();

    return _db
        .into(_db.formats)
        .insertReturning(
          FormatsCompanion.insert(
            id: _uuid.v4(),
            gameId: gameId,
            name: name.trim(),
            sortOrder: Value((lastOrder ?? -1) + 1),
          ),
        );
  }

  Future<void> renameFormat(String formatId, String name) {
    return (_db.update(_db.formats)..where((f) => f.id.equals(formatId))).write(
      FormatsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> setFormatActive(String formatId, {required bool isActive}) {
    return (_db.update(_db.formats)..where((f) => f.id.equals(formatId))).write(
      FormatsCompanion(isActive: Value(isActive)),
    );
  }

  /// Removes a user-created format that nothing points at.
  ///
  /// Two refusals, and neither is a technicality. A system format is part of
  /// the app: the most it can be is hidden, because the archetype list shipped
  /// for it would otherwise be orphaned. A format with a deck or a tournament
  /// in it carries history, and the answer there is to hide it — a match that
  /// was played in a format the database no longer knows about is a match that
  /// can no longer be read.
  ///
  /// The archetypes of the format go with it, in the same transaction. They
  /// are a list of names, and a name nobody ever recorded a match against
  /// loses nothing by being removed with the format it belonged to.
  Future<CatalogDeletionResult> deleteFormat(String formatId) async {
    final format = await (_db.select(
      _db.formats,
    )..where((f) => f.id.equals(formatId))).getSingleOrNull();

    if (format == null) return CatalogDeletionResult.deleted;
    if (format.isSystem) return CatalogDeletionResult.system;

    final usage = await formatUsage(formatId);
    if (usage.decks + usage.tournaments + usage.matches > 0) {
      return CatalogDeletionResult.inUse;
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.opponentArchetypes,
      )..where((a) => a.formatId.equals(formatId))).go();
      await (_db.delete(_db.formats)..where((f) => f.id.equals(formatId))).go();
    });

    return CatalogDeletionResult.deleted;
  }

  /// How many decks, tournaments and matches point at [formatId].
  ///
  /// Opponent archetypes are deliberately not counted. They are a list of
  /// names, not history: deleting a format takes its archetypes with it, so
  /// having some is no reason to refuse.
  Future<CatalogUsage> formatUsage(String formatId) =>
      _usageQuery('format_id', formatId).getSingle().then(_readUsage);

  /// The same counts, kept current: the catalogue screen shows them beside a
  /// delete action whose answer they decide.
  Stream<CatalogUsage> watchFormatUsage(String formatId) =>
      _usageQuery('format_id', formatId).watchSingle().map(_readUsage);

  /// The same, for a game. Its formats are not counted, for the same reason
  /// archetypes are not counted against a format.
  Future<CatalogUsage> gameUsage(String gameId) =>
      _usageQuery('game_id', gameId).getSingle().then(_readUsage);

  Stream<CatalogUsage> watchGameUsage(String gameId) =>
      _usageQuery('game_id', gameId).watchSingle().map(_readUsage);

  /// [column] is a literal, never user input: the two call sites above pass a
  /// column name of this file's own choosing, and the value is bound.
  Selectable<QueryRow> _usageQuery(String column, String id) {
    return _db.customSelect(
      'SELECT'
      ' (SELECT COUNT(*) FROM decks WHERE $column = ?1) AS decks,'
      ' (SELECT COUNT(*) FROM tournaments WHERE $column = ?1) AS tournaments,'
      ' (SELECT COUNT(*) FROM matches WHERE $column = ?1) AS matches',
      variables: [Variable<String>(id)],
      readsFrom: {_db.decks, _db.tournaments, _db.matches},
    );
  }

  static CatalogUsage _readUsage(QueryRow row) => (
    decks: row.read<int>('decks'),
    tournaments: row.read<int>('tournaments'),
    matches: row.read<int>('matches'),
  );
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(appDatabaseProvider));
});

/// The games the user can currently choose. Feeds every picker and filter.
final gamesProvider = StreamProvider<List<Game>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchGames();
});

/// Every game, hidden ones included. For reading a name back, never for
/// offering a choice.
final allGamesProvider = StreamProvider<List<Game>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchGames(includeInactive: true);
});

/// The formats of a game that the user can currently choose.
///
/// Hidden formats are left out, which is the whole point of hiding one: this
/// provider feeds the pickers and the filter chips.
final formatsProvider = StreamProvider.family<List<Format>, String>((
  ref,
  gameId,
) {
  return ref.watch(catalogRepositoryProvider).watchFormats(gameId);
});

/// Every format of a game, hidden ones included.
///
/// For reading a name back, never for offering a choice. A deck filed under a
/// format the user later hid still has to say which format that was: hiding a
/// format takes it out of the menus, it does not erase it from the rows that
/// already point at it.
final allFormatsProvider = StreamProvider.family<List<Format>, String>((
  ref,
  gameId,
) {
  return ref
      .watch(catalogRepositoryProvider)
      .watchFormats(gameId, includeInactive: true);
});

/// A game, plus the format a record already points at. See
/// [editableFormatsProvider].
typedef FormatChoiceScope = ({String gameId, String? keepId});

/// The formats an editor may offer: the ones still in the menus, plus the one
/// the record being edited is already in.
///
/// Without that second part, opening a deck whose format was hidden after it
/// was created would find no matching entry, quietly fall back to the first
/// format in the list, and save the deck into a format nobody chose.
final editableFormatsProvider =
    Provider.family<List<Format>, FormatChoiceScope>((ref, scope) {
      final all =
          ref.watch(allFormatsProvider(scope.gameId)).valueOrNull ??
          const <Format>[];

      return [
        for (final format in all)
          if (format.isActive || format.id == scope.keepId) format,
      ];
    });

// There is deliberately no `editableGamesProvider` beside
// [editableFormatsProvider]. A record's game is fixed at creation and both
// editors hide the game selector once there is something to edit, so the case
// that provider would exist for — a hidden game having to stay selectable —
// cannot arise.

/// How much history points at a format.
final formatUsageProvider = StreamProvider.family<CatalogUsage, String>((
  ref,
  formatId,
) {
  return ref.watch(catalogRepositoryProvider).watchFormatUsage(formatId);
});

/// How much history points at a game.
final gameUsageProvider = StreamProvider.family<CatalogUsage, String>((
  ref,
  gameId,
) {
  return ref.watch(catalogRepositoryProvider).watchGameUsage(gameId);
});
