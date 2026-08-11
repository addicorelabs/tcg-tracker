import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/tournaments/event_options.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';
import 'package:tcg_tracker/shared/widgets/number_stepper.dart';

import '../helpers/app_harness.dart';

void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await AppHarness.create();
  });

  Future<void> openTournamentsTab(WidgetTester tester) async {
    setSurfaceSize(tester, phoneSize);
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.emoji_events_outlined).last);
    await tester.pumpAndSettle();
  }

  Future<void> createDeck({
    String gameId = Seed.yugiohId,
    String formatId = 'ygo-advanced',
    String name = 'Snake-Eye',
    String? archetype,
  }) async {
    await DeckRepository(harness.database).createDeck(
      gameId: gameId,
      formatId: formatId,
      name: name,
      archetype: archetype ?? name,
    );
  }

  /// A deck for each game, for the tests that switch between them.
  ///
  /// The editor hides the whole form when the chosen game and format have no
  /// deck, so without this a switch to Magic would replace the chips with an
  /// empty state and the test would be asserting on the wrong screen. The
  /// Magic deck is in Standard because that is the format the editor lands on.
  Future<void> createDeckForBothGames() async {
    await createDeck();
    await createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-standard',
      name: 'Izzet Prowess',
    );
  }

  /// Fills in the tournament editor and saves.
  ///
  /// The event type is picked explicitly because it has no default: the form
  /// refuses to save until the user says what kind of event this was.
  Future<void> createTournament(
    WidgetTester tester, {
    String name = 'Locals',
    String eventType = 'OTS',
  }) async {
    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tapClearOfBars(tester, find.widgetWithText(ChoiceChip, eventType));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  /// Picks the opponent's deck from the controlled menu.
  ///
  /// The name is typed before it is tapped, exactly as it has to be in the
  /// app: the shipped list runs to dozens of archetypes per format, so the one
  /// being looked for is usually far below the fold until the filter narrows
  /// the list.
  ///
  /// The entry is the last match of that name in the tree: the menu opens into
  /// an overlay, and the screens underneath are still mounted and may well show
  /// the same archetype.
  Future<void> pickOpponentDeck(WidgetTester tester, String name) async {
    final menu = find.byType(DropdownMenu<String>);

    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: menu, matching: find.byType(TextField)),
      name,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  /// Records a round from the tournament detail screen.
  ///
  /// The game counters sit below the fold on a phone, so each one is scrolled
  /// into view and then addressed through its own row rather than by a global
  /// index: tapping a stray plus at the bottom of the screen would hit the
  /// navigation bar instead.
  Future<void> recordRound(
    WidgetTester tester, {
    int won = 0,
    int lost = 0,
    bool isBye = false,
    String opponentDeck = 'Snake-Eye',
    // For a save that was refused: the editor is still up with its opponent
    // already chosen, and only the counters need touching.
    bool alreadyOpen = false,
  }) async {
    Future<void> bump(String label, int times) async {
      if (times == 0) return;

      // Several branches of the shell stay alive at once, so the scrollable
      // has to be named rather than guessed: this one is the round editor's,
      // identified by the only "GAMES" heading in the app.
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find
            .ancestor(of: find.text('GAMES'), matching: find.byType(Scrollable))
            .first,
      );
      await tester.pumpAndSettle();

      final row = find
          .ancestor(of: find.text(label), matching: find.byType(Row))
          .first;

      for (var i = 0; i < times; i++) {
        await tester.tap(
          find.descendant(of: row, matching: find.byIcon(Icons.add)),
        );
        await tester.pump();
      }
    }

    if (!alreadyOpen) {
      await tester.tap(find.text('New round'));
      await tester.pumpAndSettle();
    }

    if (isBye) {
      await tester.tap(find.text('This round was a bye'));
      await tester.pumpAndSettle();
    } else {
      if (!alreadyOpen) await pickOpponentDeck(tester, opponentDeck);
      await bump('Won', won);
      await bump('Lost', lost);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('an empty tournament list explains what to do', (tester) async {
    await openTournamentsTab(tester);

    expect(find.text('NO TOURNAMENTS YET'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a tournament cannot be recorded without a deck', (tester) async {
    await openTournamentsTab(tester);

    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();

    expect(find.text('ADD A DECK FIRST'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Save'))
          .onPressed,
      isNull,
      reason: 'saving is disabled while there is no deck to choose',
    );

    await unmount(tester);
  });

  testWidgets('recording a tournament opens it ready for round one', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);

    await createTournament(tester);

    expect(find.text('Locals'), findsOneWidget);
    expect(find.text('NO ROUNDS RECORDED'), findsOneWidget);
    expect(find.text('New round'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the record is built from the rounds as they are recorded', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);

    await createTournament(tester);

    await recordRound(tester, won: 2);
    expect(find.text('1-0'), findsOneWidget);

    await recordRound(tester, lost: 2);
    expect(find.text('1-1'), findsOneWidget);
    expect(find.text('Round 2'.toUpperCase()), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a bye lands in the record but never in the winrate', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);

    await createTournament(tester);

    await recordRound(tester, won: 2);
    await recordRound(tester, isBye: true);

    expect(
      find.text('1-0'),
      findsOneWidget,
      reason: 'the bye is not a win, so the record stays 1-0',
    );
    expect(find.text('1 bye'), findsOneWidget);
    expect(find.text('BYE'), findsOneWidget);
    expect(
      find.text('6'),
      findsOneWidget,
      reason: 'the bye scores 3 points like a win, on top of the win itself',
    );

    await unmount(tester);
  });

  testWidgets('the event types on offer are the ones the game actually runs', (
    tester,
  ) async {
    await createDeckForBothGames();
    await openTournamentsTab(tester);

    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'OTS'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'YCS'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Continental'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'PTQ'), findsNothing);

    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'PTQ'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Showdown'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'OTS'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'YCS'), findsNothing);

    await unmount(tester);
  });

  testWidgets('the deck is chosen archetype first, then build', (tester) async {
    await createDeck(name: 'Snake-Eye Fire King', archetype: 'Snake-Eye');
    await createDeck(name: 'Snake-Eye Bystial', archetype: 'Snake-Eye');
    await createDeck(name: 'Yubel Unchained', archetype: 'Yubel');

    await openTournamentsTab(tester);
    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();

    // Format, then archetype, then the build within it.
    final fields = find.byType(DropdownButtonFormField<String>);

    await tester.tap(fields.at(2));
    await tester.pumpAndSettle();

    expect(find.text('Snake-Eye Fire King'), findsWidgets);
    expect(
      find.text('Yubel Unchained'),
      findsNothing,
      reason: 'the deck menu is limited to builds of the chosen archetype',
    );

    await tester.tap(find.text('Snake-Eye Fire King').last);
    await tester.pumpAndSettle();

    await tester.tap(fields.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yubel').last);
    await tester.pumpAndSettle();

    await tester.tap(fields.at(2));
    await tester.pumpAndSettle();

    expect(
      find.text('Yubel Unchained'),
      findsWidgets,
      reason: 'changing archetype changes what the deck menu offers',
    );
    expect(find.text('Snake-Eye Fire King'), findsNothing);

    await unmount(tester);
  });

  testWidgets('switching game drops an event type the new one does not run', (
    tester,
  ) async {
    await createDeckForBothGames();
    await openTournamentsTab(tester);

    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();
    await tapClearOfBars(tester, find.widgetWithText(ChoiceChip, 'OTS'));

    // Reaching the event types scrolled the game buttons off the top, and a
    // form this long unmounts what it scrolls past. Back to the top rather than
    // `dragUntilVisible`, which stops as soon as the target is mounted and
    // leaves it behind the app bar, where a tap does not reach it.
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Store event');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The message sits at the field it belongs to, which is below the fold and
    // therefore not in the tree until it is scrolled to.
    await tester.dragUntilVisible(
      find.text('Required'),
      find.byType(ListView),
      const Offset(0, -120),
    );

    expect(
      find.text('Required'),
      findsOneWidget,
      reason: 'the OTS choice did not survive the switch, so one is needed',
    );

    await unmount(tester);
  });

  testWidgets('a round will not save without the opponent deck', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    await tester.tap(find.text('New round'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    expect(
      await harness.database.select(harness.database.matches).get(),
      isEmpty,
      reason: 'the round was refused, so nothing was written',
    );

    await unmount(tester);
  });

  testWidgets('the round counter stops at the tournament\'s last round', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    final tournament =
        (await harness.database.select(harness.database.tournaments).get())
            .single;

    final cap = EventOptions.maxRounds(
      roundsPlanned: tournament.roundsPlanned,
      hasTopCut: tournament.hasTopCut,
      topCutSize: tournament.topCutSize,
    );

    await tester.tap(find.text('New round'));
    await tester.pumpAndSettle();

    // The first stepper on the screen is the round number; the others count
    // games, and are further down.
    final rounds = find.byType(NumberStepper).first;
    final plus = find.descendant(of: rounds, matching: find.byIcon(Icons.add));

    for (var i = 0; i < cap + 5; i++) {
      await tester.tap(plus);
      await tester.pump();
    }

    expect(
      find.descendant(of: rounds, matching: find.text('$cap')),
      findsOneWidget,
      reason:
          'a round past the end of the tournament is a typo every time, and '
          'one that quietly distorts everything computed from it',
    );

    await unmount(tester);
  });

  testWidgets(
    'a tournament names the archetype of the deck it was played with',
    (tester) async {
      await createDeck(name: 'Prova', archetype: 'Snake-Eye');
      await openTournamentsTab(tester);
      await createTournament(tester);

      expect(find.text('Prova'), findsOneWidget);
      expect(
        find.text('Snake-Eye'),
        findsOneWidget,
        reason:
            'the deck name alone does not say what was played, and two builds '
            'often share one',
      );

      await unmount(tester);
    },
  );

  testWidgets('a Yu-Gi-Oh! round cannot be recorded level', (tester) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    await recordRound(tester, won: 1, lost: 1);

    expect(
      find.text('Drawn'),
      findsNothing,
      reason: 'a game with no draws has no use for the row',
    );
    expect(
      find.textContaining('cannot end level'),
      findsOneWidget,
      reason: 'the result follows from the games, so a level score is refused',
    );
    expect(
      await harness.database.select(harness.database.matches).get(),
      isEmpty,
      reason: 'the round was refused, so nothing was written',
    );

    // The editor is still open, so the score can be put right without losing
    // the opponent that was already picked.
    await recordRound(tester, won: 1, alreadyOpen: true);

    expect(find.text('1-0'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a bye needs no opponent deck', (tester) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    await recordRound(tester, isBye: true);

    expect(find.text('BYE'), findsOneWidget);
    expect(find.text('Required'), findsNothing);

    await unmount(tester);
  });

  testWidgets('the opponent deck menu offers the archetypes of own decks', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    await tester.tap(find.text('New round'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();

    expect(
      find.text('Snake-Eye'),
      findsWidgets,
      reason: 'an archetype from the deck library is offered as an opponent',
    );
    expect(
      find.text('Snake-Eye Fire King'),
      findsWidgets,
      reason: 'so is one from the list the app ships with',
    );

    await unmount(tester);
  });

  testWidgets('an archetype nobody has faced yet can be added on the spot', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);
    await createTournament(tester);

    await tester.tap(find.text('New round'));
    await tester.pumpAndSettle();

    // The button beside the menu, not an entry inside it: with dozens of
    // archetypes on the list, a last entry would be a long scroll away and
    // hidden by the filter exactly when it is needed.
    await tester.tap(find.byTooltip('New archetype'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Fiendsmith');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final stored = await harness.database
        .select(harness.database.opponentArchetypes)
        .get();

    expect(
      [for (final archetype in stored) archetype.name],
      contains('Fiendsmith'),
      reason: 'the new archetype is saved at once, not only with the round',
    );

    await unmount(tester);
  });

  testWidgets('a tournament will not save without an event type', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);

    await tester.tap(find.text('New tournament'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Locals');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Required'),
      findsOneWidget,
      reason: 'the refusal is shown at the field, not only in a snackbar',
    );
    expect(find.text('NO ROUNDS RECORDED'), findsNothing);

    await unmount(tester);
  });

  testWidgets('finishing a tournament takes it off the dashboard', (
    tester,
  ) async {
    await createDeck();
    await openTournamentsTab(tester);

    await createTournament(tester);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Locals'), findsOneWidget);
    expect(find.text('RECORD ROUND'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.emoji_events_outlined).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Locals'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish tournament'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Finish tournament'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.text('No tournament in progress'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the format filter sits between the games and the statuses', (
    tester,
  ) async {
    await openTournamentsTab(tester);

    expect(
      find.text('Advanced'),
      findsNothing,
      reason:
          'a format belongs to a game, so it has nothing to say until one '
          'is chosen',
    );

    await tester.tap(find.text('Yu-Gi-Oh!'));
    await tester.pumpAndSettle();

    final games = tester.getCenter(find.text('Yu-Gi-Oh!')).dy;
    final formats = tester.getCenter(find.text('Advanced')).dy;
    final statuses = tester.getCenter(find.text('Planned')).dy;

    expect(
      formats,
      greaterThan(games),
      reason: 'the format row belongs below the games, on its own line',
    );
    expect(formats, lessThan(statuses));

    await unmount(tester);
  });
}
