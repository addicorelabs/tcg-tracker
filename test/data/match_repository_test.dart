import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
import 'package:tcg_tracker/data/repositories/archetype_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/data/repositories/match_repository.dart';
import 'package:tcg_tracker/data/repositories/tournament_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late MatchRepository matches;
  late ArchetypeRepository archetypes;
  late String deckId;
  late Tournament tournament;

  setUp(() async {
    db = createTestDatabase();
    matches = MatchRepository(db);
    archetypes = ArchetypeRepository(db);

    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Izzet Prowess',
      archetype: 'Izzet Prowess',
    );
    deckId = deck.id;

    tournament = await TournamentRepository(db).create(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      deckId: deckId,
      name: 'Modern Challenge',
      date: DateTime.now(),
      eventType: EventType.local,
      roundsPlanned: 5,
    );
  });

  tearDown(() => db.close());

  MatchInput input({
    int won = 2,
    int lost = 0,
    int? round,
    String? archetypeId,
    bool isBye = false,
    bool isTopCut = false,
    String? opponentName,
  }) {
    return MatchInput(
      tournamentId: tournament.id,
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      deckId: deckId,
      roundNumber: round,
      isTopCut: isTopCut,
      opponentName: opponentName,
      opponentArchetypeId: archetypeId,
      gamesWon: won,
      gamesLost: lost,
      isBye: isBye,
      playedAt: DateTime.now(),
    );
  }

  Future<OpponentArchetype> addArchetype(String name) =>
      archetypes.add(gameId: Seed.magicId, formatId: 'mtg-modern', name: name);

  Future<int> timesFaced(String id) async {
    final all = await archetypes
        .watchArchetypes(Seed.magicId, 'mtg-modern')
        .first;
    return all.firstWhere((a) => a.id == id).timesFaced;
  }

  test('the round number follows the last one recorded', () async {
    expect(await matches.nextRoundNumber(tournament.id), 1);

    await matches.add(input(round: 1));
    await matches.add(input(round: 2));

    expect(await matches.nextRoundNumber(tournament.id), 3);
  });

  test('the result is stored from the games, never typed in', () async {
    await matches.add(input(won: 1, lost: 2, round: 1));

    final match = await db.select(db.matches).getSingle();
    expect(match.result, MatchResult.loss);
  });

  test('an empty opponent name is stored as nothing, not as blank', () async {
    await matches.add(input(round: 1, opponentName: '   '));

    final match = await db.select(db.matches).getSingle();
    expect(match.opponentName, isNull);
  });

  group('opponent counters', () {
    test('go up when a match is recorded against an archetype', () async {
      final boros = await addArchetype('Boros Energy');

      await matches.add(input(round: 1, archetypeId: boros.id));
      await matches.add(input(round: 2, archetypeId: boros.id));

      expect(await timesFaced(boros.id), 2);
    });

    test('move across when a match is corrected', () async {
      final boros = await addArchetype('Boros Energy');
      final amulet = await addArchetype('Amulet Titan');
      final match = await matches.add(input(round: 1, archetypeId: boros.id));

      await matches.update(match.id, input(round: 1, archetypeId: amulet.id));

      expect(await timesFaced(boros.id), 0);
      expect(await timesFaced(amulet.id), 1);
    });

    test(
      'stay put when a match is edited without changing the opponent',
      () async {
        final boros = await addArchetype('Boros Energy');
        final match = await matches.add(input(round: 1, archetypeId: boros.id));

        await matches.update(
          match.id,
          input(won: 0, lost: 2, round: 1, archetypeId: boros.id),
        );

        expect(await timesFaced(boros.id), 1);
        final updated = await db.select(db.matches).getSingle();
        expect(updated.result, MatchResult.loss);
      },
    );

    test('come back down when a round is deleted', () async {
      final boros = await addArchetype('Boros Energy');
      final match = await matches.add(input(round: 1, archetypeId: boros.id));

      await matches.delete(match.id);

      expect(await timesFaced(boros.id), 0);
      expect(await db.select(db.matches).get(), isEmpty);
    });

    test('never fall below zero', () async {
      final boros = await addArchetype('Boros Energy');
      final match = await matches.add(input(round: 1, archetypeId: boros.id));
      await matches.delete(match.id);

      // Deleting an already-removed match must not push the counter negative.
      await matches.delete(match.id);

      expect(await timesFaced(boros.id), 0);
    });
  });

  test('rounds come back in playing order, top cut last', () async {
    await matches.add(input(round: 2));
    await matches.add(input(round: 1));
    await matches.add(input(isTopCut: true));

    final ordered = await matches.watchTournamentMatches(tournament.id).first;

    expect(ordered.map((m) => m.roundNumber), [1, 2, null]);
    expect(ordered.last.isTopCut, isTrue);
  });

  test('casual matches are kept apart from tournament rounds', () async {
    await matches.add(input(round: 1));
    await matches.add(
      MatchInput(
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        deckId: deckId,
        gamesWon: 2,
        gamesLost: 1,
        playedAt: DateTime.now(),
      ),
    );

    expect(
      await matches.watchTournamentMatches(tournament.id).first,
      hasLength(1),
    );
    expect(await matches.watchCasualMatches().first, hasLength(1));
  });

  test('the dashboard window only sees competitive matches in range', () async {
    await matches.add(input(round: 1));
    await matches.add(
      MatchInput(
        tournamentId: tournament.id,
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        deckId: deckId,
        roundNumber: 2,
        gamesWon: 2,
        gamesLost: 0,
        playedAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    );
    await matches.add(
      MatchInput(
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        deckId: deckId,
        gamesWon: 2,
        gamesLost: 0,
        playedAt: DateTime.now(),
      ),
    );

    final recent = await matches
        .watchCompetitiveMatchesSince(
          DateTime.now().subtract(const Duration(days: 30)),
        )
        .first;

    expect(
      recent,
      hasLength(1),
      reason: 'the old round and the casual match are both out',
    );
  });
}
