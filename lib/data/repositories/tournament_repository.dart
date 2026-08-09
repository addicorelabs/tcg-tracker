import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../models/enums.dart';

/// What the tournament list is currently showing.
@immutable
class TournamentFilter {
  const TournamentFilter({this.gameId, this.formatId, this.status});

  final String? gameId;
  final String? formatId;
  final TournamentStatus? status;

  TournamentFilter copyWith({
    String? gameId,
    bool clearGame = false,
    String? formatId,
    bool clearFormat = false,
    TournamentStatus? status,
    bool clearStatus = false,
  }) {
    return TournamentFilter(
      gameId: clearGame ? null : (gameId ?? this.gameId),
      formatId: clearFormat ? null : (formatId ?? this.formatId),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class TournamentRepository {
  TournamentRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Most recent first: the tournament you want is almost always the last one
  /// you played.
  Stream<List<Tournament>> watchTournaments([
    TournamentFilter filter = const TournamentFilter(),
  ]) {
    final query = _db.select(_db.tournaments)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    if (filter.gameId != null) {
      query.where((t) => t.gameId.equals(filter.gameId!));
    }
    if (filter.formatId != null) {
      query.where((t) => t.formatId.equals(filter.formatId!));
    }
    if (filter.status != null) {
      query.where((t) => t.status.equalsValue(filter.status!));
    }

    return query.watch();
  }

  Stream<Tournament?> watchTournament(String id) {
    return (_db.select(
      _db.tournaments,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// The tournament the user is in the middle of, if any.
  ///
  /// The dashboard leans on this, so it returns the most recent one rather
  /// than failing if two were ever left open at once.
  Stream<Tournament?> watchOngoing() {
    return (_db.select(_db.tournaments)
          ..where((t) => t.status.equalsValue(TournamentStatus.ongoing))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<Tournament> create({
    required String gameId,
    required String formatId,
    required String deckId,
    required String name,
    required DateTime date,
    required EventType eventType,
    required int roundsPlanned,
    int? participantCount,
    bool hasTopCut = false,
    int? topCutSize,
    String? notes,
  }) {
    final now = DateTime.now();

    return _db
        .into(_db.tournaments)
        .insertReturning(
          TournamentsCompanion.insert(
            id: _uuid.v4(),
            gameId: gameId,
            formatId: formatId,
            deckId: deckId,
            name: name.trim(),
            date: date,
            eventType: eventType,
            roundsPlanned: roundsPlanned,
            participantCount: Value(participantCount),
            hasTopCut: Value(hasTopCut),
            topCutSize: Value(topCutSize),
            // A tournament is created to be played, so it opens ongoing and the
            // user is taken straight to recording round one.
            status: TournamentStatus.ongoing,
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> update({
    required String id,
    required String name,
    required DateTime date,
    required EventType eventType,
    required int roundsPlanned,
    required String deckId,
    int? participantCount,
    bool hasTopCut = false,
    int? topCutSize,
    String? notes,
  }) {
    return (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        name: Value(name.trim()),
        date: Value(date),
        eventType: Value(eventType),
        roundsPlanned: Value(roundsPlanned),
        deckId: Value(deckId),
        participantCount: Value(participantCount),
        hasTopCut: Value(hasTopCut),
        topCutSize: Value(topCutSize),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Closes a tournament, optionally recording where the user placed.
  Future<void> finish(String id, {int? finalStanding}) {
    return (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        status: const Value(TournamentStatus.finished),
        finalStanding: Value(finalStanding),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> reopen(String id) {
    return (_db.update(_db.tournaments)..where((t) => t.id.equals(id))).write(
      TournamentsCompanion(
        status: const Value(TournamentStatus.ongoing),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a tournament together with its rounds.
  ///
  /// Done by hand rather than by a cascade so the opponent counters stay
  /// correct: every round has to be walked anyway to decrement them.
  Future<void> delete(String id) {
    return _db.transaction(() async {
      final matches = await (_db.select(
        _db.matches,
      )..where((m) => m.tournamentId.equals(id))).get();

      for (final match in matches) {
        await _decrementArchetype(match.opponentArchetypeId);
      }

      await (_db.delete(
        _db.matches,
      )..where((m) => m.tournamentId.equals(id))).go();
      await (_db.delete(_db.tournaments)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> _decrementArchetype(String? archetypeId) async {
    if (archetypeId == null) return;

    await _db.customUpdate(
      'UPDATE opponent_archetypes SET times_faced = MAX(times_faced - 1, 0) '
      'WHERE id = ?',
      variables: [Variable.withString(archetypeId)],
      updates: {_db.opponentArchetypes},
    );
  }
}

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository(ref.watch(appDatabaseProvider));
});
