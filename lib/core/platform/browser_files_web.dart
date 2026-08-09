import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'picked_image.dart';

/// Hands [content] to the browser as a file download.
Future<void> downloadTextFile(String fileName, String content) async {
  final blob = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();

  // Freeing the object URL immediately can cancel the download in some
  // browsers, so it is released on the next turn of the event loop instead.
  Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
}

/// Opens the system file picker and returns the chosen file as text.
Future<String?> pickTextFile({String accept = '.json,application/json'}) async {
  final file = await _pickFile(accept);
  if (file == null) return null;

  final completer = Completer<String?>();
  final reader = web.FileReader();

  reader.addEventListener(
    'load',
    ((web.Event _) {
      completer.complete((reader.result as JSString?)?.toDart);
    }).toJS,
  );
  reader.addEventListener(
    'error',
    ((web.Event _) {
      completer.completeError(StateError('The file could not be read'));
    }).toJS,
  );

  reader.readAsText(file);
  return completer.future;
}

/// Picks an image and re-encodes it as JPEG no larger than [maxDimension].
///
/// The downscale happens before anything is stored: a phone photo is several
/// megabytes, and the backup carries deck photos inline, so a full-resolution
/// image would bloat every export from then on. Images already smaller than
/// [maxDimension] are not scaled up.
Future<PickedImage?> pickImage({
  int maxDimension = 1280,
  double quality = 0.82,
}) async {
  final file = await _pickFile('image/*');
  if (file == null) return null;

  final url = web.URL.createObjectURL(file);
  try {
    final image = await _loadImage(url);

    final longestSide = image.naturalWidth > image.naturalHeight
        ? image.naturalWidth
        : image.naturalHeight;
    final scale = longestSide > maxDimension ? maxDimension / longestSide : 1.0;
    final width = (image.naturalWidth * scale).round();
    final height = (image.naturalHeight * scale).round();

    final canvas = web.HTMLCanvasElement()
      ..width = width
      ..height = height;
    final context = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
    context.drawImage(image, 0, 0, width.toDouble(), height.toDouble());

    final blob = await _toBlob(canvas, quality);
    if (blob == null) return null;

    final buffer = (await blob.arrayBuffer().toDart).toDart;
    return PickedImage(bytes: buffer.asUint8List(), mimeType: 'image/jpeg');
  } finally {
    web.URL.revokeObjectURL(url);
  }
}

Future<web.File?> _pickFile(String accept) {
  final completer = Completer<web.File?>();

  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = accept;

  // A cancelled dialog fires no event in most browsers, so that case simply
  // never resolves and the caller is left as it was, which is what cancelling
  // should do anyway.
  input.addEventListener(
    'change',
    ((web.Event _) {
      final files = input.files;
      completer.complete(
        files == null || files.length == 0 ? null : files.item(0),
      );
    }).toJS,
  );

  input.click();
  return completer.future;
}

Future<web.HTMLImageElement> _loadImage(String url) {
  final completer = Completer<web.HTMLImageElement>();
  final image = web.HTMLImageElement();

  image.addEventListener(
    'load',
    ((web.Event _) {
      completer.complete(image);
    }).toJS,
  );
  image.addEventListener(
    'error',
    ((web.Event _) {
      completer.completeError(StateError('The image could not be decoded'));
    }).toJS,
  );

  image.src = url;
  return completer.future;
}

Future<web.Blob?> _toBlob(web.HTMLCanvasElement canvas, double quality) {
  final completer = Completer<web.Blob?>();

  canvas.toBlob(
    ((web.Blob? blob) => completer.complete(blob)).toJS,
    'image/jpeg',
    quality.toJS,
  );

  return completer.future;
}
