# Nano Banana CD Cover: step 3, the model

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Where you are.** The app generates a cover. One request carries the prompt
and the photo, one response carries the artwork and the identity, and you have
deleted the stub along with the placeholder image it returned.

This branch is the finished step. Start on `02_photo` and follow along, or read
it here beside the result.

```
git checkout 02_photo
```

## Before you start: billing

Image generation has no free tier. On a Spark-plan project both
`gemini-3.1-flash-image` and the legacy `gemini-2.5-flash-image` return
`limit: 0` for `generate_content_free_tier_requests`, and each call fails with
a quota error that looks like a bug in your code.

Upgrade the Firebase project to **Blaze** before you start.

## What you are building

The code either side of the round-trip already exists. The controller rolls a
style, builds the prompt, flips into its busy state and hands the draft to the
sheet, and the photo sits in memory. You add the part that talks to Google.

Five files change, you add two and delete one. Three of those changes are
project setup rather than code.

---

## 1. Create the Firebase project

Four screens in the console decide something. You click through the rest.

Name the project whatever you like, and check the ID underneath resolves
without a suffix, or you will type the suffixed one for the rest of the
codelab. Find **Firebase AI Logic** in the left-hand nav. It hides well, and the
app calls it. The console offers you a provider: take the **Gemini Developer
API**. Vertex AI reaches the same models by another route that this project
leaves alone. The console then enables the APIs it needs and hands off to the
FlutterFire CLI.

Then connect the project:

```
dart pub global activate flutterfire_cli
flutterfire configure
```

That registers the per-platform apps and writes `lib/firebase_options.dart`.

That file is not in this repository, and that is deliberate: it names a
project, and it should name yours. Until you generate it, this branch will not
compile, because `lib/main.dart` imports it on line 4.

Add the packages to `pubspec.yaml`:

```yaml
  firebase_core: ^4.13.0
  firebase_ai: ^3.15.0
  firebase_app_check: ^0.4.6
```

---

## 2. Turn on App Check

Firebase AI Logic refuses requests that are not attested. Without App Check,
anyone who pulls the config out of your shipped bundle can spend your Blaze
budget on their own image generation.

**New file `lib/services/app_check_setup.dart`:**

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Public reCAPTCHA v3 **site** key, passed per build with
/// `--dart-define=RECAPTCHA_SITE_KEY=...`. The secret stays in the console.
const String _siteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

/// Fixed App Check debug token. Without one, every browser mints its own.
const String _debugToken = String.fromEnvironment('APPCHECK_DEBUG_TOKEN');

/// Turns on App Check, which Firebase AI Logic enforces.
///
/// The token must go to [WebDebugProvider], not the global — the plugin
/// overwrites that with `true` while resolving the provider.
Future<void> activateAppCheck() async {
  if (kReleaseMode && _siteKey.isEmpty) {
    throw StateError(
      'Release builds need a reCAPTCHA v3 site key. Create one in the Firebase '
      'console under App Check, then build with '
      '--dart-define=RECAPTCHA_SITE_KEY=...',
    );
  }
  await FirebaseAppCheck.instance.activate(
    providerWeb: kReleaseMode
        ? ReCaptchaV3Provider(_siteKey)
        : WebDebugProvider(
            debugToken: _debugToken.isEmpty ? null : _debugToken,
          ),
  );
}
```

You pass the site key per build rather than storing it in source. reCAPTCHA
site keys are public by design, so hardcoding one would be safe enough. Leaving
it out stops you shipping a release attested against someone else's key. A
release build without one throws at startup and prints the command that fixes
it. The matching secret stays in the Firebase console.

Hand the debug token to `WebDebugProvider`. Setting
`FIREBASE_APPCHECK_DEBUG_TOKEN` in `web/index.html` looks like the alternative
and fails: the plugin sets that global itself while resolving the provider and
overwrites your value with `true`, which makes the SDK mint a fresh UUID per
browser. You then register each of those in the console.

`web/index.html` picks up a comment recording that trap and is otherwise
unchanged.

Your first run fails, and that is the expected order of events. The app prints
the token, so your first generation goes out before the console has seen it and
comes back with:

```
[app-check/fetch-status-error] AppCheck: Fetch server returned an HTTP error
status. HTTP status: 403.
```

App Check is refusing a token it does not recognise. Copy the token the app
printed, register it under App Check in the console, and reload. Or pass a
fixed one, so each browser you open reports the same token instead of minting
its own:

```
flutter run -d chrome --dart-define=APPCHECK_DEBUG_TOKEN=...
```

Release builds need the site key too:

```
flutter build web --dart-define=RECAPTCHA_SITE_KEY=...
```

---

## 3. Initialise Firebase before the app

`main` becomes async, and the bindings have to exist before any plugin runs.

**Replace `lib/main.dart`:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/cover/cover_page.dart';
import 'services/app_check_setup.dart';
import 'state/cover_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await activateAppCheck();
  runApp(CdCoverApp(controller: CoverController()));
}

/// The CD cover press, calling a real model.
///
/// Still one column and unstyled; the layout comes next.
class CdCoverApp extends StatelessWidget {
  const CdCoverApp({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nano Banana CD Cover',
      debugShowCheckedModeBanner: false,
      home: CoverPage(controller: controller),
    );
  }
}
```

