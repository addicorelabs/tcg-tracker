/// Paints the page behind the app.
///
/// Installed to an iPhone home screen, the strips the app itself never reaches
/// — the status bar at the top, the overscroll rubber band at either end — are
/// painted with the background of `<body>`, not with `theme-color` and not with
/// anything Flutter draws. Left alone that is one flat colour under every
/// screen, which reads as a band stuck to the top of the app.
///
/// Nothing off the web, where the app has no page under it.
library;

export 'page_tint_none.dart'
    if (dart.library.js_interop) 'page_tint_web.dart';
