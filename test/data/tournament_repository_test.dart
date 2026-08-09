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
  late TournamentRepository tournaments;
  late MatchRepository matches;
  late ArchetypeRepository archetypes;
  late String deckId;

  setUp(() async {
    db = createTestDatabase();
    tournaments = TournamentRepository(db);
    matches = MatchRepository(db);
    archetypes = ArchetypeRepository(db);

    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      name: 'Izzet Prowess',
      archetype: 'Izzet Prowess',
    );
    deckId = deck.id;
  });

  tearDown(() => db.close());

  Future<Tournament> create({
    String name = 'Modern Challenge',
    DateTime? date,
  }) {
    return tournaments.create(
      gameId: Seed.magicId,
      formatId: 'mtg-modern',
      deckId: deckId,
      name: name,
      date: date ?? DateTime.now(),
      eventType: EventType.local,
      roundsPlanned: 5,
    );
  }

  test(
    'a new tournament opens in progress, ready to record round one',
    () async {
      final tournament = await create();

      expect(tournament.status, TournamentStatus.ongoing);
      expect(await tournaments.watchOngoing().first, isNotNull);
      expect(await matches.nextRoundNumber(tournament.id), 1);
    },
  );

  test('finishing records the standing and closes the tournament', () async {
    final tournament = await create();

    await tournaments.finish(tournament.id, finalStanding: 3);

    final finished = await tournaments.watchTournament(tournament.id).first;
    expect(finished!.status, TournamentStatus.finished);
    expect(finished.finalStanding, 3);
    expect(
      await tournaments.watchOngoing().first,
      isNull,
      reason: 'a finished tournament must leave the dashboard',
    );
  });

  test('reopening puts it back in progress', () async {
    final tournament = await create();
    await tournaments.finish(tournament.id);

    await tournaments.reopen(tournament.id);

    expect(
      (await tournaments.watchTournament(tournament.id).first)!.status,
      TournamentStatus.ongoing,
    );
  });

  test('the list is newest first', () async {
    await create(name: 'Old', date: DateTime(2026, 1, 1));
    await create(name: 'Recent', date: DateTime(2026, 8, 1));

    final all = await tournaments.watchTournaments().first;

    expect(all.map((t) => t.name), ['Recent', 'Old']);
  });

  test('filters narrow by game, format and status', () async {
    final modern = await create();
    await tournaments.finish(modern.id);
    await tournaments.create(
      gameId: Seed.magicId,
      formatId: 'mtg-legacy',
      deckId: deckId,
      name: 'Legacy night',
      date: DateTime.now(),
      eventType: EventType.local,
      roundsPlanned: 4,
    );

    expect(
      await tournaments
          .watchTournaments(const TournamentFilter(formatId: 'mtg-modern'))
          .first,
      hasLength(1),
    );
    expect(
      await tournaments
          .watchTournaments(
            const TournamentFilter(status: TournamentStatus.ongoing),
          )
          .first,
      hasLength(1),
    );
    expect(
      await tournaments
          .watchTournaments(TournamentFilter(gameId: Seed.yugiohId))
          .first,
      isEmpty,
    );
  });

  test(
    'deleting takes the rounds with it and gives back the opponent counts',
    () async {
      final tournament = await create();
      final archetype = await archetypes.add(
        gameId: Seed.magicId,
        formatId: 'mtg-modern',
        name: 'Boros Energy',
      );

      await matches.add(
        MatchInput(
          tournamentId: tournament.id,
          gameId: Seed.magicId,
          formatId: 'mtg-modern',
          deckId: deckId,
          roundNumber: 1,
          opponentArchetypeId: archetype.id,
          gamesWon: 2,
          gamesLost: 0,
          playedAt: DateTime.now(),
        ),
      );

      await tournaments.delete(tournament.id);

      expect(await db.select(db.matches).get(), isEmpty);
      expect(await db.select(db.tournaments).get(), isEmpty);

      final counted = await archetypes
          .watchArchetypes(Seed.magicId, 'mtg-modern')
          .first;
      expect(
        counted.firstWhere((a) => a.id == archetype.id).timesFaced,
        0,
        reason: 'a deleted tournament must not leave the meta count inflated',
      );
    },
  );
}
