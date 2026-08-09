import 'dart:typed_data';

/// An image chosen by the user, already downscaled and re-encoded.
class PickedImage {
  const PickedImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;

  int get sizeInBytes => bytes.length;
}
