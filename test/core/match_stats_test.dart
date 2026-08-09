import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/stats/match_stats.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/data/repositories/match_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late MatchRepository matches;
  late String deckId;
  late String tournamentId;

  setUp(() async {
    db = createTestDatabase();
    matches = MatchRepository(db);

    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Izzet Prowess',
      archetype: 'Izzet Prowess',
    );
    deckId = deck.id;
    tournamentId = 'tournament-1';

    await db
        .into(db.tournaments)
        .insert(
          TournamentsCompanion.insert(
            id: tournamentId,
            gameId: Seed.magicId,
            formatId: 'mtg-modern',
            deckId: deckId,
            name: 'Test event',
            date: DateTime.now(),
            eventType: EventType.local,
            roundsPlanned: 5,
            status: TournamentStatus.ongoing,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() => db.close());

  Future<void> record({
    required int won,
    required int lost,
    int drawn = 0,
    bool isBye = false,
    int? round,
  }) async {
    await matches.add(
      MatchInput(
        tournamentId: tournamentId,
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        deckId: deckId,
        roundNumber: round ?? await matches.nextRoundNumber(tournamentId),
        gamesWon: won,
        gamesLost: lost,
        gamesDrawn: drawn,
        isBye: isBye,
        playedAt: DateTime.now(),
      ),
    );
  }

  Future<MatchRecord> currentRecord() async {
    return MatchStats.recordOf(
      await matches.watchTournamentMatches(tournamentId).first,
    );
  }

  group('result is derived from the games', () {
    test('more games won than lost is a win', () {
      expect(
        MatchStats.resultOf(isBye: false, gamesWon: 2, gamesLost: 1),
        MatchResult.win,
      );
    });

    test('more games lost than won is a loss', () {
      expect(
        MatchStats.resultOf(isBye: false, gamesWon: 0, gamesLost: 2),
        MatchResult.loss,
      );
    });

    test('an equal number of games is a draw', () {
      expect(
        MatchStats.resultOf(isBye: false, gamesWon: 1, gamesLost: 1),
        MatchResult.draw,
      );
    });

    test('a bye stays a bye whatever the games say', () {
      expect(
        MatchStats.resultOf(isBye: true, gamesWon: 2, gamesLost: 0),
        MatchResult.bye,
      );
    });
  });

  group('byes', () {
    test('are excluded from the winrate but kept in the record', () async {
      await record(won: 2, lost: 0);
      await record(won: 2, lost: 1);
      await record(won: 0, lost: 2);
      await record(won: 0, lost: 0, isBye: true);

      final result = await currentRecord();

      expect(result.wins, 2);
      expect(result.losses, 1);
      expect(result.byes, 1);
      expect(result.shortForm, '2-1');
      expect(
        result.decidedMatches,
        3,
        reason: 'the bye must not be in the winrate denominator',
      );
      expect(result.winrate, closeTo(2 / 3, 0.0001));
      expect(result.roundsPlayed, 4, reason: 'but it was still a round played');
    });

    test('contribute no games to the game record', () async {
      await record(won: 2, lost: 1);
      await record(won: 0, lost: 0, isBye: true);

      final games = MatchStats.gameRecordOf(
        await matches.watchTournamentMatches(tournamentId).first,
      );

      expect(games.won, 2);
      expect(games.lost, 1);
      expect(games.total, 3);
    });

    test('a tournament of nothing but byes has no winrate at all', () async {
      await record(won: 0, lost: 0, isBye: true);
      await record(won: 0, lost: 0, isBye: true);

      final result = await currentRecord();

      expect(result.winrate, isNull, reason: 'null, never zero');
      expect(result.roundsPlayed, 2);
      expect(
        result.points,
        6,
        reason: 'the organiser awards a bye like a win, so it scores like one',
      );
    });
  });

  group('points', () {
    test('are 3 a win, 1 a draw and 0 a loss', () async {
      await record(won: 2, lost: 0);
      await record(won: 2, lost: 1);
      await record(won: 1, lost: 1, drawn: 1);
      await record(won: 0, lost: 2);

      expect((await currentRecord()).points, 7);
    });

    test('a bye scores like a win without touching the winrate', () async {
      await record(won: 2, lost: 0);
      await record(won: 0, lost: 0, isBye: true);

      final result = await currentRecord();

      expect(result.points, 6);
      expect(
        result.winrate,
        1.0,
        reason: 'one decided match, won: the bye is not in the denominator',
      );
      expect(result.decidedMatches, 1);
    });

    test('nothing played scores nothing', () async {
      expect((await currentRecord()).points, 0);
    });
  });

  test('a draw shows up as the third number of the record', () async {
    await record(won: 2, lost: 0);
    await record(won: 1, lost: 1, drawn: 1);

    final result = await currentRecord();

    expect(result.shortForm, '1-0-1');
    expect(result.draws, 1);
  });

  test('an empty record has no winrate and no numbers', () {
    const empty = MatchRecord();

    expect(empty.isEmpty, isTrue);
    expect(empty.winrate, isNull);
    expect(empty.shortForm, '0-0');
  });

  test('top cut matches count exactly like swiss rounds', () async {
    await record(won: 2, lost: 0);
    await matches.add(
      MatchInput(
        tournamentId: tournamentId,
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        deckId: deckId,
        isTopCut: true,
        gamesWon: 2,
        gamesLost: 1,
        playedAt: DateTime.now(),
      ),
    );

    final result = await currentRecord();

    expect(result.wins, 2);
    expect(result.decidedMatches, 2);
  });
}
