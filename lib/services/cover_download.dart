/// Saves the generated cover to the user's device.
library;

export 'cover_download_stub.dart'
    if (dart.library.js_interop) 'cover_download_web.dart';
