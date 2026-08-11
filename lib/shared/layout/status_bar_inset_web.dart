import 'dart:js_interop';

/// Reads `env(safe-area-inset-top)` off a probe element in `web/index.html`.
///
/// A function rather than a value written once at startup: the inset only
/// resolves to anything once the viewport is declared `viewport-fit=cover`, and
/// Flutter Web injects that meta tag itself, after the page has been parsed.
@JS('statusBarInset')
external double _measure();

/// Measured once. The value cannot change while the app runs — a phone does not
/// grow a notch — and reading it means a layout flush in the browser.
final double _measured = _read();

double _read() {
  try {
    return _measure();
  } catch (_) {
    // An index.html still in the browser's cache from before the probe existed.
    // Losing the inset leaves the old look, which is better than not starting.
    return 0;
  }
}

double get statusBarInset => _measured;
