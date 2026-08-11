/// The height the platform keeps for its status bar above the app.
///
/// Installed to an iPhone home screen the app runs full-bleed, so the clock and
/// the battery sit over the first rows the app draws, and Flutter Web does not
/// report the inset that would push them clear: `MediaQuery.padding` is zero
/// there, whatever the device. The measurement therefore comes from the page
/// itself, where `env(safe-area-inset-top)` does work, and is handed back to the
/// app to use as the padding Flutter would otherwise have provided.
///
/// Zero everywhere else — in a browser tab, on desktop, and in tests — which is
/// also the right answer: nothing overlaps the app there.
library;

export 'status_bar_inset_none.dart'
    if (dart.library.js_interop) 'status_bar_inset_web.dart';
