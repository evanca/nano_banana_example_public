import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_banana_example/services/nano_banana_service.dart';

Candidate _candidate(
  List<Part> parts, {
  FinishReason? finishReason,
  String? finishMessage,
}) =>
    Candidate(
      Content('model', parts),
      const <SafetyRating>[],
      null,
      finishReason,
      finishMessage,
    );

final _bytes = Uint8List.fromList(const [1, 2, 3]);

void main() {
  group('draftFrom', () {
    test('splits an interleaved response into artwork and specs', () {
      final draft = draftFrom(_candidate([
        TextPart('```json\n{"artistName":"Lyra","albumTitle":"Aether Theory",'
            '"catalogNumber":"SY98.02.45","label":"Chromatic"}\n```'),
        InlineDataPart('image/png', _bytes),
      ]));

      expect(draft.image, _bytes);
      expect(draft.meta?.artistName, 'Lyra');
      expect(draft.meta?.albumTitle, 'Aether Theory');
    });

    test('keeps the artwork when the model sends no text', () {
      final draft = draftFrom(_candidate([
        InlineDataPart('image/png', _bytes),
      ]));

      expect(draft.image, _bytes);
      expect(draft.rawText, isEmpty);
      expect(draft.meta, isNull);
    });

    test('reports the finish reason when the model stopped instead of drawing',
        () {
      expect(
        () => draftFrom(_candidate(
          [TextPart('I cannot help with that.')],
          finishReason: FinishReason.safety,
        )),
        throwsA(
          isA<NanoBananaException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('because: safety'),
              contains('I cannot help with that.'),
            ),
          ),
        ),
      );
    });

    test('says the response was empty when there is nothing to report', () {
      expect(
        () => draftFrom(_candidate(const [])),
        throwsA(
          isA<NanoBananaException>().having(
            (e) => e.message,
            'message',
            contains('completely empty'),
          ),
        ),
      );
    });

    test('takes the first image when the model returns more than one', () {
      final second = Uint8List.fromList(const [9, 9, 9]);
      final draft = draftFrom(_candidate([
        InlineDataPart('image/png', _bytes),
        InlineDataPart('image/png', second),
      ]));

      expect(draft.image, _bytes);
    });
  });
}
