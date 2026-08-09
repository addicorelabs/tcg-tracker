import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/archetype_seed.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/archetype_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/data/repositories/match_repository.dart';

import '../helpers/test_database.dart';

void main() {
  group('the shipped list', () {
    test('names no format that does not exist', () {
      final known = {for (final format in Seed.formats) format.id};

      expect(ArchetypeSeed.byFormat.keys, everyElement(isIn(known)));
    });

    test('has no archetype twice in the same format', () {
      for (final entry in ArchetypeSeed.byFormat.entries) {
        final seen = <String>{};
        final repeated = [
          for (final name in entry.value)
            if (!seen.add(name.toLowerCase())) name,
        ];

        expect(
          repeated,
          isEmpty,
          reason:
              'a name typed twice in ${entry.key} would become two columns of '
              'the same deck in the matchup matrix',
        );
      }
    });

    test('gives every archetype in a format its own id', () {
      for (final entry in ArchetypeSeed.byFormat.entries) {
        final ids = {
          for (final name in entry.value) ArchetypeSeed.idFor(entry.key, name),
        };

        expect(
          ids,
          hasLength(entry.value.length),
          reason:
              'two names in ${entry.key} slugify to the same id, so one would '
              'silently replace the other',
        );
      }
    });

    test('carries no leading or trailing spaces', () {
      for (final names in ArchetypeSeed.byFormat.values) {
        for (final name in names) {
          expect(name, name.trim());
        }
      }
    });
  });

  group('seeding', () {
    late AppDatabase db;

    setUp(() {
      db = createTestDatabase();
      addTearDown(db.close);
    });

    Future<List<OpponentArchetype>> stored() =>
        db.select(db.opponentArchetypes).get();

    test('a new database opens with the list already in it', () async {
      final rows = await stored();

      expect(rows, isNotEmpty);
      expect(
        rows.where((row) => row.formatId == 'ygo-advanced').map((r) => r.name),
        contains('Snake-Eye Fire King'),
      );
      expect(
        rows.every((row) => row.timesFaced == 0),
        isTrue,
        reason:
            'a default nobody has played against must not outrank an archetype '
            'that was actually faced',
      );
    });

    test('applying it twice does not double the list', () async {
      final before = await stored();
      await Seed.applyArchetypes(db);

      expect(await stored(), hasLength(before.length));
    });

    test('an archetype the user added is replaced by the list', () async {
      await ArchetypeRepository(db).add(
        gameId: Seed.yugiohId,
        formatId: 'ygo-advanced',
        name: 'Something I made up',
      );

      await Seed.applyArchetypes(db);

      expect(
        (await stored()).map((row) => row.name),
        isNot(contains('Something I made up')),
      );
    });

    test('an archetype with a match behind it survives the replace', () async {
      final archetypes = ArchetypeRepository(db);
      final mine = await archetypes.add(
        gameId: Seed.yugiohId,
        formatId: 'ygo-advanced',
        name: 'Deck nobody else lists',
      );

      final deck = await DeckRepository(db).createDeck(
        gameId: Seed.yugiohId,
        formatId: 'ygo-advanced',
        name: 'Snake-Eye',
        archetype: 'Snake-Eye',
      );

      await MatchRepository(db).add(
        MatchInput(
          gameId: Seed.yugiohId,
          formatId: 'ygo-advanced',
          deckId: deck.id,
          tournamentId: null,
          playedAt: DateTime.now(),
          opponentArchetypeId: mine.id,
          gamesWon: 2,
          gamesLost: 0,
        ),
      );

      await Seed.applyArchetypes(db);

      expect(
        (await stored()).map((row) => row.id),
        contains(mine.id),
        reason:
            'that round really was played against that deck, whatever the '
            'current list says',
      );
    });

    test(
      'a default already faced keeps its counter, and stays single',
      () async {
        final archetypes = ArchetypeRepository(db);

        // The name is on the shipped list, so a naive re-seed would add a second
        // row spelling it exactly the same way.
        final faced = await archetypes.findOrCreate(
          gameId: Seed.yugiohId,
          formatId: 'ygo-advanced',
          name: 'Branded',
        );

        final deck = await DeckRepository(db).createDeck(
          gameId: Seed.yugiohId,
          formatId: 'ygo-advanced',
          name: 'Snake-Eye',
          archetype: 'Snake-Eye',
        );

        await MatchRepository(db).add(
          MatchInput(
            gameId: Seed.yugiohId,
            formatId: 'ygo-advanced',
            deckId: deck.id,
            playedAt: DateTime.now(),
            opponentArchetypeId: faced.id,
            gamesWon: 2,
            gamesLost: 0,
          ),
        );

        await Seed.applyArchetypes(db);

        final branded = (await stored()).where(
          (row) => row.formatId == 'ygo-advanced' && row.name == 'Branded',
        );

        expect(branded, hasLength(1));
        expect(branded.single.timesFaced, 1);
      },
    );
  });
}
