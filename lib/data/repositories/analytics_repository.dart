import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/stats/analytics.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// What the analytics section is looking at.
///
/// Every field narrows: a null one means "all of them".
@immutable
class AnalyticsFilter {
  const AnalyticsFilter({this.gameId, this.formatId, this.deckId, this.since});

  final String? gameId;
  final String? formatId;
  final String? deckId;

  /// Oldest match to include. Null covers the whole history.
  final DateTime? since;

  AnalyticsFilter copyWith({
    String? gameId,
    bool clearGame = false,
    String? formatId,
    bool clearFormat = false,
    String? deckId,
    bool clearDeck = false,
    DateTime? since,
    bool clearSince = false,
  }) {
    return AnalyticsFilter(
      gameId: clearGame ? null : (gameId ?? this.gameId),
      formatId: clearFormat ? null : (formatId ?? this.formatId),
      deckId: clearDeck ? null : (deckId ?? this.deckId),
      since: clearSince ? null : (since ?? this.since),
    );
  }
}

/// Reads matches with the names the statistics group by already attached.
///
/// One query with two joins, rather than a match query plus a lookup per row:
/// a matchup matrix asks for the same archetype hundreds of times, and doing
/// that one round trip at a time is how a fast local database starts to feel
/// slow.
class AnalyticsRepository {
  AnalyticsRepository(this._db);

  final AppDatabase _db;

  Stream<List<AnalyzedMatch>> watchMatches(AnalyticsFilter filter) {
    final query = _db.select(_db.matches).join([
      innerJoin(_db.decks, _db.decks.id.equalsExp(_db.matches.deckId)),
      leftOuterJoin(
        _db.opponentArchetypes,
        _db.opponentArchetypes.id.equalsExp(_db.matches.opponentArchetypeId),
      ),
    ]);

    // Only tournament matches. Casual matches are excluded from the analytics
    // by design, and since the life counter replaced the casual recorder there
    // is no screen that creates one — a filter offering to include them would
    // be a control with nothing behind it.
    query.where(_db.matches.tournamentId.isNotNull());

    if (filter.gameId != null) {
      query.where(_db.matches.gameId.equals(filter.gameId!));
    }
    if (filter.formatId != null) {
      query.where(_db.matches.formatId.equals(filter.formatId!));
    }
    if (filter.deckId != null) {
      query.where(_db.matches.deckId.equals(filter.deckId!));
    }
    if (filter.since != null) {
      query.where(_db.matches.playedAt.isBiggerOrEqualValue(filter.since!));
    }

    query.orderBy([OrderingTerm(expression: _db.matches.playedAt)]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            match: row.readTable(_db.matches),
            deckName: row.readTable(_db.decks).name,
            deckArchetype: row.readTable(_db.decks).archetype.trim(),
            opponentArchetype: row
                .readTableOrNull(_db.opponentArchetypes)
                ?.name
                .trim(),
          ),
      ],
    );
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(appDatabaseProvider));
});
