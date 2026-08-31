# Nano Banana CD Cover: step 1, state

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Where you are.** A `CoverController` now sits behind the sheet. It owns the
run, the page listens to it, and pressing *Make the cover* walks
idle → generating → ready, or → error. It generates nothing yet:
`NanoBananaService` waits two seconds and hands back a bundled placeholder,
throwing on every third press so you can reach the error state.

This branch is the finished step. Start on `00_starter` and follow along, or
read it here beside the result.

```
git checkout 00_starter
```

## What you are building

In the static sheet, each widget holds the values it shows. By the end of this
step one object holds them and the widgets ask it. That object also runs the
work, and the widgets below the listener redraw when it changes.

You add no packages. Six files change, five are new, and the app makes no
network calls.

---

## 1. Describe what comes back

A generated cover is an image plus the identity the model invented for it.
Give each a type before anything produces them.

The model reports that identity as JSON, because once it paints those words
into the artwork they are pixels and the app cannot read them. You write the
parser now, so step 3 covers only the API call.

**New file `lib/models/album_meta.dart`:**

````dart
import 'dart:convert';

/// The album identity the model invented, reported alongside the artwork.
class AlbumMeta {
  const AlbumMeta({
    required this.artistName,
    required this.albumTitle,
    required this.catalogNumber,
    required this.label,
  });

  final String artistName;
  final String albumTitle;
  final String catalogNumber;
  final String label;

  factory AlbumMeta.fromJson(Map<String, dynamic> json) => AlbumMeta(
        artistName: (json['artistName'] as String? ?? '').trim(),
        albumTitle: (json['albumTitle'] as String? ?? '').trim(),
        catalogNumber: (json['catalogNumber'] as String? ?? '').trim(),
        label: (json['label'] as String? ?? '').trim(),
      );

  /// Pulls the metadata out of the model's text.
  ///
  /// Returns null rather than throwing — artwork without specs is still
  /// worth showing.
  static AlbumMeta? tryParse(String raw) {
    if (raw.trim().isEmpty) return null;

    final fenced = RegExp(r'```(?:json)?\s*(\{.*?\})\s*```', dotAll: true)
        .firstMatch(raw)
        ?.group(1);
    final candidate = fenced ?? _firstBalancedObject(raw);
    if (candidate == null) return null;

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! Map<String, dynamic>) return null;
      return AlbumMeta.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  static String? _firstBalancedObject(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) return null;
    var depth = 0;
    for (var i = start; i < raw.length; i++) {
      if (raw[i] == '{') depth++;
      if (raw[i] == '}') {
        depth--;
        if (depth == 0) return raw.substring(start, i + 1);
      }
    }
    return null;
  }
}
````

`tryParse` returns null instead of throwing. A cover whose specs failed to
parse is still worth showing, and an exception here would discard artwork that
arrived intact.

---

## 2. Stand in for the model

The service that makes a cover calls nothing yet. It waits, then hands back a
bundled placeholder.

It waits before deciding whether to fail, because a real call that fails has
still been out to the network, so the busy state runs as long as a success. It
also fails on every third press. Generation does fail in production, on safety
stops and token limits, and a stub that succeeds each time hides a whole branch
of your UI.

**New file `lib/services/nano_banana_service.dart`:**

```dart
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
```

`generateCover()` takes no arguments. There is no photo to send yet, and giving
it parameters it ignores would be a lie about what this step does. Step 2 adds
them.

---

## 3. Own the run

`ChangeNotifier` lives in `flutter/foundation.dart`, so there is nothing to
install. It holds state and tells its listeners when that state changed.

**New file `lib/state/cover_controller.dart`:**

```dart
import 'package:flutter/foundation.dart';

import '../services/nano_banana_service.dart';

enum CoverStatus { idle, generating, ready, error }

/// Owns the generated cover and the state of the run that produced it.
class CoverController extends ChangeNotifier {
  CoverController({NanoBananaService? service})
    : _service = service ?? NanoBananaService();

  final NanoBananaService _service;

  CoverDraft? _draft;
  CoverDraft? get draft => _draft;

  CoverStatus _status = CoverStatus.idle;
  CoverStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool get isBusy => _status == CoverStatus.generating;

  Future<void> generate() async {
    if (isBusy) return;

    // A stale cover on screen would not match what is happening.
    _status = CoverStatus.generating;
    _error = null;
    _draft = null;
    notifyListeners();

    try {
      _draft = await _service.generateCover();
      _status = CoverStatus.ready;
    } on Exception catch (e) {
      _error = '$e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  void clear() {
    _draft = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }
}
```

Three details matter here:

- Clearing `_draft` before the run starts stops the previous cover sitting there
  through the next one, showing something that no longer matches.
- `notifyListeners()` runs twice, once at the start and once at the end. The
  first call puts the busy state on screen.
