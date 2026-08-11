import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/catalog_repository.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/app_harness.dart';

void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await AppHarness.create();
  });

  Future<void> openCatalog(WidgetTester tester) async {
    setSurfaceSize(tester, phoneSize);
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await tester.pumpAndSettle();

    // The row is at the bottom of a long settings page, so it is built but off
    // screen: `ensureVisible` scrolls to it, `scrollUntilVisible` would not,
    // having already found it.
    final row = find.text('Manage games and formats');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  /// Opens the row menu of [entry] and picks [action].
  Future<void> chooseAction(
    WidgetTester tester,
    String entry,
    String action,
  ) async {
    final menu = find.descendant(
      of: find.ancestor(of: find.text(entry), matching: find.byType(ListTile)),
      matching: find.byIcon(Icons.more_vert),
    );

    await tapClearOfBars(tester, menu);
    await tester.tap(find.text(action).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapAndType(
    WidgetTester tester,
    Finder button,
    String name,
  ) async {
    await tapClearOfBars(tester, button);

    await tester.enterText(find.byType(TextField).last, name);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  /// The "New format" row of the last game card, which is the one just added.
  final lastAddFormat = find.text('New format').last;

  testWidgets('the list shows hidden entries, which the menus do not', (
    tester,
  ) async {
    await CatalogRepository(
      harness.database,
    ).setFormatActive('mtg-pauper', isActive: false);

    await openCatalog(tester);

    expect(find.text('Pauper'), findsOneWidget);
    expect(
      find.text('Hidden'),
      findsOneWidget,
      reason: 'this is the only screen a hidden entry can be brought back on',
    );
    expect(
      find.text('Built in'),
      findsNWidgets(Seed.games.length + Seed.formats.length),
      reason: 'both shipped games and every shipped format are marked as one',
    );

    await unmount(tester);
  });

  testWidgets('a new game arrives with no formats and takes the ones it is '
      'given', (tester) async {
    await openCatalog(tester);

    await tapAndType(tester, find.text('New game'), 'Pokémon');

    expect(find.text('Pokémon'), findsOneWidget);
    expect(
      find.text('No formats yet. Add the first one below.'),
      findsOneWidget,
      reason: 'the app knows nothing about this game, so it guesses no formats',
    );

    await tapAndType(tester, lastAddFormat, 'Standard 2026');

    expect(find.text('Standard 2026'), findsOneWidget);
    expect(find.text('No formats yet. Add the first one below.'), findsNothing);

    await unmount(tester);
  });

  testWidgets('a new game is offered when creating a deck', (tester) async {
    await openCatalog(tester);
    await tapAndType(tester, find.text('New game'), 'Pokémon');
    await tapAndType(tester, lastAddFormat, 'Standard 2026');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.style_outlined).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pokémon').first);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ChoiceChip, 'Standard 2026'),
      findsOneWidget,
      reason: 'a game the user added is a game like the two that ship',
    );

    await unmount(tester);
  });

  testWidgets('a duplicate format name is refused', (tester) async {
    await openCatalog(tester);

    final magicAdd = find.text('New format').at(1);
    await tapAndType(tester, magicAdd, '  modern  ');

    expect(
      find.text('This game already has a format with that name.'),
      findsOneWidget,
      reason: 'two formats called Modern would be two of everything',
    );

    await unmount(tester);
  });

  testWidgets('hiding a format keeps the decks in it readable', (tester) async {
    await DeckRepository(harness.database).createDeck(
      gameId: Seed.magicId,
      formatId: 'mtg-pauper',
      name: 'Familiars',
      archetype: 'Familiars',
    );

    await openCatalog(tester);
    await chooseAction(tester, 'Pauper', 'Hide');

    expect(find.text('Hidden'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.style_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ChoiceChip, 'Pauper'),
      findsNothing,
      reason: 'a hidden format leaves the filters',
    );

    await tester.tap(find.text('Familiars').first);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Card), matching: find.text('Pauper')),
      findsOneWidget,
      reason: 'the deck still says which format it was built for',
    );

    await unmount(tester);
  });

  testWidgets('hiding a game moves the library onto one that is visible', (
    tester,
  ) async {
    await openCatalog(tester);
    await chooseAction(tester, 'Yu-Gi-Oh!', 'Hide');
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.style_outlined).first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Modern'), findsOneWidget);
    expect(
      find.widgetWithText(ChoiceChip, 'Edison'),
      findsNothing,
      reason:
          'the library falls onto a visible game rather than showing '
          'nothing with no chip to move off',
    );

    await unmount(tester);
  });

  testWidgets('the last visible game cannot be hidden', (tester) async {
    await openCatalog(tester);
    await chooseAction(tester, 'Yu-Gi-Oh!', 'Hide');
    await chooseAction(tester, 'Magic: The Gathering', 'Hide');

    expect(
      find.text('At least one game has to stay visible.'),
      findsOneWidget,
      reason: 'with no game left, no deck and no tournament could be created',
    );
    expect(find.text('Hidden'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a built-in game cannot be deleted', (tester) async {
    await openCatalog(tester);
    await chooseAction(tester, 'Yu-Gi-Oh!', 'Delete');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Built-in entries cannot be deleted. Hide it instead.'),
      findsOneWidget,
    );
    expect(find.text('Yu-Gi-Oh!'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('deleting a format with history is refused, with a reason', (
    tester,
  ) async {
    final format = await CatalogRepository(
      harness.database,
    ).addFormat(gameId: Seed.magicId, name: 'Commander');
    await DeckRepository(harness.database).createDeck(
      gameId: Seed.magicId,
      formatId: format.id,
      name: 'Atraxa',
      archetype: 'Atraxa',
    );

    await openCatalog(tester);
    await chooseAction(tester, 'Commander', 'Delete');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(
      find.text('This has decks or tournaments in it. Hide it instead.'),
      findsOneWidget,
    );
    expect(find.text('Commander'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('an unused game can be deleted, formats and all', (tester) async {
    final game = await CatalogRepository(
      harness.database,
    ).addGame(name: 'Pokémon');
    await CatalogRepository(
      harness.database,
    ).addFormat(gameId: game.id, name: 'Standard 2026');

    await openCatalog(tester);
    await chooseAction(tester, 'Pokémon', 'Delete');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Pokémon'), findsNothing);
    expect(find.text('Standard 2026'), findsNothing);

    // Read back with a one-shot query: a Drift stream never completes inside a
    // widget test, whose clock does not run the timer keeping it alive.
    final formats = await harness.database
        .select(harness.database.formats)
        .get();
    expect(formats.map((f) => f.gameId), isNot(contains(game.id)));

    await unmount(tester);
  });
}
