import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/catalog_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = CatalogRepository(db);
    addTearDown(db.close);
  });

  test(
    'a new game lands after the ones already there, with no formats',
    () async {
      final game = await repository.addGame(name: 'Pokémon');

      expect(game.isSystem, isFalse);
      expect(game.isActive, isTrue);

      final games = await repository.watchGames().first;
      expect(games.last.name, 'Pokémon');
      expect(
        await repository.watchFormats(game.id).first,
        isEmpty,
        reason:
            'the app knows nothing about this game, so it invents no formats',
      );
    },
  );

  test(
    'the shipped games are marked as system and cannot be deleted',
    () async {
      final games = await repository.watchGames().first;
      expect(games.every((g) => g.isSystem), isTrue);

      expect(
        await repository.deleteGame(Seed.yugiohId),
        CatalogDeletionResult.system,
      );
    },
  );

  test('the last visible game cannot be hidden', () async {
    expect(
      await repository.setGameActive(Seed.yugiohId, isActive: false),
      CatalogDeletionResult.deleted,
    );
    expect(
      await repository.setGameActive(Seed.magicId, isActive: false),
      CatalogDeletionResult.lastOne,
      reason: 'with no game left, nothing could be created and nothing undone',
    );

    final visible = await repository.watchGames().first;
    expect(visible.map((g) => g.id), [Seed.magicId]);
  });

  test('a game with a deck in it cannot be deleted', () async {
    final game = await repository.addGame(name: 'Pokémon');
    final format = await repository.addFormat(
      gameId: game.id,
      name: 'Standard 2026',
    );
    await DeckRepository(db).createDeck(
      gameId: game.id,
      formatId: format.id,
      name: 'Charizard',
      archetype: 'Charizard',
    );

    expect(await repository.deleteGame(game.id), CatalogDeletionResult.inUse);
  });

  test('deleting an unused game takes its formats and archetypes', () async {
    final game = await repository.addGame(name: 'Pokémon');
    final format = await repository.addFormat(
      gameId: game.id,
      name: 'Standard 2026',
    );
    await db
        .into(db.opponentArchetypes)
        .insert(
          OpponentArchetypesCompanion.insert(
            id: 'pkmn-charizard',
            gameId: game.id,
            formatId: format.id,
            name: 'Charizard',
          ),
        );

    expect(await repository.deleteGame(game.id), CatalogDeletionResult.deleted);

    expect(
      await repository.watchGames(includeInactive: true).first,
      hasLength(2),
    );
    expect(
      await (db.select(
        db.formats,
      )..where((f) => f.gameId.equals(game.id))).get(),
      isEmpty,
    );
    expect(
      await (db.select(
        db.opponentArchetypes,
      )..where((a) => a.gameId.equals(game.id))).get(),
      isEmpty,
      reason: 'a name filed under a game that no longer exists is unreachable',
    );
  });

  test('a new format lands after the ones already there', () async {
    final format = await repository.addFormat(
      gameId: Seed.magicId,
      name: 'Commander',
    );

    expect(format.isSystem, isFalse);
    expect(format.isActive, isTrue);
    expect(
      format.sortOrder,
      greaterThan(
        Seed.formats
            .where((f) => f.gameId == Seed.magicId)
            .map((f) => f.sortOrder)
            .reduce((a, b) => a > b ? a : b),
      ),
      reason: 'a format the user adds belongs at the end of their list',
    );

    final formats = await repository.watchFormats(Seed.magicId).first;
    expect(formats.last.name, 'Commander');
  });

  test('hiding a format takes it out of the choices, not out of the '
      'database', () async {
    await repository.setFormatActive('mtg-pauper', isActive: false);

    final offered = await repository.watchFormats(Seed.magicId).first;
    final all = await repository
        .watchFormats(Seed.magicId, includeInactive: true)
        .first;

    expect(offered.map((f) => f.id), isNot(contains('mtg-pauper')));
    expect(
      all.map((f) => f.id),
      contains('mtg-pauper'),
      reason: 'the tournaments played in it still have to be able to name it',
    );
  });

  test('renaming trims the name', () async {
    await repository.renameFormat('mtg-modern', '  Modern Horizons  ');

    final formats = await repository.watchFormats(Seed.magicId).first;
    final renamed = formats.firstWhere((f) => f.id == 'mtg-modern');

    expect(renamed.name, 'Modern Horizons');
  });

  test('a system format cannot be deleted', () async {
    expect(
      await repository.deleteFormat('mtg-modern'),
      CatalogDeletionResult.system,
    );

    final formats = await repository.watchFormats(Seed.magicId).first;
    expect(formats.map((f) => f.id), contains('mtg-modern'));
  });

  test('a format with a deck in it cannot be deleted', () async {
    final format = await repository.addFormat(
      gameId: Seed.magicId,
      name: 'Commander',
    );
    await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: format.id,
      name: 'My Commander deck',
      archetype: 'Atraxa',
    );

    expect(
      await repository.deleteFormat(format.id),
      CatalogDeletionResult.inUse,
      reason: 'deleting it would leave a deck pointing at nothing',
    );
  });

  test('deleting an unused format takes its archetypes with it', () async {
    final format = await repository.addFormat(
      gameId: Seed.magicId,
      name: 'Commander',
    );
    await db
        .into(db.opponentArchetypes)
        .insert(
          OpponentArchetypesCompanion.insert(
            id: 'commander-atraxa',
            gameId: Seed.magicId,
            formatId: format.id,
            name: 'Atraxa',
          ),
        );

    expect(
      await repository.deleteFormat(format.id),
      CatalogDeletionResult.deleted,
    );

    final formats = await repository
        .watchFormats(Seed.magicId, includeInactive: true)
        .first;
    expect(formats.map((f) => f.id), isNot(contains(format.id)));

    final orphans = await (db.select(
      db.opponentArchetypes,
    )..where((a) => a.formatId.equals(format.id))).get();
    expect(
      orphans,
      isEmpty,
      reason: 'an archetype of a format that no longer exists is unreachable',
    );
  });

  test('usage counts what would break if the format went away', () async {
    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Living End',
      archetype: 'Living End',
    );
    await insertHistoryFor(db, deckId: deck.id);

    expect(await repository.formatUsage('mtg-modern'), (
      decks: 1,
      tournaments: 1,
      matches: 1,
    ));
    expect(
      await repository.formatUsage('mtg-legacy'),
      (decks: 0, tournaments: 0, matches: 0),
      reason: 'the shipped archetypes are a list of names, not usage',
    );
  });
}
