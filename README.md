# Nano Banana CD Cover: step 2, the photo

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Where you are.** Real photos go in and real files come out. *Upload a photo*
opens the platform picker, *Take a selfie* opens a live camera page, and
*Download spread* hands the bytes to the browser. `generateCover` now takes the
selfie and a prompt, and still ignores both: the placeholder comes back either
way. You write the prompt here; nothing sends it.

This branch is the finished step. Start on `01_state` and follow along, or read
it here beside the result.

```
git checkout 01_state
```

## What you are building

Step 1 gave the sheet a controller and something to show, but you had no way
to get a photo in or a file out.

This step adds two ways in, one way out, and the prompt that travels with the
photo in step 3. You give the service the signature it needs, and it keeps
returning the placeholder, so the round-trip stays the one missing piece when
step 3 starts.

You add three packages, and twelve files change.

---

## 1. Add the packages

```yaml
  image_picker: ^1.2.3
  camera: ^0.12.0+2
  web: ^1.1.1
```

Put those under `dependencies:` in `pubspec.yaml`, then:

```
flutter pub get
```

`image_picker` opens the platform file dialog and `camera` drives a live
preview. The download uses `web`, and only on the web build.

---

## 2. Write the prompt

Nothing sends the prompt yet. Writing it now leaves step 3 as the API call
alone.

The prompt tells the model to count the people in the photo instead of handing
it a number, because the app does not know either. One face makes a solo artist
and four make a group, and the prompt says "the act" throughout so that nothing
steers a group photo back to one person.

**New file `lib/prompts/cover_prompt.dart`:**

````dart
import 'cover_styles.dart';

/// Builds the prompt for one CD inlay wrap. Only [style] varies per run.
String buildCoverPrompt(CoverStyle style) =>
    '''
You are art-directing an early-2000s hip-hop / alternative CD album.

Language rule, which overrides everything below it.

Keep the voice of the era. Its slang, its stylised spelling, its swagger and
its bravado are the point: names like "Tha Northside Click", "Blueprint Lyfe"
or "Concrete Rosez" are exactly right, and so are track titles that sound like
they came off a real sleeve in 2001.

What must never appear, in the JSON or painted into the artwork: slurs of any
kind, racial or ethnic epithets, profanity, sexual content, and anything
demeaning to any group of people. This holds even though records of the era
often used them. If a name or title you are about to write would break it,
pick another one in the same voice.

Start by looking at the supplied photo and counting the people in it. Those
people are "the act":
- one person — a solo artist.
- two or more — a group, and every single one of them is a member.
Never drop a person, never invent an extra one, and never replace anyone with
a different face. If the photo shows four people, the artwork shows those same
four people.

First invent the album identity and report it as a JSON object inside a
```json fenced code block, with exactly these keys:
  "artistName": string — the name of the act, in the style of the era. A stage
      name if the photo shows one person, a group name if it shows several.
  "albumTitle": string — short, Y2K flavour
  "catalogNumber": string — a catalogue number like "745.98.02"
  "label": string — an invented record label

Then generate the complete printed inlay artwork as a single image, inventing
10-12 track titles with running times and typesetting all of it into the
artwork itself. Keep every face from the photo clearly recognisable as itself.

The artist name and album title painted into the artwork must match the JSON
above character for character — they are shown side by side.

Every piece of text in the artwork must be one of those invented strings.
Never paint instruction words, field labels or placeholders such as "artist
name", "album title" or "track list" into the image.

Produce one single wide landscape image, 2:1 aspect ratio, laid out as a
two-panel album inlay:

- Right half = the front cover. The act posed as the recording artist,
  confident and direct-to-camera. If the act is a group, arrange them as a
  posed group shot — every member in frame, faces unobscured, at a scale
  where each is clearly identifiable, with the composition reading as one
  crew rather than separate cut-outs.
  Wardrobe — this is important: completely replace the clothing worn in the
  supplied photo, for every person in it. Do not keep the original garments,
  their colours, their patterns or their necklines. Nothing anyone is wearing
  in the source photo should survive into the artwork. Dress the act according
  to the art direction below; for a group, style them as one crew in that same
  direction, varying the individual garments so they look styled together
  rather than uniformed.
  Set the act's name and the album title on this panel as designed lettering.
  Print only those two invented strings — never the words "artist name",
  "album title", or any other field label or placeholder. Spell every word
  correctly and keep the lettering clearly legible.
- Left half = the back cover, carrying the printed track list: 10-12 numbered
  tracks, each with a title and a running time in m:ss, set in small clean
  type that stays readable against the artwork. Add a record label name and
  a small copyright line at the bottom. No faces on this half — the artwork
  continues behind the type, calm enough to read against.
  The album title and the act's name must be spelled identically on both
  halves.

The two halves must read as one continuous image. The background must flow
unbroken across the centre fold, with no seam, no tonal step and no visible
join.

${style.direction}

Commit fully to this art direction: the palette, wardrobe, lettering and film
treatment above should all be unmistakable at a glance.
''';
````

