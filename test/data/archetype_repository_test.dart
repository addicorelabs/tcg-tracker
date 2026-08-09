import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/archetype_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ArchetypeRepository repository;

  setUp(() async {
    db = createTestDatabase();
    repository = ArchetypeRepository(db);

    // These tests are about the rules, not about which archetypes ship in the
    // box, and they read far better against an empty table.
    await clearSeededArchetypes(db);
  });

  tearDown(() => db.close());

  Future<OpponentArchetype> addModern(String name) {
    return repository.add(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: name,
    );
  }

  test('findOrCreate matches ignoring case and surrounding spaces', () async {
    final first = await addModern('Boros Energy');

    final again = await repository.findOrCreate(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: '  boros energy ',
    );

    expect(again.id, first.id);
    expect(
      await repository.watchArchetypes(Seed.magicId, 'mtg-modern').first,
      hasLength(1),
      reason: 'a different spelling must not create a second column',
    );
  });

  test('the same name in another format is a separate entry', () async {
    await addModern('Burn');
    await repository.findOrCreate(
      gameId: Seed.magicId,
      formatId: 'mtg-legacy',
      name: 'Burn',
    );

    expect(
      await repository.watchArchetypes(Seed.magicId, 'mtg-modern').first,
      hasLength(1),
    );
    expect(
      await repository.watchArchetypes(Seed.magicId, 'mtg-legacy').first,
      hasLength(1),
    );
  });

  test('the list is ordered by how often each archetype was faced', () async {
    final rare = await addModern('Amulet Titan');
    final common = await addModern('Boros Energy');

    await (db.update(db.opponentArchetypes)
          ..where((a) => a.id.equals(common.id)))
        .write(const OpponentArchetypesCompanion(timesFaced: Value(12)));
    await (db.update(db.opponentArchetypes)..where((a) => a.id.equals(rare.id)))
        .write(const OpponentArchetypesCompanion(timesFaced: Value(1)));

    final ordered = await repository
        .watchArchetypes(Seed.magicId, 'mtg-modern')
        .first;

    expect(ordered.map((a) => a.name), ['Boros Energy', 'Amulet Titan']);
  });

  test('an archetype with recorded matches cannot be deleted', () async {
    final archetype = await addModern('Boros Energy');
    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Izzet Prowess',
      archetype: 'Izzet Prowess',
    );
    await insertHistoryFor(
      db,
      deckId: deck.id,
      opponentArchetypeId: archetype.id,
    );

    expect(
      await repository.delete(archetype.id),
      ArchetypeDeletionResult.inUse,
    );
  });

  test('an unused archetype is deleted', () async {
    final archetype = await addModern('Amulet Titan');

    expect(
      await repository.delete(archetype.id),
      ArchetypeDeletionResult.deleted,
    );
    expect(
      await repository.watchArchetypes(Seed.magicId, 'mtg-modern').first,
      isEmpty,
    );
  });
}
