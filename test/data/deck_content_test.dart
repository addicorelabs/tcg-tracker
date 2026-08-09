import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/decklist/decklist_parser.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
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

  final photo = Uint8List.fromList([1, 2, 3, 4, 5]);

  Future<Deck> createDeck() => repository.createDeck(
    gameId: Seed.magicId,
    formatId: 'mtg-modern',
    name: 'Izzet Prowess',
    archetype: 'Izzet Prowess',
  );

  const list = [
    ParsedCard(section: DeckSection.main, name: 'Lightning Bolt', quantity: 4),
    ParsedCard(section: DeckSection.main, name: 'Mountain', quantity: 16),
    ParsedCard(section: DeckSection.side, name: 'Blood Moon', quantity: 3),
  ];

  group('photo', () {
    test('is stored and read back byte for byte', () async {
      final deck = await createDeck();

      await repository.setPhoto(deck.id, image: photo, mimeType: 'image/jpeg');

      final stored = await repository.watchDeck(deck.id).first;
      expect(stored!.photo, photo);
      expect(stored.photoMimeType, 'image/jpeg');
    });

    test('is cleared by passing nothing', () async {
      final deck = await createDeck();
      await repository.setPhoto(deck.id, image: photo, mimeType: 'image/jpeg');

      await repository.setPhoto(deck.id);

      final stored = await repository.watchDeck(deck.id).first;
      expect(stored!.photo, isNull);
      expect(stored.photoMimeType, isNull);
    });
  });

  group('decklist', () {
    test('is stored with its sections and source order', () async {
      final deck = await createDeck();

      await repository.replaceCards(deck.id, list);

      final cards = await repository.watchCards(deck.id).first;
      expect(cards.map((c) => c.name), [
        'Lightning Bolt',
        'Mountain',
        'Blood Moon',
      ]);
      expect(cards.first.quantity, 4);
      expect(cards.last.section, DeckSection.side);
    });

    test('importing again replaces rather than merges', () async {
      final deck = await createDeck();
      await repository.replaceCards(deck.id, list);

      await repository.replaceCards(deck.id, [
        const ParsedCard(
          section: DeckSection.main,
          name: 'Ragavan, Nimble Pilferer',
          quantity: 4,
        ),
      ]);

      final cards = await repository.watchCards(deck.id).first;
      expect(cards.map((c) => c.name), ['Ragavan, Nimble Pilferer']);
    });

    test('is scoped to its own deck', () async {
      final first = await createDeck();
      final second = await repository.createDeck(
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        name: 'Burn',
        archetype: 'Burn',
      );
      await repository.replaceCards(first.id, list);

      expect(await repository.watchCards(second.id).first, isEmpty);
    });

    test('goes away with the deck', () async {
      final deck = await createDeck();
      await repository.replaceCards(deck.id, list);

      await repository.deleteDeck(deck.id);

      expect(await db.select(db.deckCards).get(), isEmpty);
    });
  });

  test('duplicating carries the photo and the list across', () async {
    final deck = await createDeck();
    await repository.setPhoto(deck.id, image: photo, mimeType: 'image/jpeg');
    await repository.replaceCards(deck.id, list);

    final copy = await repository.duplicateDeck(deck.id, newName: 'Copy');

    expect(copy.photo, photo);
    expect(await repository.watchCards(copy.id).first, hasLength(3));
    expect(
      await repository.watchCards(deck.id).first,
      hasLength(3),
      reason: 'the original keeps its own list',
    );
  });
}
