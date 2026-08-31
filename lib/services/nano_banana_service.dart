import 'dart:ui' as ui show ImageDescriptor, ImmutableBuffer, Size;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../models/album_meta.dart';

/// The generated artwork plus the specs printed beside it.
class CoverDraft {
  const CoverDraft({
    required this.image,
    required this.rawText,
    required this.meta,
    required this.pixelSize,
  });

  final Uint8List? image;
  final String rawText;
  final AlbumMeta? meta;

  /// The frame sizes itself from this; the model does not always honour 2:1.
  final ui.Size? pixelSize;

  CoverDraft withPixelSize(ui.Size? size) => CoverDraft(
        image: image,
        rawText: rawText,
        meta: meta,
        pixelSize: size,
      );
}

/// Interprets one candidate into a draft.
///
/// Split out so it can be tested without Firebase.
CoverDraft draftFrom(Candidate candidate) {
  Uint8List? image;
  final buffer = StringBuffer();
  for (final part in candidate.content.parts) {
    switch (part) {
      case InlineDataPart(:final bytes):
        image ??= bytes;
      case TextPart(:final text):
        buffer.write(text);
      default:
        break;
    }
  }

  final rawText = buffer.toString().trim();
  if (image == null) {
    // Surface the finish reason, or this reads as a client bug.
    final reason = candidate.finishReason;
    throw NanoBananaException([
      'The model returned no image.',
      if (reason != null) 'It stopped because: $reason.',
      if (candidate.finishMessage?.isNotEmpty ?? false) candidate.finishMessage!,
      if (rawText.isNotEmpty) 'It said: $rawText',
      if (reason == null && rawText.isEmpty)
        'The response was completely empty — try generating again.',
    ].join(' '));
  }

  return CoverDraft(
    image: image,
    rawText: rawText,
    meta: AlbumMeta.tryParse(rawText),
    pixelSize: null,
  );
}

/// The single Gemini call returning cover art and album copy together.
///
/// The parts must be walked directly; `.text` misses the interleaving.
class NanoBananaService {
  NanoBananaService({String model = defaultModel})
      : _model = FirebaseAI.googleAI().generativeModel(
          model: model,
          generationConfig: GenerationConfig(
            responseModalities: [
              ResponseModalities.text,
              ResponseModalities.image,
            ],
          ),
          // The prompt asks for a genre whose vocabulary the model will
          // otherwise reach for, and it paints the words into the image where
          // nothing downstream can filter them.
          safetySettings: [
            SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low, null),
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low, null),
            SafetySetting(
              HarmCategory.sexuallyExplicit,
              HarmBlockThreshold.low,
              null,
            ),
          ],
        );

  /// Nano Banana 2. Image generation has no free tier — Blaze required.
  static const String defaultModel = 'gemini-3.1-flash-image';

  final GenerativeModel _model;

  Future<CoverDraft> generateCover({
    required Uint8List selfie,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        InlineDataPart(mimeType, selfie),
      ]),
    ]);

    final blocked = response.promptFeedback?.blockReason;
    if (blocked != null) {
      throw NanoBananaException(
        'The request was blocked ($blocked). '
        '${response.promptFeedback?.blockReasonMessage ?? ''}'.trim(),
      );
    }

    final candidate = response.candidates.firstOrNull;
    if (candidate == null) {
      throw const NanoBananaException('The model returned no candidates.');
    }

    final draft = draftFrom(candidate);
    return draft.withPixelSize(await _measure(draft.image!));
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