The structure stays fixed. One line varies between runs: the style, a preset
the controller rolls at random.

**New file `lib/prompts/cover_styles.dart`:**

```dart
import 'dart:math';

/// One Y2K art-direction preset, rolled at random per generation.
class CoverStyle {
  const CoverStyle({
    required this.name,
    required this.palette,
    required this.wardrobe,
    required this.typography,
    required this.treatment,
  });

  /// Short label, so a good roll can be recognised.
  final String name;

  final String palette;
  final String wardrobe;
  final String typography;
  final String treatment;

  String get direction =>
      '''
ART DIRECTION — "$name":
- Palette and setting: $palette
- Wardrobe: $wardrobe
- Typography: $typography
- Photographic treatment: $treatment''';

  static CoverStyle random([Random? random]) =>
      all[(random ?? Random()).nextInt(all.length)];

  /// One per distinct visual language.
  static const List<CoverStyle> all = [
    CoverStyle(
      name: 'Electric Blue Grunge',
      palette:
          'a saturated cyan and electric-blue monochrome wash over the whole '
          'frame, with acid-yellow and lime highlights and a streak of hot '
          'pink light cutting diagonally across the image. Grimy, sun-bleached '
          'suburban setting — concrete, chain-link, weathered paint.',
      wardrobe:
          'distressed low-slung denim, frayed cropped tops, layered chunky '
          'knits, leg warmers or slouched boots, a small pendant necklace. '
          'Deliberately scruffy and undone.',
      typography:
          'a bold rounded serif logotype in acid yellow, slightly hand-drawn, '
          'sitting in the upper corner.',
      treatment:
          'heavy colour grading pushed to the point of channel clipping, high '
          'grain, hard on-camera flash, slight motion blur at the edges.',
    ),
    CoverStyle(
      name: 'Super Electric Techno',
      palette:
          'burnt orange and rust filling the frame, overlaid with a dense '
          'collage of blueprint linework, exploded technical diagrams, grids '
          'and vector arrows in white and black.',
      wardrobe:
          'baggy nylon trackwear, oversized windbreaker, bucket hat or '
          'bandana, wraparound sport shades, cornrows or spiky bleached tips. '
          'Breakdance-crew energy.',
      typography:
          'a chunky graffiti-style wordmark with a hard outline, plus a narrow '
          'strip of tiny monospace credits running edge to edge near the top.',
      treatment:
          'flat high-contrast cut-out photography layered over the diagram '
          'collage, halftone dots, visible registration marks.',
    ),
    CoverStyle(
      name: 'Millennium White',
      palette:
          'white on white, with a soft lavender and pale-blue radial glow '
          'blooming from behind the act. Weightless, heavenly, almost no '
          'shadow.',
      wardrobe:
          'a crisp all-white suit or an iridescent white tracksuit, '
          'white-on-white layering, holographic or chrome-finish fabric, '
          'silver-tinted wraparound shades, a thick silver chain.',
      typography:
          'a chrome liquid-metal wordmark with a strong bevel and specular '
          'highlight, centred low in the frame.',
      treatment:
          'clean studio lighting, heavy backlit haze, soft bloom, glossy '
          'retouching with no visible grain.',
    ),
    CoverStyle(
      name: 'Black & White Street',
      palette:
          'pure black and white, no colour at all. Shot on a city street '
          'against ornate old architecture, wide-angle and slightly distorted, '
          'the act close to the lens.',
      wardrobe:
          'tracksuit jacket, bandana or headband, chunky watch and rings, '
          'sportswear layering. Hands thrown toward the camera.',
      typography:
          'a bold lowercase sans wordmark set tight, plus a small '
          'PARENTAL ADVISORY block in a bottom corner.',
      treatment:
          'high-contrast greyscale, wide-angle lens distortion, deep focus so '
          'the architecture stays sharp behind the act.',
    ),
  ];
}
```

