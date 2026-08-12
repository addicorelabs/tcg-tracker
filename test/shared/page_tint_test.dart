import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/app/theme.dart';
import 'package:tcg_tracker/shared/layout/page_tint.dart';

void main() {
  test('the page takes the surface the app is built on', () {
    expect(pageTintCss(AppTheme.dark()), '#101017');
  });

  test('the light theme answers with a colour of its own', () {
    // Read rather than written out: the light scheme is generated from the seed
    // colour, so pinning the exact value here would break on a Material update
    // without anything actually being wrong. White is the point — a dark strip
    // over a white app is the whole complaint, in reverse.
    final css = pageTintCss(AppTheme.light());
    final rgb = int.parse(css.substring(1), radix: 16);
    final channels = [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF];

    expect(
      channels.every((channel) => channel > 0xF0),
      isTrue,
      reason: 'got $css, which nobody would call white',
    );
  });
}
