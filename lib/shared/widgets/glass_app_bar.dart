import 'dart:ui';

import 'package:flutter/material.dart';

/// An app bar the page shows through.
///
/// Used with `extendBodyBehindAppBar: true`, so the content scrolls underneath
/// instead of stopping at a solid strip — the same idea as the floating
/// navigation bar at the other end of the screen.
///
/// The blur is not decoration. A title laid straight over moving cards and
/// numbers is unreadable the moment anything scrolls past it; blurring what is
/// behind keeps the letters legible without hiding the page. The tint on top of
/// it does the same job for the light theme, where a blur alone leaves too
/// little contrast.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({this.title, this.actions, super.key});

  final Widget? title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      title: title,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(
            color: colors.surface.withValues(alpha: 0.55),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
