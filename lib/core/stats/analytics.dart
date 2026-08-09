import '../../data/db/app_database.dart';
import '../../data/models/enums.dart';
import 'match_stats.dart';

/// A match with the two names the statistics are grouped by.
///
/// The archetype is carried alongside the match rather than looked up per
/// screen: every figure in the analytics section is "this archetype against
/// that one", and resolving that inside each widget would mean a query per
/// cell of a matrix.
///
/// [opponentArchetype] is null only for rows that predate the rule making the
/// opponent's deck mandatory, or that arrived through a restored backup. They
/// still count towards winrate — a match was played — but they cannot be
/// attributed to a matchup.
typedef AnalyzedMatch = ({
  Match match,
  String deckName,
  String deckArchetype,
  String? opponentArchetype,
});

/// Winrate split by who started game one.
class PlayDrawSplit {
  const PlayDrawSplit({
    this.onThePlay = const MatchRecord(),
    this.onTheDraw = const MatchRecord(),
    this.unrecorded = const MatchRecord(),
  });

  final MatchRecord onThePlay;
  final MatchRecord onTheDraw;

  /// Matches where nobody wrote down who went first. Kept visible rather than
  /// folded into one of the other two, which would invent data.
  final MatchRecord unrecorded;

  bool get isEmpty =>
      onThePlay.decidedMatches == 0 && onTheDraw.decidedMatches == 0;

  /// How many percentage points the play is worth, or null when one of the two
  /// sides has nothing to compare.
  double? get advantage {
    final play = onThePlay.winrate;
    final draw = onTheDraw.winrate;
    if (play == null || draw == null) return null;
    return play - draw;
  }
}

/// One archetype and how it did.
typedef ArchetypeRecord = ({String archetype, MatchRecord record});

/// One deck build and how it did.
typedef DeckRecord = ({
  String deckId,
  String name,
  String archetype,
  MatchRecord record,
  GameRecord games,
});

/// A month of results.
typedef TrendPoint = ({DateTime month, MatchRecord record});

/// How often an opponent archetype turned up.
typedef ArchetypeShare = ({String archetype, int faced, double share});

/// My archetypes against theirs.
///
/// Rows and columns are ordered by how much was played into them, so the
/// matchups that matter are the ones on screen without scrolling.
class MatchupMatrix {
  const MatchupMatrix({
    required this.mine,
    required this.theirs,
    required this.cells,
  });

  static const empty = MatchupMatrix(mine: [], theirs: [], cells: {});

  final List<String> mine;
  final List<String> theirs;
  final Map<(String, String), MatchRecord> cells;

  bool get isEmpty => cells.isEmpty;

  /// Null where the two decks have never met, which is different from having
  /// met and never won.
  MatchRecord? cell(String mineArchetype, String theirsArchetype) =>
      cells[(mineArchetype, theirsArchetype)];
}

/// Everything the analytics section computes.
///
/// It lives here and not in the widgets for the same reason [MatchStats] does:
/// a bye must be invisible to a winrate on every screen, and the only way to
/// be sure is to have one implementation.
abstract final class Analytics {
  /// Below this many decided matches, a figure is shown but visibly muted.
  ///
  /// Not a threshold for hiding anything: two matches are still two matches.
  /// It is there so a 100% winrate over two games does not read like a 100%
  /// winrate over forty.
  static const smallSample = 5;

  static bool isThin(MatchRecord record) => record.decidedMatches < smallSample;

  static MatchupMatrix matchup(Iterable<AnalyzedMatch> matches) {
    final cells = <(String, String), MatchRecord>{};
    final mineWeight = <String, int>{};
    final theirsWeight = <String, int>{};

    for (final entry in matches) {
      if (!entry.match.result.countsTowardsWinrate) continue;

      final theirs = entry.opponentArchetype;
      if (theirs == null) continue;

      final mine = entry.deckArchetype;
      final key = (mine, theirs);
      cells[key] =
          (cells[key] ?? const MatchRecord()) +
          MatchStats.recordOf([entry.match]);

      mineWeight[mine] = (mineWeight[mine] ?? 0) + 1;
      theirsWeight[theirs] = (theirsWeight[theirs] ?? 0) + 1;
    }

    return MatchupMatrix(
      mine: _byWeight(mineWeight),
      theirs: _byWeight(theirsWeight),
      cells: cells,
    );
  }

