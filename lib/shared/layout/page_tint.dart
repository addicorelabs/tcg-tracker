import 'package:flutter/material.dart';

import 'page_tint_platform.dart';

/// Keeps the page behind the app the colour of the app's own background.
///
/// The status bar of an installed web app is painted by the page, not by the
/// app, and the app cannot reach up there — covering that strip is what broke
/// where taps landed. So it is coloured to match instead, and it matches on
/// every screen but the dashboard, whose banner is a colour of its own.
///
/// It does not follow the section, and could not: iOS reads the colour when the
/// app is launched and never looks again. Changing it while the app runs writes
/// to a page nobody is reading. The theme does survive that, because it is
/// restored from storage before the first frame.
void applyPageTint(ThemeData theme) {
  final css = pageTintCss(theme);
  if (css == _applied) return;
  _applied = css;
  setPageTint(css);
}

String? _applied;

/// The colour the page takes, as CSS: the surface the app is built on — the
/// deep grey in the dark theme, near white in the light one.
String pageTintCss(ThemeData theme) {
  final rgb = theme.scaffoldBackgroundColor.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
