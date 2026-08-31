import 'package:flutter/foundation.dart';

/// Non-web fallback: throws.
Future<void> downloadCover(Uint8List bytes, String filename) {
  throw UnsupportedError(
    'Saving is only wired up for web. On mobile this needs a share sheet.',
  );
}