  static PlayDrawSplit playDraw(Iterable<AnalyzedMatch> matches) {
    var play = const MatchRecord();
    var draw = const MatchRecord();
    var unknown = const MatchRecord();

    for (final entry in matches) {
      if (!entry.match.result.countsTowardsWinrate) continue;
      final record = MatchStats.recordOf([entry.match]);

      switch (entry.match.onThePlay) {
        case true:
          play = play + record;
        case false:
          draw = draw + record;
        case null:
          unknown = unknown + record;
      }
    }

    return PlayDrawSplit(onThePlay: play, onTheDraw: draw, unrecorded: unknown);
  }

  /// My decks, most played first.
  static List<DeckRecord> byDeck(Iterable<AnalyzedMatch> matches) {
    final grouped = <String, List<AnalyzedMatch>>{};
    for (final entry in matches) {
      grouped.putIfAbsent(entry.match.deckId, () => []).add(entry);
    }

    final records = [
      for (final entries in grouped.values)
        (
          deckId: entries.first.match.deckId,
          name: entries.first.deckName,
          archetype: entries.first.deckArchetype,
          record: MatchStats.recordOf([for (final e in entries) e.match]),
          games: MatchStats.gameRecordOf([for (final e in entries) e.match]),
        ),
    ];

    records.sort(
      (a, b) => b.record.roundsPlayed.compareTo(a.record.roundsPlayed),
    );
    return records;
  }

  /// Results month by month, oldest first, with no gaps for months played.
  static List<TrendPoint> monthlyTrend(Iterable<AnalyzedMatch> matches) {
    final months = <DateTime, MatchRecord>{};

    for (final entry in matches) {
      if (!entry.match.result.countsTowardsWinrate) continue;
      final played = entry.match.playedAt;
      final month = DateTime(played.year, played.month);
      months[month] =
          (months[month] ?? const MatchRecord()) +
          MatchStats.recordOf([entry.match]);
    }

    final points = [
      for (final entry in months.entries)
        (month: entry.key, record: entry.value),
    ];

    points.sort((a, b) => a.month.compareTo(b.month));
    return points;
  }

  /// Which decks were actually across the table, most common first.
  ///
  /// This is the local meta: not what the internet says is played, what turned
  /// up at the shop.
  static List<ArchetypeShare> meta(Iterable<AnalyzedMatch> matches) {
    final counts = <String, int>{};
    var total = 0;

    for (final entry in matches) {
      if (!entry.match.result.countsTowardsWinrate) continue;
      final archetype = entry.opponentArchetype;
      if (archetype == null) continue;

      counts[archetype] = (counts[archetype] ?? 0) + 1;
      total++;
    }

    if (total == 0) return const [];

    final shares = [
      for (final entry in counts.entries)
        (archetype: entry.key, faced: entry.value, share: entry.value / total),
    ];

    shares.sort((a, b) => b.faced.compareTo(a.faced));
    return shares;
  }

  /// How I did against each archetype, ignoring which of my decks played it.
  static List<ArchetypeRecord> byOpponentArchetype(
    Iterable<AnalyzedMatch> matches,
  ) {
    final grouped = <String, MatchRecord>{};

    for (final entry in matches) {
      if (!entry.match.result.countsTowardsWinrate) continue;
      final archetype = entry.opponentArchetype;
      if (archetype == null) continue;

      grouped[archetype] =
          (grouped[archetype] ?? const MatchRecord()) +
          MatchStats.recordOf([entry.match]);
    }

    final records = [
      for (final entry in grouped.entries)
        (archetype: entry.key, record: entry.value),
    ];

    records.sort(
      (a, b) => b.record.decidedMatches.compareTo(a.record.decidedMatches),
    );
    return records;
  }

  static List<String> _byWeight(Map<String, int> weights) {
    final names = weights.keys.toList()
      ..sort((a, b) {
        final byWeight = weights[b]!.compareTo(weights[a]!);
        return byWeight != 0 ? byWeight : a.compareTo(b);
      });
    return names;
  }
}
