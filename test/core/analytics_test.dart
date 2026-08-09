import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/stats/analytics.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';

void main() {
  var counter = 0;

  AnalyzedMatch played({
    required MatchResult result,
    String mine = 'Snake-Eye',
    String? theirs = 'Fire King',
    String deckId = 'deck-1',
    String deckName = 'Snake-Eye Fire King',
    bool? onThePlay,
    DateTime? at,
    int gamesWon = 2,
    int gamesLost = 1,
  }) {
    counter++;
    return (
      match: Match(
        id: 'match-$counter',
        tournamentId: 'tournament-1',
        gameId: Seed.yugiohId,
        formatId: 'ygo-advanced',
        deckId: deckId,
        isTopCut: false,
        onThePlay: onThePlay,
        gamesWon: gamesWon,
        gamesLost: gamesLost,
        gamesDrawn: 0,
        result: result,
        playedAt: at ?? DateTime(2026, 6, 1),
      ),
      deckName: deckName,
      deckArchetype: mine,
      opponentArchetype: theirs,
    );
  }

  setUp(() => counter = 0);

  group('byes', () {
    test('a bye is in no winrate, no matchup and no meta', () {
      final matches = [
        played(result: MatchResult.win),
        played(result: MatchResult.bye, theirs: null),
      ];

      final matrix = Analytics.matchup(matches);
      expect(matrix.cell('Snake-Eye', 'Fire King')!.decidedMatches, 1);
      expect(matrix.theirs, [
        'Fire King',
      ], reason: 'a bye has no opponent to attribute it to');

      expect(Analytics.meta(matches).single.faced, 1);
      expect(Analytics.playDraw(matches).unrecorded.decidedMatches, 1);
    });

    test('a bye recorded with an opponent archetype is still ignored', () {
      // Possible through a restored backup: the column allows it even though
      // the round editor does not.
      final matches = [played(result: MatchResult.bye)];

      expect(Analytics.matchup(matches).isEmpty, isTrue);
      expect(Analytics.meta(matches), isEmpty);
      expect(Analytics.monthlyTrend(matches), isEmpty);
    });
  });

  group('matchup matrix', () {
    test('rows and columns lead with what was played most', () {
      final matches = [
        for (var i = 0; i < 3; i++)
          played(result: MatchResult.win, theirs: 'Fire King'),
        played(result: MatchResult.loss, theirs: 'Branded'),
        played(result: MatchResult.win, mine: 'Labrynth', theirs: 'Branded'),
      ];

      final matrix = Analytics.matchup(matches);

      expect(matrix.mine, ['Snake-Eye', 'Labrynth']);
      expect(matrix.theirs, ['Fire King', 'Branded']);
      expect(matrix.cell('Snake-Eye', 'Fire King')!.winrate, 1.0);
      expect(matrix.cell('Snake-Eye', 'Branded')!.winrate, 0.0);
    });

    test('a pairing never played is null, not zero', () {
      final matrix = Analytics.matchup([played(result: MatchResult.win)]);

      expect(
        matrix.cell('Snake-Eye', 'Branded'),
        isNull,
        reason: 'never met and met but never won are different facts',
      );
    });

    test('a match with no opponent archetype cannot be placed', () {
      final matches = [
        played(result: MatchResult.win, theirs: null),
        played(result: MatchResult.loss),
      ];

      final matrix = Analytics.matchup(matches);

      expect(matrix.cells, hasLength(1));
      expect(matrix.cell('Snake-Eye', 'Fire King')!.decidedMatches, 1);
    });
  });

  group('play and draw', () {
    test('matches split by who started, unknowns kept apart', () {
      final split = Analytics.playDraw([
        played(result: MatchResult.win, onThePlay: true),
        played(result: MatchResult.win, onThePlay: true),
        played(result: MatchResult.loss, onThePlay: false),
        played(result: MatchResult.win, onThePlay: null),
      ]);

      expect(split.onThePlay.winrate, 1.0);
      expect(split.onTheDraw.winrate, 0.0);
      expect(
        split.unrecorded.decidedMatches,
        1,
        reason:
            'a match with nothing written down must not be invented into '
            'one of the two piles',
      );
      expect(split.advantage, 1.0);
    });

    test('no advantage without both sides', () {
      final split = Analytics.playDraw([
        played(result: MatchResult.win, onThePlay: true),
      ]);

      expect(split.advantage, isNull);
    });
  });

  group('trend', () {
    test('months come out in order, and a month unplayed is absent', () {
      final trend = Analytics.monthlyTrend([
        played(result: MatchResult.loss, at: DateTime(2026, 5, 20)),
        played(result: MatchResult.win, at: DateTime(2026, 3, 2)),
        played(result: MatchResult.win, at: DateTime(2026, 3, 20)),
      ]);

      expect(trend.map((point) => point.month.month), [3, 5]);
      expect(trend.first.record.winrate, 1.0);
      expect(
        trend.length,
        2,
        reason:
            'April was not played, and an empty month is not a month of '
            'losses',
      );
    });
  });

  group('meta', () {
    test('shares add up over the matches with a known opponent', () {
      final meta = Analytics.meta([
        played(result: MatchResult.win, theirs: 'Fire King'),
        played(result: MatchResult.loss, theirs: 'Fire King'),
        played(result: MatchResult.win, theirs: 'Branded'),
        played(result: MatchResult.win, theirs: null),
      ]);

      expect(meta.first.archetype, 'Fire King');
      expect(meta.first.faced, 2);
      expect(meta.first.share, closeTo(2 / 3, 0.001));
      expect(meta.map((share) => share.share).reduce((a, b) => a + b), 1.0);
    });
  });

  group('by deck', () {
    test('decks are listed most played first, with their games', () {
      final decks = Analytics.byDeck([
        played(result: MatchResult.win, deckId: 'a', gamesWon: 2, gamesLost: 0),
        played(
          result: MatchResult.loss,
          deckId: 'a',
          gamesWon: 1,
          gamesLost: 2,
        ),
        played(result: MatchResult.win, deckId: 'b'),
      ]);

      expect(decks.first.deckId, 'a');
      expect(decks.first.record.decidedMatches, 2);
      expect(decks.first.games.won, 3);
      expect(decks.first.games.lost, 2);
    });
  });

  test('a small sample is flagged, not hidden', () {
    final thin = Analytics.matchup([
      played(result: MatchResult.win),
    ]).cell('Snake-Eye', 'Fire King')!;

    expect(Analytics.isThin(thin), isTrue);
    expect(
      thin.winrate,
      1.0,
      reason: 'the number is still the number; only its presentation changes',
    );
  });
}
