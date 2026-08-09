import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

void main() {
  late AppHarness harness;

  setUp(() async {
    harness = await AppHarness.create();
  });

  Future<void> openSettings(WidgetTester tester) async {
    setSurfaceSize(tester, phoneSize);
    await tester.pumpWidget(harness.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await tester.pumpAndSettle();
  }

  /// The account row, addressed by its title.
  ///
  /// Not by its chevron: the formats row has one too, and which of the two
  /// comes first on the screen is not what these tests are about.
  final accountRow = find.ancestor(
    of: find.text('Account and sync'),
    matching: find.byType(ListTile),
  );

  testWidgets('settings leads to the account screen', (tester) async {
    await openSettings(tester);

    expect(
      find.text('Account and sync'),
      findsWidgets,
      reason: 'the sync state belongs where it can be seen without hunting',
    );

    await tester.tap(accountRow);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a build without credentials says so instead of failing', (
    tester,
  ) async {
    await openSettings(tester);
    await tester.tap(accountRow);
    await tester.pumpAndSettle();

    expect(find.text('Sync is not set up in this build'), findsOneWidget);
    expect(
      find.text('Sign in'),
      findsNothing,
      reason: 'a form that could only ever fail is worse than an explanation',
    );

    await unmount(tester);
  });
}
