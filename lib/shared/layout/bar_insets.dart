import 'package:flutter/material.dart';

import 'status_bar_inset.dart';

/// The two bars the app draws over its content, and the room they need.
///
/// Both ends of every screen work the same way: the bar is painted on top of
/// the body rather than beside it, so the app carries on behind it, and the
/// screen has to leave the room itself.
///
/// Geometry of the floating navigation bar drawn by `ShellScaffold`.
///
/// The bar floats over the body rather than sitting beside it, so that the app
/// carries on behind and around the pill. Nothing is reserved for it in the
/// layout, which means every screen has to leave [FloatingBar.inset] clear at
/// the bottom itself — miss it on one screen and the last row of that list ends
/// up under the bar, unreadable and untappable.
///
/// The numbers are constants rather than something read back through
/// `MediaQuery`, even though `extendBody: true` does publish the height that
/// way. A `Scaffold` strips bottom padding from its floating-action-button
/// slot, so a button — the single thing most likely to end up under the bar —
/// could never see the value. One source that works everywhere beats two that
/// disagree in the one place it matters.
///
/// Nothing here follows the system's own bottom inset. Installed to an iPhone
/// home screen, which is what this app is, Flutter Web reports no insets at
/// all; [FloatingBar.bottomMargin] is the gap that keeps the pill off the home
/// indicator.
abstract final class FloatingBar {
  /// Height of the pill itself. The navigation bar theme is set from this.
  static const height = 72.0;

  /// Gap between the pill and the sides of the screen.
  static const sideMargin = 24.0;

  /// Gap between the pill and the bottom of the screen.
  static const bottomMargin = 28.0;

  /// Room the bar takes at the bottom of a screen.
  static const inset = height + bottomMargin;
}

/// Room the app bar needs at the top of a screen.
///
/// A `Scaffold` built with `extendBodyBehindAppBar: true` does publish this
/// through `MediaQuery`, and reading it back that way still would not work: it
/// publishes it *inside* the body, while a `ListView(padding: ...)` is built
/// outside, from the context of the widget holding the `Scaffold`. The value
/// that arrives there is the one from before the bar, which is zero.
///
/// The bar is the standard toolbar height, plus whatever the platform keeps for
/// its status bar above it: installed to an iPhone home screen the app runs
/// under the clock, and [statusBarInset] is the room the `Scaffold` gives the
/// bar to stay clear of it. In a browser tab that term is zero.
abstract final class TopBar {
  static double get inset => kToolbarHeight + statusBarInset;
}

extension BarPadding on EdgeInsets {
  /// This padding, with room for the floating navigation bar underneath it.
  EdgeInsets get clearingFloatingBar =>
      this + const EdgeInsets.only(bottom: FloatingBar.inset);

  /// This padding, with room for the app bar above it.
  EdgeInsets get clearingAppBar => this + EdgeInsets.only(top: TopBar.inset);
}

/// Wraps a floating action button so it clears the floating navigation bar.
///
/// The padding is part of what the `Scaffold` measures when it places the
/// button, so growing the button's box is the same as lifting the button.
class LiftedFab extends StatelessWidget {
  const LiftedFab({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FloatingBar.inset),
      child: child,
    );
  }
}
