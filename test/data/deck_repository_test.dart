import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late DeckRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = DeckRepository(db);
  });

  tearDown(() => db.close());

  Future<Deck> createModernDeck({String name = 'Izzet Prowess'}) {
    return repository.createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: name,
      archetype: 'Izzet Prowess',
      colors: 'UR',
    );
  }

  test('decks are scoped by game and format', () async {
    await createModernDeck();
    await repository.createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-edison',
      name: 'Frog Monarch',
      archetype: 'Monarch',
    );

    final magic = await repository.watchDecks(gameId: Seed.magicId).first;
    final edison = await repository
        .watchDecks(gameId: Seed.yugiohId, formatId: 'ygo-edison')
        .first;
    final legacy = await repository
        .watchDecks(gameId: Seed.magicId, formatId: 'mtg-legacy')
        .first;

    expect(magic.single.name, 'Izzet Prowess');
    expect(edison.single.name, 'Frog Monarch');
    expect(legacy, isEmpty);
  });

  test('names and archetypes are trimmed on the way in', () async {
    final deck = await repository.createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: '  Boros Energy  ',
      archetype: ' Boros Energy ',
    );

    expect(deck.name, 'Boros Energy');
    expect(deck.archetype, 'Boros Energy');
  });

  test('updating moves the deck to its new format', () async {
    final deck = await createModernDeck();

    await repository.updateDeck(
      id: deck.id,
      formatId: 'mtg-legacy',
      name: 'Izzet Delver',
      archetype: 'Izzet Delver',
    );

    expect(
      await repository
          .watchDecks(gameId: Seed.magicId, formatId: 'mtg-modern')
          .first,
      isEmpty,
    );
    expect(
      (await repository
              .watchDecks(gameId: Seed.magicId, formatId: 'mtg-legacy')
              .first)
          .single
          .name,
      'Izzet Delver',
    );
  });

  test('archived decks are hidden unless asked for', () async {
    final deck = await createModernDeck();
    await repository.setArchived(deck.id, isArchived: true);

    expect(await repository.watchDecks(gameId: Seed.magicId).first, isEmpty);
    expect(
      await repository
          .watchDecks(gameId: Seed.magicId, includeArchived: true)
          .first,
      hasLength(1),
    );
  });

  test('duplicating copies the build but takes a new name and id', () async {
    final deck = await createModernDeck();

    final copy = await repository.duplicateDeck(
      deck.id,
      newName: 'Izzet Prowess (copy)',
    );

    expect(copy.id, isNot(deck.id));
    expect(copy.name, 'Izzet Prowess (copy)');
    expect(copy.archetype, deck.archetype);
    expect(copy.colors, 'UR');
  });

  test('a deck with no history can be deleted', () async {
    final deck = await createModernDeck();

    expect(await repository.deleteDeck(deck.id), DeckDeletionResult.deleted);
    expect(await repository.watchDecks().first, isEmpty);
  });

  test('a deck used by a tournament can only be archived', () async {
    final deck = await createModernDeck();
    await insertHistoryFor(db, deckId: deck.id);

    expect(await repository.isDeckInUse(deck.id), isTrue);
    expect(await repository.deleteDeck(deck.id), DeckDeletionResult.inUse);
    expect(
      await repository.watchDecks(includeArchived: true).first,
      hasLength(1),
      reason: 'the deck must survive a refused delete',
    );
  });

  test('archetype suggestions are unique and scoped to the format', () async {
    await createModernDeck();
    await createModernDeck(name: 'Izzet Prowess v2');
    await repository.createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-legacy',
      name: 'Delver',
      archetype: 'Izzet Delver',
    );

    final modern = await repository
        .watchArchetypes(Seed.magicId, 'mtg-modern')
        .first;

    expect(modern, ['Izzet Prowess']);
  });
}