---

## 4. Read the response

An image model can emit `TextPart`s and `InlineDataPart`s interleaved in a
single response, so both halves of the answer arrive in one round-trip. The
convenience `.text` accessor drops that sequence, so you walk the parts
yourself.

`draftFrom` does that walk. It sits at the top level rather than inside the
class, so your tests reach it without Firebase in the way. You can construct
`Candidate`, `Content`, `TextPart` and `InlineDataPart` yourself, so those tests
use real SDK types instead of a stand-in.

**Replace `lib/services/nano_banana_service.dart`:**

```dart
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
```

An empty response means the model stopped rather than answered, on a safety
filter or a token limit, and the finish reason tells you which. Drop it and you
get a blank error and spend the afternoon hunting a bug in your own code.

`_measure` reads the returned image's real dimensions so the plate can hug
them. The prompt asks for 2:1 and the model sometimes returns something else.

---

## 5. Delete the placeholder

You deleted the stub, so nothing loads it.

```
git rm assets/placeholder_cover.png
```

Remove the `assets:` block from `pubspec.yaml` with it.

---

## 6. Cover the parsing

Test `draftFrom` against the shapes a model produces: image alone, text alone,
both, neither, and a stop with a reason.

**New file `test/draft_from_test.dart`:**

````dart
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
````

```
flutter test
```

---

## Run it

```
flutter pub get
flutter run -d chrome
```

| Do this | What you should see |
| --- | --- |
| *Make the cover* before registering the token | `[app-check/fetch-status-error] … HTTP status: 403.` Expected. Register the printed token and reload. |
| Upload a photo, then *Make the cover* | Roughly twelve seconds, then a real spread with your face on it and the specs filled in from the model's JSON. |
| Look at the plate | It is whatever ratio the model returned, not necessarily 2:1. |
| Press it again | A different art direction. The style is rolled per run. |
| Download spread | `cd-cover-<style>.png`, named after the roll that produced it. |

A quota error on each call means the project sits on Spark. A 403 from
`app-check/fetch-status-error` on each call means you have yet to register the
debug token.

---

## Next

Step 4 makes the sheet earn its name, with a responsive layout, a press log
that walks the run, a failure plate and the raw server response.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| 0 | `00_starter` | the static sheet |
| 1 | `01_state` | state and a stub service |
| 2 | `02_photo` | the photo: picker, camera, download |
| **3** | **`03_model`** | **the model: Firebase AI Logic and Gemini 📍** |
| 4 | `04_sheet` | the sheet: responsive layout, press log, error panel |
| 5 | `05_design` | the look: theme, fonts, animations |

## Layout

```
lib/
  firebase_options.dart              written by flutterfire, gitignored
  services/
    app_check_setup.dart             debug provider / reCAPTCHA v3
    nano_banana_service.dart         the call, and draftFrom to read it back
  models/album_meta.dart             now actually parsing what came back
test/
  draft_from_test.dart               response walking, no Firebase needed
```