- The catch takes `on Exception` rather than `on Object`. A thrown `Error`
  means a bug in your own code, and you want it to crash rather than surface as
  a friendly message.

---

## 4. Build the controller once

The app owns one controller and hands it down. You create it outside `build`,
so a rebuild keeps the run in progress.

**Replace `lib/main.dart`:**

```dart
import 'package:flutter/material.dart';

import 'features/cover/cover_page.dart';
import 'state/cover_controller.dart';

void main() {
  runApp(CdCoverApp(controller: CoverController()));
}

/// The CD cover press, with state behind it.
///
/// One controller owns the run; the sheet listens. No photo and no model
/// yet — the service returns a bundled placeholder.
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

## 5. Listen once, at the top

`ListenableBuilder` rebuilds its child whenever the controller notifies. Put
one above the whole sheet and the widgets below it redraw together, so none of
them subscribes on its own.

**Replace `lib/features/cover/cover_page.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The cover sheet, stacked in one column at every width.
class CoverPage extends StatelessWidget {
  const CoverPage({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // One listener at the top; everything below rebuilds together.
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
                        CoverActions(controller: controller),
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

Each widget now takes `controller`, so none of them are `const` any more.

---

## 6. Make the plate react

Split what sits *on* the plate away from the plate itself. The frame stays the
same in each state while the contents change.

**New file `lib/features/cover/widgets/proof_body.dart`:**

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
    final art = controller.draft?.image;
    if (art == null) {
      return const _Placeholder('NOTHING PRESSED YET');
    }
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

**Replace `lib/features/cover/widgets/proof_panel.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'proof_body.dart';

/// The plate the artwork sits on.
class ProofPanel extends StatelessWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  static const double _placeholderRatio = 2;

  @override
  Widget build(BuildContext context) {
    final size = controller.draft?.pixelSize;
    final ratio = size != null && size.height > 0
        ? size.width / size.height
        : _placeholderRatio;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: ratio,
          child: ProofBody(controller: controller),
        ),
      ),
    );
  }
}
```

The static sheet hardcoded `aspectRatio: 2` and kept the placeholder image
inside the widget. Now the panel measures the ratio from whatever the service
returned, and the image arrives as data. That matters in step 3, when a real
model returns something other than 2:1.

---

## 7. Make the copy react

The headline, the job line and the blurb change while a run is in flight. The
job number appears once a cover comes back.

**Replace `lib/features/cover/widgets/cover_masthead.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// Job line, headline and blurb — all three change while generating.
class CoverMasthead extends StatelessWidget {
  const CoverMasthead({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final pressing = controller.isBusy;
    final catalog = controller.draft?.meta?.catalogNumber;
    final job = switch ((pressing, catalog)) {
      (true, _) => 'JOB — ON PRESS',
      (false, final c?) when c.isNotEmpty => 'JOB $c — PROOF 01',
      _ => 'JOB — AWAITING PROOF',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(job, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 14),
        Text(
          pressing ? 'PRINTING\nYOUR COVER' : 'MAKE THE\nCOVER',
          style: const TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 18),
        Text(
          pressing
              ? 'Nano Banana is reading the photo, naming the act and setting '
                    'the type. Sit tight — the whole spread lands in one piece.'
              : 'Step into the booth, solo or with the whole crew. Nano Banana '
                    'reads the photo, invents the act, writes the tracklist '
                    'and prints a full jewel-case spread — front, spine and '
                    'back.',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
```

---

## 8. Fill the specs from the draft

Hardcoded strings become lookups. Two fallbacks matter here: `···` while a run
is going, and `—` before you ask for anything. "In progress" and "nothing yet"
are different states and should not look identical.

**Replace `lib/features/cover/widgets/plate_specs.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'spec_row.dart';

/// The specs table.
class PlateSpecs extends StatelessWidget {
  const PlateSpecs({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final meta = controller.draft?.meta;
    // "Unknown yet" and "in progress" are different states.
    final pending = controller.isBusy ? '···' : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('PLATE SPECS', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 14),
        const Divider(height: 1),
        SpecRow(
          label: 'Artist',
          value: meta?.artistName.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        SpecRow(
          label: 'Title',
          value: meta?.albumTitle.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        SpecRow(
          label: 'Catalog',
          value: meta?.catalogNumber.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        const SpecRow(label: 'Panels', value: 'front / back'),
        const Divider(height: 1),
        const SpecRow(label: 'Stock', value: '300gsm matte'),
        const Divider(height: 1),
        SpecRow(
          label: 'Press',
          value: meta?.label.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

extension on String {
  String orIfEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
```

---

## 9. Wire the button, and show failures

*Make the cover* gets a real callback and goes disabled while busy. The error
gets one line above the inputs.

The photo buttons and the download stay inert. They need the platform behind
them, which is step 2.

**Replace `lib/features/cover/widgets/cover_actions.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'dashed_action.dart';
import 'press_action.dart';

/// Everything below the plate. Only generate is wired yet.
class CoverActions extends StatelessWidget {
  const CoverActions({required this.controller, super.key});

  final CoverController controller;

  static void _todo() {}

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
            const Expanded(
              child: DashedAction(
                label: 'Upload a photo',
                onPressed: _todo,
                leading: Icon(Icons.arrow_upward, size: 14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashedAction(
                label: 'Take a selfie',
                onPressed: _todo,
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
          onPressed: busy ? null : controller.generate,
        ),
        const SizedBox(height: 22),
        const DashedAction(
          label: 'Download spread',
          onPressed: _todo,
          leading: Icon(Icons.arrow_downward, size: 14),
        ),
      ],
    );
  }
}
```

---

## Run it

```
flutter pub get
flutter run -d chrome
```

Press *Make the cover* four times:

| Press | What you should see |
| --- | --- |
| 1 | Plate reads `GENERATING…`, specs show `···`, every control dims. Two seconds later the placeholder spread appears, the specs fill in, and the job line becomes `JOB 000.00.00 — PROOF 01`. |
| 2 | The same. |
| 3 | The error line appears above the inputs, the plate returns to `NOTHING PRESSED YET`, and the specs go back to `—`. |
| 4 | Recovers — the error line is gone. |

If press 3 leaves the old cover on the plate, `_draft = null` is missing from
the start of `generate()`.

---

## Optional: cover the parser

`tryParse` is the one piece of logic here with edge cases: fenced JSON, bare
JSON, JSON buried in prose, malformed input, missing keys.

**New file `test/album_meta_test.dart`:**

````dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_banana_example/models/album_meta.dart';

void main() {
  group('AlbumMeta.tryParse', () {
    test('reads a fenced json block', () {
      final meta = AlbumMeta.tryParse('''
```json
{"artistName":"Aethelred","albumTitle":"Synapse_v.1",
 "catalogNumber":"SY98.02.45","label":"Millennium Beats Corp."}
```
''');

      expect(meta, isNotNull);
      expect(meta!.artistName, 'Aethelred');
      expect(meta.albumTitle, 'Synapse_v.1');
      expect(meta.catalogNumber, 'SY98.02.45');
      expect(meta.label, 'Millennium Beats Corp.');
    });

    test('reads bare json with no fence', () {
      final meta = AlbumMeta.tryParse(
        '{"artistName":"Krystalia","albumTitle":"Chrome//Wave",'
        '"catalogNumber":"745.98.02","label":"Glowtek"}',
      );

      expect(meta?.artistName, 'Krystalia');
      expect(meta?.albumTitle, 'Chrome//Wave');
    });

    test('finds the object when the model wraps it in prose', () {
      final meta = AlbumMeta.tryParse(
        'Here is the album identity you asked for:\n'
        '{"artistName":"Static Signal","albumTitle":"Circuit Breaker",'
        '"catalogNumber":"745.98.02","label":"Signal Rekords"}\n'
        'The artwork follows.',
      );

      expect(meta?.artistName, 'Static Signal');
      expect(meta?.label, 'Signal Rekords');
    });

    test('returns null when the model sent no text at all', () {
      expect(AlbumMeta.tryParse(''), isNull);
      expect(AlbumMeta.tryParse('   \n  '), isNull);
    });

    test('returns null rather than throwing on malformed json', () {
      expect(AlbumMeta.tryParse('{"artistName": "unterminated'), isNull);
      expect(AlbumMeta.tryParse('Here is your cover!'), isNull);
    });

    test('missing keys become empty strings, not nulls or crashes', () {
      final meta = AlbumMeta.tryParse('{"artistName":"Lyra"}');

      expect(meta?.artistName, 'Lyra');
      expect(meta?.albumTitle, '');
      expect(meta?.catalogNumber, '');
      expect(meta?.label, '');
    });
  });
}
````

```
flutter test
```

---

## Next

Step 2 puts a real photo in and takes the result out, with a file picker, a
camera page and a download.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| 0 | `00_starter` | the static sheet |
| **1** | **`01_state`** | **state and a stub service 📍** |
| 2 | `02_photo` | the photo: picker, camera, download |
| 3 | `03_model` | the model: Firebase AI Logic and Gemini |
| 4 | `04_sheet` | the sheet: responsive layout, press log, error panel |
| 5 | `05_design` | the look: theme, fonts, animations |

## Layout

```
lib/
  main.dart                     builds the controller, hands it to the page
  models/album_meta.dart        artist, title, catalog, label — and a parser
  services/
    nano_banana_service.dart    the stub, and the CoverDraft it returns
  state/cover_controller.dart   status, draft, error
  features/cover/
    cover_page.dart             one ListenableBuilder over the whole sheet
    widgets/                    masthead, plate, specs table, actions
assets/
  placeholder_cover.png         what the stub returns, until a model does
```
