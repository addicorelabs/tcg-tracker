import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/data/db/seed.dart';
import 'package:tcg_tracker/data/repositories/deck_repository.dart';

import '../helpers/app_harness.dart';

void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await AppHarness.create();
  });

  Future<void> openDecksTab(WidgetTester tester) async {
    setSurfaceSize(tester, phoneSize);
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.style_outlined).first);
    await tester.pumpAndSettle();
  }

  /// Opens the archetype whose row is on the library screen.
  ///
  /// The library lists archetypes, not decks: the individual builds only exist
  /// one level down.
  Future<void> openArchetype(WidgetTester tester, String archetype) async {
    await tester.tap(find.text(archetype).first);
    await tester.pumpAndSettle();
  }

  testWidgets('a library with no decks still shows the archetypes', (
    tester,
  ) async {
    await openDecksTab(tester);

    expect(
      // First alphabetically, so it is on screen without scrolling.
      find.text('Artmage'),
      findsOneWidget,
      reason: 'the shipped catalogue is what a new deck gets filed under',
    );
    // The subtitle carries the format alongside it, so the row reads
    // "No deck yet · Advanced".
    expect(find.textContaining('No deck yet'), findsWidgets);

    await unmount(tester);
  });

  testWidgets('creating a deck puts it in the list', (tester) async {
    await openDecksTab(tester);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    // The name is a plain field, addressed by position because a SectionLabel
    // labels it rather than an InputDecoration. The archetype is a menu.
    await tester.enterText(find.byType(TextFormField).at(0), 'My Branded');
    await tester.pumpAndSettle();

    final menu = find.byType(DropdownMenu<String>);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: menu, matching: find.byType(TextField)),
      'Branded',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Branded').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 deck'),
      findsOneWidget,
      reason: 'the library lists the archetype, with its builds counted',
    );
    expect(
      find.text('My Branded'),
      findsNothing,
      reason: 'the build is one level down',
    );

    await openArchetype(tester, 'Branded');

    expect(find.text('My Branded'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Card), matching: find.text('Advanced')),
      findsOneWidget,
      reason: 'the deck carries the format',
    );

    await unmount(tester);
  });

  testWidgets('the archetypes you play come before the rest', (tester) async {
    // Last alphabetically of the shipped Advanced list, so if it appears above
    // the first of them it can only be because having a deck put it there.
    await DeckRepository(harness.database).createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      name: 'My Yummy',
      archetype: 'Yummy',
    );

    await openDecksTab(tester);

    expect(
      tester.getCenter(find.text('Yummy')).dy,
      lessThan(tester.getCenter(find.text('Artmage')).dy),
      reason:
          'the deck being worked on this week belongs at the top, not '
          'buried in a catalogue of two hundred',
    );

    await unmount(tester);
  });

  testWidgets('an archetype with no deck yet opens ready to take one', (
    tester,
  ) async {
    await openDecksTab(tester);
    await openArchetype(tester, 'Artmage');

    expect(find.text('NO DECKS YET'), findsOneWidget);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextField, 'Artmage'),
      findsOneWidget,
      reason: 'an empty archetype is exactly where its first build gets filed',
    );

    await unmount(tester);
  });

  testWidgets('a deck is not saved without a name', (tester) async {
    await openDecksTab(tester);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsNWidgets(2));
    expect(
      find.text('New deck'),
      findsOneWidget,
      reason: 'the editor stays open when the form is invalid',
    );

    await unmount(tester);
  });

  testWidgets('archived decks leave the list until asked for', (tester) async {
    await DeckRepository(harness.database).createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      name: 'Snake-Eye',
      archetype: 'Snake-Eye',
    );

    await openDecksTab(tester);
    await openArchetype(tester, 'Snake-Eye');

    await tester.tap(
      find.descendant(
        of: find.byType(Card),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(
      find.text('NO DECKS YET'),
      findsOneWidget,
      reason: 'the archived deck leaves the archetype it was the only build of',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show archived'));
    await tester.pumpAndSettle();

    await openArchetype(tester, 'Snake-Eye');

    expect(find.textContaining('Archived'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the format filter narrows the list', (tester) async {
    final repository = DeckRepository(harness.database);
    await repository.createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-advanced',
      name: 'Snake-Eye',
      archetype: 'Snake-Eye',
    );
    await repository.createDeck(
      gameId: Seed.yugiohId,
      formatId: 'ygo-edison',
      name: 'Frog Monarch',
      archetype: 'Monarch',
    );

    await openDecksTab(tester);
    expect(find.text('Snake-Eye'), findsOneWidget);
    expect(find.text('Monarch'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Edison'));
    await tester.pumpAndSettle();

    expect(find.text('Snake-Eye'), findsNothing);
    expect(find.text('Monarch'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('switching game clears the format filter', (tester) async {
    await openDecksTab(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Edison'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();

    final all = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'All'),
    );
    expect(
      all.selected,
      isTrue,
      reason: 'an Edison filter means nothing in a Magic list',
    );
    expect(find.widgetWithText(ChoiceChip, 'Modern'), findsOneWidget);

    await unmount(tester);
  });
}
