import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/app/routes.dart';
import 'package:tcg_tracker/app/theme.dart';
import 'package:tcg_tracker/shared/layout/page_tint.dart';

void main() {
  String tint(bool dark, AppRoute route) => pageTintCss(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    location: route.path,
  );

  test('the dashboard hands the page its own banner colour', () {
    expect(
      tint(true, AppRoute.home),
      '#2a1f52',
      reason: 'the first stop of the dark hero gradient',
    );
    expect(
      tint(false, AppRoute.home),
      '#6a5ae0',
      reason: 'and of the light one, which is a different violet',
    );
  });

  test('every other screen hands it the surface it is built on', () {
    for (final route in [
      AppRoute.tournaments,
      AppRoute.analytics,
      AppRoute.decks,
      AppRoute.settings,
    ]) {
      expect(tint(true, route), '#101017', reason: '${route.path}, dark');
      expect(
        tint(false, route),
        isNot('#101017'),
        reason:
            '${route.path}: the light theme has to answer differently, or the '
            'strip is a dark band over a white app',
      );
    }
  });

  test('the light surface is near white, not a tint of its own', () {
    // Read rather than written out: the light scheme is generated from the seed
    // colour, so pinning the exact value here would break on a Material update
    // without anything actually being wrong.
    final css = tint(false, AppRoute.settings);
    final rgb = int.parse(css.substring(1), radix: 16);
    final channels = [
      (rgb >> 16) & 0xFF,
      (rgb >> 8) & 0xFF,
      rgb & 0xFF,
    ];

    expect(
      channels.every((channel) => channel > 0xF0),
      isTrue,
      reason: 'got $css, which nobody would call white',
    );
  });
}
