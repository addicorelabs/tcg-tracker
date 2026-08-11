import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcg_tracker/app/app.dart';
import 'package:tcg_tracker/data/db/app_database.dart';
import 'package:tcg_tracker/data/db/database_provider.dart';
import 'package:tcg_tracker/features/settings/providers/app_settings_provider.dart';
import 'package:tcg_tracker/shared/layout/floating_bar_inset.dart';

import 'test_database.dart';

/// The app wired to throwaway storage, for widget tests.
class AppHarness {
  AppHarness._(this.prefs, this.database);

  final SharedPreferences prefs;
  final AppDatabase database;

  /// Creates a harness and registers its teardown.
  static Future<AppHarness> create() async {
    SharedPreferences.setMockInitialValues({});
    final harness = AppHarness._(
      await SharedPreferences.getInstance(),
      createTestDatabase(),
    );
    addTearDown(harness.database.close);
    return harness;
  }

  Widget get app => ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(database),
    ],
    child: const TcgTrackerApp(),
  );
}

/// Pins the test surface to a phone or a desktop size.
///
/// The shell swaps between a bottom bar and a side rail at 800 logical pixels,
/// and the default 800x600 test surface sits exactly on that breakpoint, so
/// every test has to pick a side explicitly.
void setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

const phoneSize = Size(400, 800);
const desktopSize = Size(1200, 800);

/// Tears the app down inside the test body.
///
/// Drift keeps a short-lived timer running after the last listener of a stream
/// query goes away, which the test framework would otherwise report as a
/// pending timer. Unmounting and letting the clock run drains it.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

/// Taps something that may be sitting under the floating navigation bar.
///
/// The bar is drawn over the body, so a widget can be well inside the viewport
/// and still be covered: `ensureVisible` is satisfied by the first condition
/// and blind to the second, and `tap` then lands on the bar instead. This
/// scrolls the last [FloatingBar.inset] pixels out of the way as well.
///
/// Use it for anything low on a scrolling screen. A plain `tap` that has worked
/// for months will start missing the moment a field is added above the target.
Future<void> tapClearOfNavBar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();

  final view = tester.view;
  final screenBottom = view.physicalSize.height / view.devicePixelRatio;
  final clearance = screenBottom - FloatingBar.inset - 8;
  final bottom = tester.getBottomLeft(finder).dy;

  if (bottom > clearance) {
    await tester.drag(finder, Offset(0, clearance - bottom));
    await tester.pumpAndSettle();
  }

  await tester.tap(finder);
  await tester.pumpAndSettle();
}
