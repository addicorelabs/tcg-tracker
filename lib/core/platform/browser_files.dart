/// Moving files between the app and the user's device.
///
/// The implementation is picked at compile time: the browser one is the real
/// one, the stub exists so the code still compiles under the Dart VM, which is
/// where the tests run.
library;

export 'browser_files_stub.dart'
    if (dart.library.js_interop) 'browser_files_web.dart';
