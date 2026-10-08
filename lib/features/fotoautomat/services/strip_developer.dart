import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/developed_strip.dart';
import '../models/strip_style.dart';
import 'image_measure.dart';
import 'strip_prompt.dart';
import 'strip_reading.dart';

/// Thrown with a message fit for the error panel.
class DevelopFailure implements Exception {
  const DevelopFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Turns captured frames into a finished strip.
abstract interface class StripDeveloper {
  String get model;

  Future<DevelopedStrip> develop(List<Uint8List> frames, StripStyle style);
}

/// Nano Banana Pro through Firebase AI Logic (Gemini Developer API).
class GeminiStripDeveloper implements StripDeveloper {
  GeminiStripDeveloper({this.model = defaultModel});

  /// Latest stable (GA) Pro image model, released 2026-05-28.
  static const defaultModel = 'gemini-3-pro-image';

  @override
  final String model;

  late final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: model,
    generationConfig: GenerationConfig(
      responseModalities: [ResponseModalities.text, ResponseModalities.image],
      // Pro supports 1:1 up to 9:16 and 21:9 only; 1:4 is Flash-only and
      // rejected here, so the strip is drawn centred on a 9:16 canvas.
      imageConfig: const ImageConfig(
        aspectRatio: ImageAspectRatio.portrait9x16,
        imageSize: ImageSize.size2K,
      ),
    ),
  );

  @override
  Future<DevelopedStrip> develop(List<Uint8List> frames, StripStyle style) async {
    final GenerateContentResponse response;
    try {
      response = await _model.generateContent([
        Content.multi([
          TextPart(buildStripPrompt(style, frameCount: frames.length)),
          for (final (i, frame) in frames.indexed) ...[
            TextPart(framePhotoLabel(i, frames.length)),
            InlineDataPart('image/jpeg', frame),
          ],
        ]),
      ]);
    } on QuotaExceeded catch (e) {
      throw DevelopFailure(
        'Quota exceeded. Image models have no free tier: the Firebase project '
        'needs the Blaze plan. (${e.message})',
      );
    } on ServiceApiNotEnabled catch (e) {
      throw DevelopFailure(e.message);
    } on FirebaseAIException catch (e) {
      throw DevelopFailure(e.message);
    }

    switch (readStripResponse(response)) {
      case StripFailureReading(:final reason):
        throw DevelopFailure(reason);
      case StripImageReading(:final bytes, :final mimeType, :final note):
        return DevelopedStrip(
          bytes: bytes,
          mimeType: mimeType,
          style: style,
          model: model,
          developedAt: DateTime.now(),
          labNote: note,
          aspectRatio: await measureAspectRatio(bytes),
        );
    }
  }
}
