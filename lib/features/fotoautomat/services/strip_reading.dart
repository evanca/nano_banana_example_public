import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

/// What one generation response amounts to.
sealed class StripReading {
  const StripReading();
}

class StripImageReading extends StripReading {
  const StripImageReading({required this.bytes, required this.mimeType, this.note});

  final Uint8List bytes;
  final String mimeType;
  final String? note;
}

class StripFailureReading extends StripReading {
  const StripFailureReading(this.reason);

  /// Human-readable, shown on the error panel.
  final String reason;
}

/// Interprets a response without touching Firebase, so it is testable with
/// real SDK types. Reports why nothing came back instead of a blank error.
StripReading readStripResponse(GenerateContentResponse response) {
  final feedback = response.promptFeedback;
  if (feedback?.blockReason case final reason?) {
    final detail = feedback?.blockReasonMessage;
    return StripFailureReading(
      'Input rejected (${reason.name})${detail == null ? '' : ': $detail'}.',
    );
  }

  final candidate = response.candidates.firstOrNull;
  if (candidate == null) {
    return const StripFailureReading('The darkroom returned nothing. Try again.');
  }

  InlineDataPart? image;
  final text = StringBuffer();
  for (final part in candidate.content.parts) {
    // Interim composition images and reasoning are not the print.
    if (part.isThought ?? false) continue;
    switch (part) {
      case InlineDataPart(:final mimeType, :final bytes)
          when mimeType.startsWith('image/') && bytes.isNotEmpty:
        image ??= part;
      case TextPart(text: final chunk):
        text.write(chunk);
      default:
        break;
    }
  }

  final note = _cleanNote(text.toString());
  if (image != null) {
    return StripImageReading(bytes: image.bytes, mimeType: image.mimeType, note: note);
  }

  final finish = candidate.finishReason;
  if (finish != null && finish != FinishReason.stop) {
    final detail = candidate.finishMessage;
    return StripFailureReading(
      'Development stopped (${finish.name})${detail == null ? '' : ': $detail'}.',
    );
  }
  if (note != null) {
    return StripFailureReading('No print, only a note from the darkroom: "$note"');
  }
  return const StripFailureReading('The darkroom returned an empty strip. Try again.');
}

String? _cleanNote(String raw) {
  final note = raw.trim().replaceAll(RegExp(r'^["“„]+|["”“]+$'), '').trim();
  return note.isEmpty ? null : note;
}
