import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../booth_hardware.dart';

/// Downloads through a temporary object URL and anchor.
class WebStripSaver implements StripSaver {
  const WebStripSaver();

  @override
  void save(Uint8List bytes, {required String fileName, required String mimeType}) {
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    web.document.body!.append(anchor);
    anchor
      ..click()
      ..remove();
    Timer(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
  }
}
