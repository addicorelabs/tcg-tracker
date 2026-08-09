import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/models/enums.dart';
import 'package:tcg_tracker/data/repositories/analytics_repository.dart';
import 'package:tcg_tracker/data/repositories/archetype_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/data/repositories/match_repository.dart';
import 'package:tcg_tracker/data/repositories/tournament_repository.dart';
import 'package:tcg_tracker/features/analytics/presentation/widgets/matchup_grid.dart';

import '../helpers/app_harness.dart';
import '../helpers/test_database.dart';

void main() {
  late AppHarness harness;
  late AppDatabase db;

  setUp(() async {
    harness = await AppHarness.create();
    db = harness.database;
  });

  /// A finished tournament with the rounds given, so the analytics section has
  /// something real to read rather than hand-built rows.
  Future<void> recordSeason({
    required List<({MatchResult result, String? opponent, bool? onThePlay})>
    rounds,
    String deckName = 'Snake-Eye Fire King',
    String archetype = 'Snake-Eye',
  }) async {
    final deck = await DeckRepository(db).createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      name: deckName,
      archetype: archetype,
    );

    final tournament = await TournamentRepository(db).create(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      deckId: deck.id,
      name: 'Regional',
      date: DateTime.now(),
      eventType: EventType.regional,
      roundsPlanned: rounds.length,
    );

    final archetypes = ArchetypeRepository(db);
    final matches = MatchRepository(db);

    for (final (index, round) in rounds.indexed) {
      final opponent = round.opponent == null
          ? null
          : await archetypes.findOrCreate(
              gameId: Seed.yugiohId,
              formatId: 'ygo-advanced',
              name: round.opponent!,
            );

      await matches.add(
        MatchInput(
          gameId: Seed.yugiohId,
          formatId: 'ygo-advanced',
          deckId: deck.id,
          tournamentId: tournament.id,
          roundNumber: index + 1,
          playedAt: DateTime.now(),
          opponentArchetypeId: opponent?.id,
          onThePlay: round.onThePlay,
          isBye: round.result == MatchResult.bye,
          gamesWon: switch (round.result) {
            MatchResult.win => 2,
            MatchResult.loss => 0,
            _ => 1,
          },
          gamesLost: switch (round.result) {
            MatchResult.win => 0,
            MatchResult.loss => 2,
            _ => 1,
          },
        ),
      );
    }
  }

  Future<void> openAnalytics(WidgetTester tester) async {
    setSurfaceSize(tester, const Size(400, 2400));
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.insights_outlined).first);
    await tester.pumpAndSettle();
  }

  testWidgets('an empty section says what to do about it', (tester) async {
    await openAnalytics(tester);

    expect(
      find.text('Record a tournament round and the numbers start here.'),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('the winrate ignores the bye that the record keeps', (
    tester,
  ) async {
    await recordSeason(
      rounds: [
        (result: MatchResult.win, opponent: 'Fire King', onThePlay: true),
        (result: MatchResult.win, opponent: 'Branded', onThePlay: false),
        (result: MatchResult.loss, opponent: 'Branded', onThePlay: false),
        (result: MatchResult.bye, opponent: null, onThePlay: null),
      ],
    );

    await openAnalytics(tester);

    expect(
      find.text('67%'),
      findsWidgets,
      reason:
          '2 wins out of 3 decided matches, with the bye left out of both '
          'sides of the fraction',
    );
    expect(find.text('3 matches'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('the matchup grid appears once opponents are known', (
    tester,
  ) async {
    await recordSeason(
      rounds: [
        (result: MatchResult.win, opponent: 'Fire King', onThePlay: true),
        (result: MatchResult.loss, opponent: 'Branded', onThePlay: false),
      ],
    );

    await openAnalytics(tester);

    expect(find.byType(MatchupGrid), findsOneWidget);
    expect(find.text('Snake-Eye'), findsWidgets);
    expect(find.text('Fire King'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('a filter that excludes everything says so', (tester) async {
    await recordSeason(
      rounds: [
        (result: MatchResult.win, opponent: 'Fire King', onThePlay: true),
      ],
    );

    await openAnalytics(tester);
    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();

    expect(
      // EmptyState draws its title in caps.
      find.text('NO MATCHES MATCH THESE FILTERS'),
      findsOneWidget,
      reason: 'an empty database and an empty filter are different problems',
    );

    await unmount(tester);
  });

  test('casual matches never reach the analytics', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

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
        gamesWon: 2,
        gamesLost: 0,
      ),
    );

    final rows = await AnalyticsRepository(
      db,
    ).watchMatches(const AnalyticsFilter()).first;

    expect(
      rows,
      isEmpty,
      reason:
          'the section reports on tournaments, and a match outside one is '
          'not a tournament round',
    );
  });
}
