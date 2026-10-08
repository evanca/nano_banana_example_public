import 'dart:typed_data';
import 'dart:ui' as ui;

/// Width over height of encoded image bytes, or null when they cannot be
/// decoded. An image you cannot measure is still worth showing.
Future<double?> measureAspectRatio(Uint8List bytes) async {
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final ratio = descriptor.height == 0 ? null : descriptor.width / descriptor.height;
    descriptor.dispose();
    buffer.dispose();
    return ratio;
  } catch (_) {
    return null;
  }
}