---

## 3. Give the service a signature

The body still returns the placeholder. The shape of the call changes: it now
takes the photo and the prompt, and `CoverDraft` gains the raw text a model
would send back alongside the image.

**Replace `lib/services/nano_banana_service.dart`:**

```dart
import 'dart:ui' as ui show ImageDescriptor, ImmutableBuffer, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  /// The plate sizes itself from this rather than assuming a ratio.
  final ui.Size? pixelSize;

  CoverDraft withPixelSize(ui.Size? size) =>
      CoverDraft(image: image, rawText: rawText, meta: meta, pixelSize: size);
}

/// Stands in for the Gemini call.
///
/// Replacing the body of [generateCover] is the whole exercise.
class NanoBananaService {
  NanoBananaService();

  /// Nano Banana 2. Image generation has no free tier — Blaze required.
  static const String defaultModel = 'gemini-3.1-flash-image';

  static const String _placeholderAsset = 'assets/placeholder_cover.png';

  /// Roughly what the real call costs, so the busy state is not a flicker.
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

  Future<CoverDraft> generateCover({
    required Uint8List selfie,
    required String prompt,
    String mimeType = 'image/jpeg',
  }) async {
    // TODO(codelab): send `selfie` and `prompt` to the image model, then read
    // the artwork and the JSON identity out of the response.
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
      rawText: '',
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
```

It ignores both parameters, and the `TODO(codelab)` marks the spot. Adding
them now means each caller already passes what step 3 needs, so that step
touches one method and nothing else.

---

## 4. Save the cover

The bytes live in memory, so generating again discards them. You keep a cover
by downloading it.

Web and mobile want different things here: a browser download against a share
sheet. Conditional import picks the implementation at compile time, so neither
platform carries the other's code.

**New file `lib/services/cover_download.dart`:**

```dart
/// Saves the generated cover to the user's device.
library;

export 'cover_download_stub.dart'
    if (dart.library.js_interop) 'cover_download_web.dart';
```

**New file `lib/services/cover_download_web.dart`:**

```dart
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Hands the bytes to the browser as a download.
Future<void> downloadCover(Uint8List bytes, String filename) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  try {
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';
    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  } finally {
    // Or the blob is pinned for the life of the page.
    web.URL.revokeObjectURL(url);
  }
}
```

You trigger a browser download by wrapping the bytes in a blob and clicking a
synthetic anchor. Revoke the URL afterwards. These are multi-megabyte images,
and each generation sits in memory for the life of the page without it.

**New file `lib/services/cover_download_stub.dart`:**

```dart
import 'package:flutter/foundation.dart';

/// Non-web fallback: throws.
Future<void> downloadCover(Uint8List bytes, String filename) {
  throw UnsupportedError(
    'Saving is only wired up for web. On mobile this needs a share sheet.',
  );
}
```

---

## 5. Teach the controller about photos

The controller gains the selfie, the style roll, and the save.

**Replace `lib/state/cover_controller.dart`:**

