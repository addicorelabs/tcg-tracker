import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/app/theme.dart';
import 'package:tcg_tracker/shared/layout/page_tint.dart';

void main() {
  String tint({required bool dark, required bool onDashboard}) => pageTintCss(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    onDashboard: onDashboard,
  );

  test('the dashboard hands the page its own banner colour', () {
    expect(
      tint(dark: true, onDashboard: true),
      '#2a1f52',
      reason: 'the first stop of the dark hero gradient',
    );
    expect(
      tint(dark: false, onDashboard: true),
      '#6a5ae0',
      reason: 'and of the light one, which is a different violet',
    );
  });

  test('every other section hands it the surface it is built on', () {
    expect(tint(dark: true, onDashboard: false), '#101017');
    expect(
      tint(dark: false, onDashboard: false),
      isNot('#101017'),
      reason:
          'the light theme has to answer differently, or the strip is a dark '
          'band over a white app',
    );
  });

  test('the light surface is near white, not a tint of its own', () {
    // Read rather than written out: the light scheme is generated from the seed
    // colour, so pinning the exact value here would break on a Material update
    // without anything actually being wrong.
    final css = tint(dark: false, onDashboard: false);
    final rgb = int.parse(css.substring(1), radix: 16);
    final channels = [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF];

    expect(
      channels.every((channel) => channel > 0xF0),
      isTrue,
      reason: 'got $css, which nobody would call white',
    );
  });
}
