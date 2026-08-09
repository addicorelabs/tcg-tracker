import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await AppHarness.create();
  });

  testWidgets('opens on the dashboard with both creation actions', (
    tester,
  ) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    // The quick actions are rendered in uppercase by the dashboard.
    expect(find.text('NEW TOURNAMENT'), findsOneWidget);
    expect(find.text('NEW MATCH'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('narrow layout shows five bottom destinations', (tester) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
      hasLength(5),
    );

    await unmount(tester);
  });

  testWidgets('wide layout shows the side rail instead', (tester) async {
    setSurfaceSize(tester, desktopSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).destinations,
      hasLength(5),
    );

    await unmount(tester);
  });

  testWidgets('creation flows keep the navigation bar on screen', (
    tester,
  ) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    for (final action in ['NEW TOURNAMENT', 'NEW MATCH']) {
      // The dashboard scrolls on a phone-sized screen, so the second button
      // starts below the fold.
      await tester.ensureVisible(find.text(action));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(
        find.byType(NavigationBar),
        findsOneWidget,
        reason: '$action must not cover the navigation bar',
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }

    expect(find.text('NEW TOURNAMENT'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('switching to the settings tab shows language and theme', (
    tester,
  ) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('settings lists the formats seeded into the database', (
    tester,
  ) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Legacy'), 200);

    for (final format in ['Edison', 'Standard', 'Modern', 'Pauper', 'Legacy']) {
      expect(find.text(format), findsOneWidget);
    }
    // Shown translated, unlike every other format name.
    expect(find.text('Advanced'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('choosing Italian translates the interface', (tester) async {
    setSurfaceSize(tester, phoneSize);

    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italiano').last);
    await tester.pumpAndSettle();

    expect(find.text('Lingua'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    // Appears twice: the app bar title and the navigation destination label.
    expect(find.text('Impostazioni'), findsNWidgets(2));

    await unmount(tester);
  });
}