```dart
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../prompts/cover_prompt.dart';
import '../prompts/cover_styles.dart';
import '../services/cover_download.dart';
import '../services/nano_banana_service.dart';

enum CoverStatus { idle, generating, ready, error }

/// Owns the selfie and the generated cover draft.
class CoverController extends ChangeNotifier {
  CoverController({ImagePicker? picker, NanoBananaService? service})
    : _picker = picker ?? ImagePicker(),
      _service = service ?? NanoBananaService();

  final ImagePicker _picker;
  final NanoBananaService _service;

  Uint8List? _selfie;
  Uint8List? get selfie => _selfie;

  CoverDraft? _draft;
  CoverDraft? get draft => _draft;

  /// Which art direction this draft was rolled with.
  CoverStyle? _style;
  CoverStyle? get style => _style;

  CoverStatus _status = CoverStatus.idle;
  CoverStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool get hasSelfie => _selfie != null;
  bool get isBusy => _status == CoverStatus.generating;

  /// Longest edge the selfie is scaled to before being sent.
  static const double _maxSelfieEdge = 1280;

  /// Opens the platform file dialog.
  Future<void> uploadSelfie() async {
    _error = null;
    notifyListeners();
    try {
      // firebase_ai base64-encodes on the main isolate, so a full-size
      // photo freezes the UI while the request is built.
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxSelfieEdge,
        maxHeight: _maxSelfieEdge,
        imageQuality: 85,
      );
      if (file == null) return;
      _selfie = await file.readAsBytes();
      _draft = null;
      _status = CoverStatus.idle;
    } on Exception catch (e) {
      _error = 'Could not read that image: $e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  /// Accepts bytes captured elsewhere.
  void setSelfie(Uint8List bytes) {
    _selfie = bytes;
    _draft = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }

  Future<void> generate() async {
    final selfie = _selfie;
    if (selfie == null || isBusy) return;

    _status = CoverStatus.generating;
    _error = null;
    _draft = null;
    _style = CoverStyle.random();
    debugPrint('Cover style: ${_style!.name}');
    notifyListeners();

    try {
      _draft = await _service.generateCover(
        selfie: selfie,
        prompt: buildCoverPrompt(_style!),
      );
      _status = CoverStatus.ready;
    } on Exception catch (e) {
      _error = '$e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  /// Hands the artwork to the browser's download dialog.
  ///
  /// The bytes only live in memory — generating again discards them.
  Future<void> saveCover() async {
    final bytes = _draft?.image;
    if (bytes == null) return;

    final slug = (_style?.name ?? 'cover')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    try {
      await downloadCover(bytes, 'cd-cover-$slug.png');
    } on Object catch (e) {
      _error = 'Could not save the cover: $e';
      notifyListeners();
    }
  }

  void clear() {
    _selfie = null;
    _draft = null;
    _style = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }
}
```

You give `pickImage` `maxWidth`, `maxHeight` and `imageQuality`, and those are
not cosmetic. `firebase_ai` base64-encodes the bytes on the main isolate when it
builds the request, so a full-size phone photo freezes the UI for seconds in
step 3. Gemini downsamples large images anyway, so you pay for detail it throws
away.

The controller rolls `_style` per run, and it reaches the UI through the
download filename. That filename is your record of which direction produced a
cover you liked.

---

## 6. The camera page

Upload and capture stay separate on purpose. On web they are two mechanisms,
`getUserMedia` against a file input, and merging them would hide that behind a
wrapper with different behaviour on each platform.

The page pops with the captured bytes, or with null if the user backs out.

**New file `lib/features/camera/camera_page.dart`:**

```dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Live webcam preview with a shutter button. Pops the captured bytes.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  String? _error;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera available on this device.');
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      // Mobile captures are uncapped; big frames stall the main isolate.
      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      setState(() => _error = _describe(e));
    }
  }

  String _describe(CameraException e) {
    if (e.code == 'CameraAccessDenied' || e.code == 'NotAllowedError') {
      return 'Camera permission was denied. Allow access in your browser, '
          'then try again.';
    }
    return 'Could not start the camera: ${e.description ?? e.code}';
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final shot = await controller.takePicture();
      final bytes = await shot.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop<Uint8List>(bytes);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _describe(e);
        _capturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a selfie')),
      body: Center(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() => _error = null);
                _start();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const CircularProgressIndicator();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _capturing ? null : _capture,
            icon: const Icon(Icons.camera_alt),
            label: Text(_capturing ? 'Capturing…' : 'Capture'),
          ),
        ],
      ),
    );
  }
}
```

The page prefers the front camera and falls back to whatever exists. It
catches permission denial by name, because "CameraAccessDenied" needs an
instruction and the other failures do not.

---

## 7. Route to the camera

`CoverPage` pushes the camera and keeps whatever comes back.

**Replace `lib/features/cover/cover_page.dart`:**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import '../camera/camera_page.dart';
import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The cover sheet, stacked in one column at every width.
class CoverPage extends StatelessWidget {
  const CoverPage({required this.controller, super.key});

  final CoverController controller;

