import 'picked_image.dart';

/// Fallback used outside the browser, where there is no download or file picker.
///
/// Reached only if the app is ever built for a platform other than web; the
/// tests exercise the services behind these calls directly.
Future<void> downloadTextFile(String fileName, String content) {
  throw UnsupportedError('Downloading a file is only supported on the web');
}

Future<String?> pickTextFile({String accept = '.json,application/json'}) {
  throw UnsupportedError('Picking a file is only supported on the web');
}

Future<PickedImage?> pickImage({
  int maxDimension = 1280,
  double quality = 0.82,
}) {
  throw UnsupportedError('Picking an image is only supported on the web');
}
