import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';

/// A seeded, in-memory database for a single test.
///
/// It is the real database, so it opens with the shipped opponent archetype
/// list already in it, exactly as the app does on a phone.
AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());

/// Empties the shipped archetype list.
///
/// For tests about the rules rather than about the contents: "the list is
/// ordered by how often each archetype was faced" is far easier to read with
/// two rows in the table than with two hundred and sixty. Tests that are about
/// what ships in the box do not call this.
Future<void> clearSeededArchetypes(AppDatabase db) async {
  await db.delete(db.opponentArchetypes).go();
}

/// Inserts a tournament and one match played with [deckId], which is what makes
/// that deck impossible to delete.
Future<void> insertHistoryFor(
  AppDatabase db, {
  required String deckId,
  String formatId = 'mtg-modern',
  String? opponentArchetypeId,
}) async {
  final now = DateTime.now();

  await db
      .into(db.tournaments)
      .insert(
        TournamentsCompanion.insert(
          id: 'tournament-1',
          gameId: Seed.magicId,
          formatId: formatId,
          deckId: deckId,
          name: 'Test event',
          date: now,
          eventType: EventType.local,
          roundsPlanned: 4,
          status: TournamentStatus.finished,
          createdAt: now,
          updatedAt: now,
        ),
      );

  await db
      .into(db.matches)
      .insert(
        MatchesCompanion.insert(
          id: 'match-1',
          tournamentId: const Value('tournament-1'),
          gameId: Seed.magicId,
          formatId: formatId,
          deckId: deckId,
          roundNumber: const Value(1),
          opponentArchetypeId: Value(opponentArchetypeId),
          onThePlay: const Value(true),
          gamesWon: const Value(2),
          gamesLost: const Value(1),
          result: MatchResult.win,
          playedAt: now,
        ),
      );
}