  Future<void> _takeSelfie(BuildContext context) async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
    if (bytes != null) controller.setSelfie(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => SafeArea(
          child: ListView(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CoverLayout.maxSheetWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CoverMasthead(controller: controller),
                        const SizedBox(height: 40),
                        ProofPanel(controller: controller),
                        const SizedBox(height: 32),
                        PlateSpecs(controller: controller),
                        const SizedBox(height: 32),
                        CoverActions(
                          controller: controller,
                          onTakeSelfie: () => _takeSelfie(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Wire the buttons

All four do something now. Generate stays disabled until a photo exists, and
download until a cover does.

**Replace `lib/features/cover/widgets/cover_actions.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'dashed_action.dart';
import 'press_action.dart';

/// Everything below the plate: error, inputs, generate, download.
class CoverActions extends StatelessWidget {
  const CoverActions({
    required this.controller,
    required this.onTakeSelfie,
    super.key,
  });

  final CoverController controller;
  final VoidCallback onTakeSelfie;

  @override
  Widget build(BuildContext context) {
    final busy = controller.isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.error case final error?) ...[
          Text(error, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 22),
        ],
        Row(
          children: [
            Expanded(
              child: DashedAction(
                label: 'Upload a photo',
                onPressed: busy ? null : controller.uploadSelfie,
                leading: const Icon(Icons.arrow_upward, size: 14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashedAction(
                label: 'Take a selfie',
                onPressed: busy ? null : onTakeSelfie,
                leading: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        PressAction(
          label: 'Make the cover',
          trailing: '~12 sec',
          onPressed: busy || !controller.hasSelfie ? null : controller.generate,
        ),
        const SizedBox(height: 22),
        DashedAction(
          label: 'Download spread',
          onPressed:
              controller.draft?.image == null ? null : controller.saveCover,
          leading: const Icon(Icons.arrow_downward, size: 14),
        ),
      ],
    );
  }
}
```

---

## 9. Show the selfie on the plate

Before a cover exists the plate shows the photo you are about to send, so you
can see what the model gets.

**Replace `lib/features/cover/widgets/proof_body.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// What sits on the plate.
class ProofBody extends StatelessWidget {
  const ProofBody({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isBusy) {
      return const _Placeholder('GENERATING…');
    }
    final art = controller.draft?.image ?? controller.selfie;
    if (art == null) {
      return const _Placeholder('AWAITING SELFIE');
    }
    // Contain, never cover: a portrait selfie would be cropped in half.
    return ColoredBox(
      color: Colors.black12,
      child: Image.memory(art, fit: BoxFit.contain),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(child: Text(label, style: const TextStyle(fontSize: 12))),
    );
  }
}
```

`BoxFit.contain` rather than `cover`. The frame is still on its 2:1 placeholder
ratio at this point, and cropping a portrait photo to a landscape plate cuts the
face in half.

`lib/main.dart` and `lib/features/cover/widgets/proof_panel.dart` each pick up a
doc comment in this step and are otherwise unchanged.

---

## Run it

```
flutter pub get
flutter run -d chrome
```

| Do this | What you should see |
| --- | --- |
| Upload a photo | The file dialog opens. Your photo appears on the plate and *Make the cover* comes alive. |
| Take a selfie | The camera page opens and asks for permission. Capture pops you back with the shot on the plate. |
| Make the cover | Two seconds, then the placeholder spread and its specs. The stub has not looked at your photo. |
| Download spread | The browser saves `cd-cover-<style>.png`. |

The placeholder comes back regardless of the photo, and that is the point of
this step. You send nothing yet.

---

## Next

Step 3 sends it, with a Firebase project on the Blaze plan, App Check, and one
call to Gemini's image model that returns the artwork and the JSON identity
together.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| 0 | `00_starter` | the static sheet |
| 1 | `01_state` | state and a stub service |
| **2** | **`02_photo`** | **the photo: picker, camera, download 📍** |
| 3 | `03_model` | the model: Firebase AI Logic and Gemini |
| 4 | `04_sheet` | the sheet: responsive layout, press log, error panel |
| 5 | `05_design` | the look: theme, fonts, animations |

## Layout

```
lib/
  features/camera/camera_page.dart   live preview, pops the captured bytes
  prompts/
    cover_prompt.dart                the art direction, not yet sent
    cover_styles.dart                one of these is rolled per run
  services/
    cover_download.dart              conditional export
    cover_download_web.dart          blob plus a synthetic anchor click
    cover_download_stub.dart         throws off the web
    nano_banana_service.dart         a stub with the real signature
  state/cover_controller.dart        selfie, draft, status, error
```
