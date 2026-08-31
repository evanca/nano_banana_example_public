import 'dart:ui' as ui show ImageDescriptor, ImmutableBuffer, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/album_meta.dart';

/// The generated artwork plus the specs printed beside it.
class CoverDraft {
  const CoverDraft({
    required this.image,
    required this.meta,
    required this.pixelSize,
  });

  final Uint8List? image;
  final AlbumMeta? meta;

  /// The plate sizes itself from this rather than assuming a ratio.
  final ui.Size? pixelSize;
}

/// Stands in for the call that will eventually make a cover.
///
/// It takes nothing: there is no photo to send yet.
class NanoBananaService {
  NanoBananaService();

  static const String _placeholderAsset = 'assets/placeholder_cover.png';

  /// Roughly what a real call costs, so the busy state is not a flicker.
  static const Duration _latency = Duration(seconds: 2);

  /// One press in every [_failEvery] fails, so the error path is reachable.
  static const int _failEvery = 3;

  int _presses = 0;

  static const AlbumMeta _placeholderMeta = AlbumMeta(
    artistName: 'Placeholder',
    albumTitle: 'Nothing Was Generated',
    catalogNumber: '000.00.00',
    label: 'Stub Records',
  );

  Future<CoverDraft> generateCover() async {
    // The wait comes first either way: a failed call still went out.
    await Future<void>.delayed(_latency);

    _presses++;
    if (_presses % _failEvery == 0) {
      throw const NanoBananaException(
        'The model returned no image. This is the stub failing on purpose: '
        'one press in every $_failEvery throws, so the error path stays '
        'visible until there is a real call to fail.',
      );
    }

    // Offset and length, not the whole backing buffer.
    final data = await rootBundle.load(_placeholderAsset);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return CoverDraft(
      image: bytes,
      meta: _placeholderMeta,
      pixelSize: await _measure(bytes),
    );
  }
}

/// Reads the artwork's real pixel dimensions.
Future<ui.Size?> _measure(Uint8List bytes) async {
  try {
    final descriptor = await ui.ImageDescriptor.encoded(
      await ui.ImmutableBuffer.fromUint8List(bytes),
    );
    final size = ui.Size(
      descriptor.width.toDouble(),
      descriptor.height.toDouble(),
    );
    descriptor.dispose();
    return size;
  } on Object {
    // A cover we cannot measure is still worth showing.
    return null;
  }
}

class NanoBananaException implements Exception {
  const NanoBananaException(this.message);

  final String message;

  @override
  String toString() => message;
}
