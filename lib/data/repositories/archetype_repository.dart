import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';
import 'deck_repository.dart';

/// Why an opponent archetype could not be deleted.
enum ArchetypeDeletionResult { deleted, inUse }

/// The controlled list of opponent archetypes, one list per game and format.
///
/// This is what keeps the matchup matrix readable: without it, the same deck
/// gets typed five different ways and shows up as five separate columns.
class ArchetypeRepository {
  ArchetypeRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Ordered by how often the archetype has actually been faced, so the decks
  /// that dominate the local meta are the first ones offered.
  Stream<List<OpponentArchetype>> watchArchetypes(
    String gameId,
    String formatId,
  ) {
    return (_db.select(_db.opponentArchetypes)
          ..where((a) => a.gameId.equals(gameId) & a.formatId.equals(formatId))
          ..orderBy([
            (a) =>
                OrderingTerm(expression: a.timesFaced, mode: OrderingMode.desc),
            (a) => OrderingTerm(expression: a.name),
          ]))
        .watch();
  }

  /// Every archetype of a game, or of one format when [formatId] is given.
  ///
  /// Alphabetical rather than by how often each was faced: this feeds the deck
  /// library, which is a catalogue to look things up in, not a list of
  /// suggestions to pick the likeliest from.
  Stream<List<OpponentArchetype>> watchScope({
    required String gameId,
    String? formatId,
  }) {
    final query = _db.select(_db.opponentArchetypes)
      ..where((a) => a.gameId.equals(gameId))
      ..orderBy([(a) => OrderingTerm(expression: a.name)]);

    if (formatId != null) {
      query.where((a) => a.formatId.equals(formatId));
    }

    return query.watch();
  }

  Future<OpponentArchetype> add({
    required String gameId,
    required String formatId,
    required String name,
  }) {
    return _db
        .into(_db.opponentArchetypes)
        .insertReturning(
          OpponentArchetypesCompanion.insert(
            id: _uuid.v4(),
            gameId: gameId,
            formatId: formatId,
            name: name.trim(),
          ),
        );
  }

  /// Returns the archetype with this name in this scope, creating it if needed.
  ///
  /// Matching ignores case and surrounding spaces, which is what stops
  /// "snake-eye" and "Snake-Eye " from becoming two entries.
  Future<OpponentArchetype> findOrCreate({
    required String gameId,
    required String formatId,
    required String name,
  }) async {
    final trimmed = name.trim();

    // Deliberately not `getSingleOrNull`: nothing in the schema stops two rows
    // sharing a name in one format, and a lookup that throws whenever they do
    // would break the round editor with no way for the user to recover. If
    // there are two, the one actually played against wins.
    final matches =
        await (_db.select(_db.opponentArchetypes)
              ..where(
                (a) =>
                    a.gameId.equals(gameId) &
                    a.formatId.equals(formatId) &
                    a.name.lower().equals(trimmed.toLowerCase()),
              )
              ..orderBy([
                (a) => OrderingTerm(
                  expression: a.timesFaced,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();

    return matches.firstOrNull ??
        await add(gameId: gameId, formatId: formatId, name: trimmed);
  }

  Future<void> rename(String id, String name) {
    return (_db.update(_db.opponentArchetypes)..where((a) => a.id.equals(id)))
        .write(OpponentArchetypesCompanion(name: Value(name.trim())));
  }

  Future<bool> isInUse(String id) async {
    final matches =
        await (_db.selectOnly(_db.matches)
              ..addColumns([_db.matches.id])
              ..where(_db.matches.opponentArchetypeId.equals(id))
              ..limit(1))
            .get();
    return matches.isNotEmpty;
  }

  /// Deletes an archetype, refusing when matches were recorded against it.
  Future<ArchetypeDeletionResult> delete(String id) async {
    if (await isInUse(id)) return ArchetypeDeletionResult.inUse;

    await (_db.delete(
      _db.opponentArchetypes,
    )..where((a) => a.id.equals(id))).go();
    return ArchetypeDeletionResult.deleted;
  }
}

final archetypeRepositoryProvider = Provider<ArchetypeRepository>((ref) {
  return ArchetypeRepository(ref.watch(appDatabaseProvider));
});

/// Archetypes of one game and format, addressed by a `gameId/formatId` pair.
typedef ArchetypeScope = ({String gameId, String formatId});

final archetypesProvider =
    StreamProvider.family<List<OpponentArchetype>, ArchetypeScope>((
      ref,
      scope,
    ) {
      return ref
          .watch(archetypeRepositoryProvider)
          .watchArchetypes(scope.gameId, scope.formatId);
    });

/// Every name offerable as an opponent's deck, in the order they are offered.
///
/// The archetypes already faced come first, most faced first, because the local
/// meta repeats itself. The archetypes of the user's own decks follow: a deck
/// they own is exactly as likely to sit across the table, and the decks section
/// is where those names are curated.
///
/// Matching is case-insensitive, so a deck named "snake-eye" does not appear
/// beside an archetype called "Snake-Eye".
final opponentArchetypeChoicesProvider =
    Provider.family<List<String>, ArchetypeScope>((ref, scope) {
      final faced =
          ref.watch(archetypesProvider(scope)).valueOrNull ??
          const <OpponentArchetype>[];
      final owned =
          ref.watch(deckArchetypesProvider(scope)).valueOrNull ??
          const <String>[];

      final choices = <String>[];
      final seen = <String>{};

      for (final name in [for (final a in faced) a.name, ...owned]) {
        if (seen.add(name.trim().toLowerCase())) choices.add(name.trim());
      }

      return choices;
    });
