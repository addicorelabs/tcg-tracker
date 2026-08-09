import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
import 'package:tcg_tracker/data/repositories/catalog_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('a fresh database is seeded with both games', () async {
    final games = await db.select(db.games).get();

    expect(games.map((g) => g.id), containsAll([Seed.yugiohId, Seed.magicId]));
  });

  test('each game is seeded with its formats', () async {
    final repository = CatalogRepository(db);

    final yugioh = await repository.watchFormats(Seed.yugiohId).first;
    final magic = await repository.watchFormats(Seed.magicId).first;

    expect(yugioh.map((f) => f.name), ['Avanzato', 'Edison']);
    expect(magic.map((f) => f.name), [
      'Standard',
      'Modern',
      'Pauper',
      'Legacy',
    ]);
    expect(
      [...yugioh, ...magic].every((f) => f.isSystem),
      isTrue,
      reason: 'seeded formats must be protected from deletion',
    );
  });

  test('re-applying the seed leaves existing rows untouched', () async {
    final repository = CatalogRepository(db);
    await repository.renameFormat('mtg-modern', 'Modern (renamed)');

    await Seed.apply(db);

    final formats = await repository.watchFormats(Seed.magicId).first;
    expect(
      formats.firstWhere((f) => f.id == 'mtg-modern').name,
      'Modern (renamed)',
    );
    expect(formats, hasLength(4), reason: 'the seed must not duplicate rows');
  });

  // Adding, hiding and deleting formats live in catalog_repository_test.dart,
  // together with the rules about what may be deleted. This file is about the
  // database and what it opens with.

  test(
    'foreign keys reject a match pointing at a deck that does not exist',
    () async {
      await expectLater(
        db
            .into(db.matches)
            .insert(
              MatchesCompanion.insert(
                id: 'm1',
                gameId: Seed.magicId,
                formatId: 'mtg-modern',
                deckId: 'does-not-exist',
                result: MatchResult.win,
                playedAt: DateTime.now(),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    },
  );
}
