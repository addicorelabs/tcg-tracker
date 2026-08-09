import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/decklist/decklist_parser.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// Why a deck could not be deleted.
enum DeckDeletionResult {
  deleted,

  /// The deck is referenced by a tournament or a match. Deleting it would make
  /// that history unreadable, so it can only be archived.
  inUse,
}

/// Read and write access to the user's deck library.
class DeckRepository {
  DeckRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Decks matching the given scope, most recently updated first.
  ///
  /// Archived decks are hidden unless asked for: they stay in the database so
  /// old tournaments keep naming the deck that was actually played.
  Stream<List<Deck>> watchDecks({
    String? gameId,
    String? formatId,
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.decks)
      ..orderBy([
        (d) => OrderingTerm(expression: d.updatedAt, mode: OrderingMode.desc),
      ]);

    if (gameId != null) query.where((d) => d.gameId.equals(gameId));
    if (formatId != null) query.where((d) => d.formatId.equals(formatId));
    if (!includeArchived) query.where((d) => d.isActive.equals(true));

    return query.watch();
  }

  Stream<Deck?> watchDeck(String id) {
    return (_db.select(
      _db.decks,
    )..where((d) => d.id.equals(id))).watchSingleOrNull();
  }

  /// Archetype names already used in this scope, for autocomplete.
  Stream<List<String>> watchArchetypes(String gameId, String formatId) {
    final query = _db.selectOnly(_db.decks, distinct: true)
      ..addColumns([_db.decks.archetype])
      ..where(
        _db.decks.gameId.equals(gameId) & _db.decks.formatId.equals(formatId),
      )
      ..orderBy([OrderingTerm(expression: _db.decks.archetype)]);

    return query.map((row) => row.read(_db.decks.archetype)!).watch();
  }

  Future<Deck> createDeck({
    required String gameId,
    required String formatId,
    required String name,
    required String archetype,
    String? colors,
    String? notes,
    Uint8List? photo,
    String? photoMimeType,
  }) {
    final now = DateTime.now();

    return _db
        .into(_db.decks)
        .insertReturning(
          DecksCompanion.insert(
            id: _uuid.v4(),
            gameId: gameId,
            formatId: formatId,
            name: name.trim(),
            archetype: archetype.trim(),
            colors: Value(colors),
            notes: Value(notes),
            photo: Value(photo),
            photoMimeType: Value(photoMimeType),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// [formatId] is part of the update because the editor lets it be changed:
  /// leaving it out made the picker look like it worked while the deck stayed
  /// in its old format.
  Future<void> updateDeck({
    required String id,
    required String formatId,
    required String name,
    required String archetype,
    String? colors,
    String? notes,
  }) {
    return (_db.update(_db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        formatId: Value(formatId),
        name: Value(name.trim()),
        archetype: Value(archetype.trim()),
        colors: Value(colors),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setArchived(String id, {required bool isArchived}) {
    return (_db.update(_db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        isActive: Value(!isArchived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Replaces the deck's photo, or clears it when [image] is null.
  Future<void> setPhoto(String id, {Uint8List? image, String? mimeType}) {
    return (_db.update(_db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        photo: Value(image),
        photoMimeType: Value(mimeType),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<DeckCard>> watchCards(String deckId) {
    return (_db.select(_db.deckCards)
          ..where((c) => c.deckId.equals(deckId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.section),
            (c) => OrderingTerm(expression: c.sortOrder),
          ]))
        .watch();
  }

  /// Swaps in a freshly imported decklist.
  ///
  /// An import replaces rather than merges: re-importing an edited list should
  /// leave exactly what the file says, not the union with what was there.
  Future<void> replaceCards(String deckId, List<ParsedCard> cards) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.deckCards,
      )..where((c) => c.deckId.equals(deckId))).go();

      await _db.batch((batch) {
        batch.insertAll(_db.deckCards, [
          for (final (index, card) in cards.indexed)
            DeckCardsCompanion.insert(
              id: _uuid.v4(),
              deckId: deckId,
              section: card.section,
              name: card.name,
              quantity: Value(card.quantity),
              sortOrder: Value(index),
            ),
        ]);
      });
    });
  }

  /// Copies a deck, so a new build of the same archetype starts from the old one.
  ///
  /// The photo and the decklist come along: a duplicate is meant to be the
  /// starting point for the next build, not an empty shell.
  Future<Deck> duplicateDeck(String id, {required String newName}) async {
    final source = await (_db.select(
      _db.decks,
    )..where((d) => d.id.equals(id))).getSingle();

    final copy = await createDeck(
      gameId: source.gameId,
      formatId: source.formatId,
      name: newName,
      archetype: source.archetype,
      colors: source.colors,
      notes: source.notes,
      photo: source.photo,
      photoMimeType: source.photoMimeType,
    );

    final cards = await watchCards(id).first;
    await replaceCards(copy.id, [
      for (final card in cards)
        ParsedCard(
          section: card.section,
          name: card.name,
          quantity: card.quantity,
        ),
    ]);

    return copy;
  }

  /// Whether any tournament or match still points at this deck.
  Future<bool> isDeckInUse(String id) async {
    final tournaments =
        await (_db.selectOnly(_db.tournaments)
              ..addColumns([_db.tournaments.id])
              ..where(_db.tournaments.deckId.equals(id))
              ..limit(1))
            .get();
    if (tournaments.isNotEmpty) return true;

    final matches =
        await (_db.selectOnly(_db.matches)
              ..addColumns([_db.matches.id])
              ..where(_db.matches.deckId.equals(id))
              ..limit(1))
            .get();
    return matches.isNotEmpty;
  }

  /// Deletes a deck, refusing when history depends on it.
  Future<DeckDeletionResult> deleteDeck(String id) async {
    if (await isDeckInUse(id)) return DeckDeletionResult.inUse;

    await (_db.delete(_db.decks)..where((d) => d.id.equals(id))).go();
    return DeckDeletionResult.deleted;
  }
}

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository(ref.watch(appDatabaseProvider));
});

/// Archetype names used by the user's own decks in one game and format.
final deckArchetypesProvider =
    StreamProvider.family<List<String>, ({String gameId, String formatId})>((
      ref,
      scope,
    ) {
      return ref
          .watch(deckRepositoryProvider)
          .watchArchetypes(scope.gameId, scope.formatId);
    });
