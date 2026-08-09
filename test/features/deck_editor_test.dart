import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  /// The archetype the tests file their decks under.
  ///
  /// One from the list the app ships with, because that is what the field
  /// offers: the archetype is chosen from a menu now, not typed.
  const archetype = 'Branded';

  Future<void> pickArchetype(WidgetTester tester, String name) async {
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

  /// [withArchetype] has to belong to the format the editor is on: the list is
  /// per format, and an Advanced archetype is not offered in Edison.
  Future<void> fillAndSave(
    WidgetTester tester,
    String name, {
    String withArchetype = archetype,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.pumpAndSettle();
    await pickArchetype(tester, withArchetype);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  /// Opens the archetype row, which is what the library actually lists.
  Future<void> openArchetype(
    WidgetTester tester, [
    String name = archetype,
  ]) async {
    await tester.tap(find.text(name).first);
    await tester.pumpAndSettle();
  }

  /// What actually reached the database, regardless of what the list shows.
  ///
  /// A one-shot query, not a stream: drift keeps its stream queries alive with
  /// a timer, and a widget test's fake clock never fires it, so awaiting
  /// `watch().first` inside a test body hangs forever.
  Future<List<String>> storedDeckNames() async {
    final decks = await harness.database.select(harness.database.decks).get();
    return [for (final deck in decks) deck.name];
  }

  testWidgets('a deck created for the other game is saved and visible', (
    tester,
  ) async {
    await openDecksTab(tester);
    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Magic: The Gathering'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'Izzet Prowess', withArchetype: 'Izzet Spells');

    expect(await storedDeckNames(), ['Izzet Prowess']);
    await openArchetype(tester, 'Izzet Spells');
    expect(
      find.text('Izzet Prowess'),
      findsOneWidget,
      reason:
          'a deck that disappears after saving looks exactly like a deck '
          'that failed to save',
    );

    await unmount(tester);
  });

  testWidgets('a deck saved while a format filter is active is still visible', (
    tester,
  ) async {
    await openDecksTab(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Edison'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'My Frogs', withArchetype: 'Frog Monarch');

    expect(await storedDeckNames(), ['My Frogs']);
    await openArchetype(tester, 'Frog Monarch');
    expect(find.text('My Frogs'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('saving twice in a row works', (tester) async {
    await openDecksTab(tester);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'First');

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'Second');

    expect(await storedDeckNames(), containsAll(['First', 'Second']));

    await unmount(tester);
  });

  testWidgets('every build of an archetype sits behind one row', (
    tester,
  ) async {
    await openDecksTab(tester);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'Snake-Eye Fire King');

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'Snake-Eye Unchained');

    expect(await storedDeckNames(), hasLength(2));
    expect(
      find.text(archetype),
      findsOneWidget,
      reason: 'two builds of one archetype, one row',
    );
    expect(find.textContaining('2 decks'), findsOneWidget);

    await openArchetype(tester);

    expect(find.text('Snake-Eye Fire King'), findsOneWidget);
    expect(find.text('Snake-Eye Unchained'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('adding a build from inside an archetype starts on it', (
    tester,
  ) async {
    await openDecksTab(tester);
    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'First build');

    await openArchetype(tester);
    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextField, archetype),
      findsOneWidget,
      reason: 'a build added from inside an archetype is one of its builds',
    );

    await unmount(tester);
  });

  testWidgets('format, name and archetype are the only required fields', (
    tester,
  ) async {
    await openDecksTab(tester);
    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    // Nothing else is touched: no colours, no photo, no decklist, no notes.
    await fillAndSave(tester, 'Bare Minimum');

    expect(await storedDeckNames(), ['Bare Minimum']);
    expect(
      find.text('Fill in the highlighted fields before saving.'),
      findsNothing,
    );

    await unmount(tester);
  });

  testWidgets('a save with nothing filled in says why', (tester) async {
    await openDecksTab(tester);
    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await storedDeckNames(), isEmpty);
    expect(
      find.text('Fill in the highlighted fields before saving.'),
      findsOneWidget,
      reason: 'a refused save that says nothing looks like a broken button',
    );

    await unmount(tester);
  });

  testWidgets('an edited deck saves its new name', (tester) async {
    await openDecksTab(tester);

    await tester.tap(find.text('New deck'));
    await tester.pumpAndSettle();
    await fillAndSave(tester, 'Before');

    await openArchetype(tester);
    await tester.tap(find.text('Before'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'After');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await storedDeckNames(), ['After']);

    await unmount(tester);
  });
}
