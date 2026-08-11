import 'dart:js_interop';

/// Sets the background of `<body>`, defined in `web/index.html`.
@JS('setPageTint')
external void _setPageTint(String css);

void setPageTint(String css) {
  try {
    _setPageTint(css);
  } catch (_) {
    // An index.html still in the browser's cache from before this existed. The
    // page keeps the colour it was served with, which is the old look.
  }
}
