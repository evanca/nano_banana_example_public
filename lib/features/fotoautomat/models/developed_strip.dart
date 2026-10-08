import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'strip_style.dart';

/// A strip the darkroom returned.
class DevelopedStrip extends Equatable {
  const DevelopedStrip({
    required this.bytes,
    required this.mimeType,
    required this.style,
    required this.model,
    required this.developedAt,
    this.labNote,
    this.aspectRatio,
  });

  final Uint8List bytes;
  final String mimeType;
  final StripStyle style;
  final String model;
  final DateTime developedAt;

  /// The model's one-line remark. Image-only responses happen
  /// intermittently, so this is optional by design.
  final String? labNote;

  /// Measured width over height; the requested ratio is not guaranteed.
  final double? aspectRatio;

  String get fileExtension => switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/webp' => 'webp',
    _ => 'png',
  };

  @override
  List<Object?> get props => [bytes, mimeType, style.id, model, developedAt, labNote, aspectRatio];
}
