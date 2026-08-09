import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/decklist/decklist_parser.dart';
import 'package:tcg_tracker/data/backup/backup_service.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
import 'package:tcg_tracker/data/repositories/archetype_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase source;
  late BackupService service;

  setUp(() {
    source = createTestDatabase();
    service = BackupService(source);
  });

  tearDown(() => source.close());

  /// Fills the database with one of everything, so a round trip exercises every
  /// table and both enum columns.
  Future<Deck> populate() async {
    final deck = await DeckRepository(source).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Izzet Prowess',
      archetype: 'Izzet Prowess',
      colors: 'UR',
      notes: 'Sideboard needs another Blood Moon',
    );

    await DeckRepository(source).setPhoto(
      deck.id,
      image: Uint8List.fromList([0, 1, 2, 250, 255]),
      mimeType: 'image/jpeg',
    );
    await DeckRepository(source).replaceCards(deck.id, const [
      ParsedCard(
        section: DeckSection.main,
        name: 'Lightning Bolt',
        quantity: 4,
      ),
      ParsedCard(section: DeckSection.side, name: 'Blood Moon', quantity: 3),
    ]);

    final archetype = await ArchetypeRepository(
      source,
    ).add(gameId: Seed.magicId, formatId: 'mtg-modern', name: 'Boros Energy');

    await insertHistoryFor(
      source,
      deckId: deck.id,
      opponentArchetypeId: archetype.id,
    );

    return deck;
  }

  test('a round trip restores every table', () async {
    final deck = await populate();
    final exported = await service.exportToString();

    final target = createTestDatabase();
    addTearDown(target.close);
    await BackupService(target).importFromString(exported);

    final restoredDeck = await (target.select(
      target.decks,
    )..where((d) => d.id.equals(deck.id))).getSingle();

    expect(restoredDeck.name, 'Izzet Prowess');
    expect(restoredDeck.colors, 'UR');
    expect(restoredDeck.notes, 'Sideboard needs another Blood Moon');
    expect(
      restoredDeck.photo,
      Uint8List.fromList([0, 1, 2, 250, 255]),
      reason: 'deck photos travel in the backup as base64',
    );
    expect(await target.select(target.deckCards).get(), hasLength(2));
    expect(await target.select(target.games).get(), hasLength(2));
    expect(await target.select(target.formats).get(), hasLength(6));
    expect(
      await target.select(target.opponentArchetypes).get(),
      // The shipped archetype list travels in the backup too, so the count is
      // the source's, not one.
      hasLength((await source.select(source.opponentArchetypes).get()).length),
    );
    expect(await target.select(target.tournaments).get(), hasLength(1));
    expect(await target.select(target.matches).get(), hasLength(1));
  });

  test('enums and dates survive the round trip', () async {
    await populate();
    final exported = await service.exportToString();

    final target = createTestDatabase();
    addTearDown(target.close);
    await BackupService(target).importFromString(exported);

    final tournament = await target.select(target.tournaments).getSingle();
    final match = await target.select(target.matches).getSingle();
    final original = await source.select(target.matches).getSingle();

    expect(tournament.eventType, EventType.local);
    expect(tournament.status, TournamentStatus.finished);
    expect(match.result, MatchResult.win);
    expect(match.onThePlay, isTrue);
    expect(
      match.playedAt.toIso8601String(),
      original.playedAt.toIso8601String(),
    );
  });

  test('a restore replaces what was already there', () async {
    final empty = await service.exportToString();
    await populate();

    await service.importFromString(empty);

    expect(await source.select(source.decks).get(), isEmpty);
    expect(await source.select(source.matches).get(), isEmpty);
    expect(
      await source.select(source.formats).get(),
      hasLength(6),
      reason: 'the seeded catalogue is part of the backup, not lost by it',
    );
  });

  test('a failed restore leaves the database untouched', () async {
    await populate();

    // Rows that reference a deck the backup never contained: the insert fails
    // on the foreign key, and the transaction must roll everything back.
    const corrupt = '''
{
  "app": "tcg-tracker",
  "formatVersion": 1,
  "tables": {
    "games": [],
    "formats": [],
    "decks": [],
    "opponent_archetypes": [],
    "tournaments": [],
    "matches": [
      {
        "id": "orphan",
        "game_id": "mtg",
        "format_id": "mtg-modern",
        "deck_id": "missing",
        "is_top_cut": false,
        "games_won": 0,
        "games_lost": 0,
        "games_drawn": 0,
        "result": "win",
        "played_at": "2026-01-01T00:00:00.000"
      }
    ]
  }
}
''';

    await expectLater(
      service.importFromString(corrupt),
      throwsA(isA<Exception>()),
    );
    expect(await source.select(source.decks).get(), hasLength(1));
  });

  group('rejects files it cannot read', () {
    test('not JSON at all', () {
      expect(
        () => service.importFromString('not json'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('exported by something else', () {
      expect(
        () => service.importFromString('{"app": "other", "formatVersion": 1}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('written by a newer version of the app', () {
      expect(
        () => service.importFromString(
          '{"app": "tcg-tracker", "formatVersion": 99, "tables": {}}',
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  test('the suggested file name carries the date', () {
    expect(
      service.suggestedFileName(DateTime(2026, 8, 8)),
      'tcg-tracker-2026-08-08.json',
    );
  });
}
