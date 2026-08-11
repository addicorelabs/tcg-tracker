import 'package:flutter/material.dart';

import 'status_bar_inset.dart';

/// Hands the platform's status bar inset to the framework, once, at the top of
/// the app.
///
/// Below this everything is an ordinary `MediaQuery.padding.top`: `Scaffold`
/// makes the app bar taller by it, `AppBar` pushes its title below it, and
/// `SafeArea` keeps anything else clear. None of that happens on its own,
/// because Flutter Web reports no insets at all for an installed web app —
/// [statusBarInset] measures the page instead.
///
/// It is measured more than once. The value is zero until Safari has applied
/// the `viewport-fit=cover` the page patches into Flutter's viewport tag, which
/// can land a frame after the first build, and it changes again when the phone
/// is turned on its side — an iPhone has no top inset in landscape.
class StatusBarScope extends StatefulWidget {
  const StatusBarScope({required this.child, super.key});

  final Widget child;

  @override
  State<StatusBarScope> createState() => _StatusBarScopeState();
}

class _StatusBarScopeState extends State<StatusBarScope>
    with WidgetsBindingObserver {
  double _inset = statusBarInset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didChangeMetrics() => _measure();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final inset = statusBarInset;
    if (inset != _inset) setState(() => _inset = inset);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(top: _inset),
        viewPadding: media.viewPadding.copyWith(top: _inset),
      ),
      child: widget.child,
    );
  }
}
