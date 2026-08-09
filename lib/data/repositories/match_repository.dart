import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/stats/match_stats.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// Everything needed to record a match, from either a tournament round or a
/// casual game.
///
/// The result is not part of it: it is worked out from the games played, so it
/// can never contradict them.
class MatchInput {
  const MatchInput({
    required this.gameId,
    required this.formatId,
    required this.deckId,
    required this.playedAt,
    this.tournamentId,
    this.roundNumber,
    this.isTopCut = false,
    this.opponentName,
    this.opponentArchetypeId,
    this.onThePlay,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.gamesDrawn = 0,
    this.isBye = false,
    this.notes,
  });

  final String gameId;
  final String formatId;
  final String deckId;
  final DateTime playedAt;
  final String? tournamentId;
  final int? roundNumber;
  final bool isTopCut;
  final String? opponentName;
  final String? opponentArchetypeId;
  final bool? onThePlay;
  final int gamesWon;
  final int gamesLost;
  final int gamesDrawn;
  final bool isBye;
  final String? notes;
}

class MatchRepository {
  MatchRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Match>> watchTournamentMatches(String tournamentId) {
    return (_db.select(_db.matches)
          ..where((m) => m.tournamentId.equals(tournamentId))
          ..orderBy([
            (m) => OrderingTerm(expression: m.isTopCut),
            (m) => OrderingTerm(expression: m.roundNumber),
            (m) => OrderingTerm(expression: m.playedAt),
          ]))
        .watch();
  }

  /// Matches played outside any tournament.
  Stream<List<Match>> watchCasualMatches({String? gameId, String? formatId}) {
    final query = _db.select(_db.matches)
      ..where((m) => m.tournamentId.isNull())
      ..orderBy([
        (m) => OrderingTerm(expression: m.playedAt, mode: OrderingMode.desc),
      ]);

    if (gameId != null) query.where((m) => m.gameId.equals(gameId));
    if (formatId != null) query.where((m) => m.formatId.equals(formatId));

    return query.watch();
  }

  /// Every tournament match played on or after [since], for the dashboard.
  Stream<List<Match>> watchCompetitiveMatchesSince(DateTime since) {
    return (_db.select(_db.matches)..where(
          (m) =>
              m.tournamentId.isNotNull() &
              m.playedAt.isBiggerOrEqualValue(since),
        ))
        .watch();
  }

  Stream<Match?> watchMatch(String id) {
    return (_db.select(
      _db.matches,
    )..where((m) => m.id.equals(id))).watchSingleOrNull();
  }

  /// The next round number to record for a tournament.
  Future<int> nextRoundNumber(String tournamentId) async {
    final highest =
        await (_db.selectOnly(_db.matches)
              ..addColumns([_db.matches.roundNumber.max()])
              ..where(_db.matches.tournamentId.equals(tournamentId)))
            .map((row) => row.read(_db.matches.roundNumber.max()))
            .getSingleOrNull();

    return (highest ?? 0) + 1;
  }

  Future<Match> add(MatchInput input) {
    return _db.transaction(() async {
      final match = await _db
          .into(_db.matches)
          .insertReturning(
            MatchesCompanion.insert(
              id: _uuid.v4(),
              tournamentId: Value(input.tournamentId),
              gameId: input.gameId,
              formatId: input.formatId,
              deckId: input.deckId,
              roundNumber: Value(input.roundNumber),
              isTopCut: Value(input.isTopCut),
              opponentName: Value(_trimToNull(input.opponentName)),
              opponentArchetypeId: Value(input.opponentArchetypeId),
              onThePlay: Value(input.onThePlay),
              gamesWon: Value(input.gamesWon),
              gamesLost: Value(input.gamesLost),
              gamesDrawn: Value(input.gamesDrawn),
              result: MatchStats.resultOf(
                isBye: input.isBye,
                gamesWon: input.gamesWon,
                gamesLost: input.gamesLost,
              ),
              playedAt: input.playedAt,
              notes: Value(_trimToNull(input.notes)),
            ),
          );

      await _adjustArchetype(input.opponentArchetypeId, 1);
      return match;
    });
  }

  /// Rewrites a match, keeping the opponent counters in step.
  Future<void> update(String id, MatchInput input) {
    return _db.transaction(() async {
      final previous = await (_db.select(
        _db.matches,
      )..where((m) => m.id.equals(id))).getSingle();

      await (_db.update(_db.matches)..where((m) => m.id.equals(id))).write(
        MatchesCompanion(
          roundNumber: Value(input.roundNumber),
          isTopCut: Value(input.isTopCut),
          opponentName: Value(_trimToNull(input.opponentName)),
          opponentArchetypeId: Value(input.opponentArchetypeId),
          onThePlay: Value(input.onThePlay),
          gamesWon: Value(input.gamesWon),
          gamesLost: Value(input.gamesLost),
          gamesDrawn: Value(input.gamesDrawn),
          result: Value(
            MatchStats.resultOf(
              isBye: input.isBye,
              gamesWon: input.gamesWon,
              gamesLost: input.gamesLost,
            ),
          ),
          playedAt: Value(input.playedAt),
          notes: Value(_trimToNull(input.notes)),
          deckId: Value(input.deckId),
        ),
      );

      if (previous.opponentArchetypeId != input.opponentArchetypeId) {
        await _adjustArchetype(previous.opponentArchetypeId, -1);
        await _adjustArchetype(input.opponentArchetypeId, 1);
      }
    });
  }

  Future<void> delete(String id) {
    return _db.transaction(() async {
      final match = await (_db.select(
        _db.matches,
      )..where((m) => m.id.equals(id))).getSingleOrNull();
      if (match == null) return;

      await (_db.delete(_db.matches)..where((m) => m.id.equals(id))).go();
      await _adjustArchetype(match.opponentArchetypeId, -1);
    });
  }

  /// Keeps `times_faced` honest, which is what orders the archetype
  /// suggestions by the local meta.
  Future<void> _adjustArchetype(String? archetypeId, int delta) async {
    if (archetypeId == null) return;

    await _db.customUpdate(
      'UPDATE opponent_archetypes SET times_faced = MAX(times_faced + ?, 0) '
      'WHERE id = ?',
      variables: [Variable.withInt(delta), Variable.withString(archetypeId)],
      updates: {_db.opponentArchetypes},
    );
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.watch(appDatabaseProvider));
});
