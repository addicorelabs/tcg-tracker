import 'dart:js_interop';

/// Reads `env(safe-area-inset-top)` off a probe element in `web/index.html`.
@JS('statusBarInset')
external double _measure();

/// The inset right now.
///
/// Not cached. It is zero until Safari has applied the `viewport-fit=cover` the
/// page patches into Flutter's own viewport tag, which can land a frame after
/// the app's first build, and it changes again when the phone is turned on its
/// side. `StatusBarScope` is what asks, and it asks more than once.
double get statusBarInset {
  try {
    return _measure();
  } catch (_) {
    // An index.html still in the browser's cache from before the probe existed.
    // Losing the inset leaves the old look, which is better than not starting.
    return 0;
  }
}
