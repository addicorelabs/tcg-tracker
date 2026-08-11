import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import 'page_tint_platform.dart';

/// Keeps the page behind the app the colour of whatever screen is on top of it.
///
/// The status bar of an installed web app is painted by the page, not by the
/// app, and the app cannot reach up there — covering that strip breaks where
/// taps land. So it is coloured to match instead: the banner's own purple on the
/// dashboard, the ordinary background everywhere else, which is what sits under
/// the title bar of every other screen.
///
/// Driven by the router rather than by the screens themselves. A screen that set
/// the colour on the way in and cleared it on the way out would fight the next
/// one, whose `initState` runs before the previous one's `dispose`.
class PageTint extends StatefulWidget {
  const PageTint({required this.router, required this.child, super.key});

  final GoRouter router;
  final Widget child;

  @override
  State<PageTint> createState() => _PageTintState();
}

class _PageTintState extends State<PageTint> {
  ThemeData? _theme;
  String? _applied;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_apply);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read here and kept, because [_apply] also runs from the router's
    // notification, which is not a build and must not look up an inherited
    // widget.
    _theme = Theme.of(context);
    _apply();
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_apply);
    super.dispose();
  }

  void _apply() {
    final theme = _theme;
    if (!mounted || theme == null) return;

    final location = widget.router.routerDelegate.currentConfiguration.uri.path;
    final color = location == AppRoute.home.path
        ? theme.appColors.heroGradient.first
        : theme.scaffoldBackgroundColor;

    final css = _css(color);
    if (css == _applied) return;
    _applied = css;
    setPageTint(css);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

String _css(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
