import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'page_tint_platform.dart';

/// Keeps the page behind the app the colour of the section on top of it.
///
/// The status bar of an installed web app is painted by the page, not by the
/// app, and the app cannot reach up there — covering that strip breaks where
/// taps land. So it is coloured to match instead.
///
/// Called from `ShellScaffold.build`, which is the one widget that is rebuilt
/// both when the section changes and when the theme does. A listener on the
/// router would catch only the first, and a screen setting the colour on the
/// way in and clearing it on the way out would fight the next one, whose
/// `initState` runs before the previous one's `dispose`.
void applyPageTint({required ThemeData theme, required bool onDashboard}) {
  final css = pageTintCss(theme: theme, onDashboard: onDashboard);
  if (css == _applied) return;
  _applied = css;
  setPageTint(css);
}

String? _applied;

/// The colour the page takes under a section, as CSS.
///
/// Both colours come from the theme in force, so the light one is the light
/// app's: the banner's violet over the dashboard, and the surface the app is
/// built on — near white in the light theme, the deep grey in the dark one —
/// under every other section, which is what their title bar sits on.
String pageTintCss({required ThemeData theme, required bool onDashboard}) {
  final color = onDashboard
      ? theme.appColors.heroGradient.first
      : theme.scaffoldBackgroundColor;

  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
