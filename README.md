# Nano Banana CD Cover: step 4, the sheet

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Where you are.** You have replaced the single column. Past 900px the sheet
splits into specs on the left and the plate with its controls on the right, a
press log walks the run stage by stage, and a failure gets its own plate
alongside the raw server response.

You style none of it. The stock Material theme and Flutter's default font at
plain sizes leave the structure as the one thing on screen.

This branch is the finished step. Start on `03_model` and follow along, or read
it here beside the result.

```
git checkout 03_model
```

## What you are building

Step 3 finished the machine. It generates a real cover from a real photo, and
for twelve seconds it shows you a grey box that says GENERATING.

You spend this step on those twelve seconds, and on what the sheet says when a
run goes wrong. You add ten widgets, change ten more, and give the controller
the state that drives most of them.

This is the last step before the theme, so you fix each measurement here. Step
5 adds paint on top.

---

## 1. Narrate the run

The API reports no progress. You get no stream and no percentage: a request
goes out and twelve seconds later a picture comes back.

So you pace the log on a timer, which makes it theatre rather than telemetry.
It stops advancing at the last stage instead of claiming a completion the model
has yet to report, and the stage it halts on marks where your own clock reached,
which says nothing about Gemini.

**Replace `lib/state/cover_controller.dart`:**

```dart
import 'dart:async';

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

  /// Stages the press log walks through.
  ///
  /// Theatre, not telemetry — the API reports no progress.
  static const List<String> pressStages = [
    'Photo received',
    'Reading the faces',
    'Cutting mask',
    'Setting the type',
    'Imposing spread',
    'Proofing',
  ];

  static const Duration _stageDuration = Duration(seconds: 2);

  /// Longest edge the selfie is scaled to before being sent.
  static const double _maxSelfieEdge = 1280;

  Timer? _pressTimer;
  int _pressStage = 0;

  /// Which stage the log is showing.
  int get pressStage => _pressStage;

  /// Stage the run halted on, or null if it has not failed.
  int? _failedStage;
  int? get failedStage => _failedStage;

  DateTime? _failedAt;
  DateTime? get failedAt => _failedAt;

  /// How many times this selfie has been sent.
  int _attempt = 0;
  int get attempt => _attempt;

  void _startPressLog() {
    _pressStage = 0;
    _pressTimer?.cancel();
    _pressTimer = Timer.periodic(_stageDuration, (timer) {
      if (_pressStage >= pressStages.length - 1) {
        timer.cancel();
        return;
      }
      _pressStage++;
      notifyListeners();
    });
  }

  void _stopPressLog() {
    _pressTimer?.cancel();
    _pressTimer = null;
  }

  @override
  void dispose() {
    _stopPressLog();
    super.dispose();
  }

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
      _resetRun();
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
    _resetRun();
    notifyListeners();
  }

  /// A new photo starts a fresh run.
  void _resetRun() {
    _attempt = 0;
    _failedStage = null;
    _failedAt = null;
  }

  Future<void> generate() async {
    final selfie = _selfie;
    if (selfie == null || isBusy) return;

    _status = CoverStatus.generating;
    _error = null;
    _draft = null;
    _failedStage = null;
    _failedAt = null;
    _attempt++;
    _style = CoverStyle.random();
    debugPrint('Cover style: ${_style!.name}');
    _startPressLog();
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
      _failedStage = _pressStage;
      _failedAt = DateTime.now().toUtc();
    } finally {
      _stopPressLog();
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

`_attempt` counts sends of the current photo and resets when you load another
one. Failures belong to the photo that produced them.

---

## 2. Split the sheet

You add one breakpoint, and the column layout you already have serves as the
narrow case.

**Replace `lib/features/cover/cover_layout.dart`:**

```dart
/// Layout constants shared by the cover sheet and its widgets.
abstract final class CoverLayout {
  /// Below this the sheet stacks into one column.
  static const double wideBreakpoint = 900;

  /// The sheet stops growing past this.
  static const double maxSheetWidth = 1240;
}
```

Above 900px the specs take the left column and the plate takes the right, with
the controls stacked under the plate rather than running the full width of the
sheet. They belong to the plate, not to the page.

**Replace `lib/features/cover/cover_page.dart`:**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import '../camera/camera_page.dart';
import 'cover_layout.dart';
import 'widgets/cover_actions.dart';
import 'widgets/cover_masthead.dart';
import 'widgets/cover_top_bar.dart';
import 'widgets/plate_specs.dart';
import 'widgets/proof_panel.dart';

/// The proof sheet: specs on the left, the printed spread on the right.
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
              CoverTopBar(controller: controller),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CoverLayout.maxSheetWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoverMasthead(controller: controller),
                        const SizedBox(height: 40),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final specs = PlateSpecs(controller: controller);
                            final actions = CoverActions(
                              controller: controller,
                              onTakeSelfie: () => _takeSelfie(context),
                            );
                            final proof = ProofPanel(controller: controller);

                            if (constraints.maxWidth <
                                CoverLayout.wideBreakpoint) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  proof,
                                  const SizedBox(height: 32),
                                  specs,
                                  const SizedBox(height: 32),
                                  actions,
                                ],
                              );
                            }
                            // The controls belong to the plate, not the sheet.
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 4, child: specs),
                                const SizedBox(width: 48),
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      proof,
                                      const SizedBox(height: 28),
                                      actions,
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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

## 3. The strip along the top

Identity on the left, plate dimensions on the right. The dimensions come from
the artwork the model returned, so before a run the bar has nothing to report
and prints dashes instead of inventing a number.

**New file `lib/features/cover/widgets/status_dot.dart`:**

```dart
import 'package:flutter/material.dart';

/// The state dot. Filled once a run has halted.
class StatusDot extends StatelessWidget {
  const StatusDot({required this.halted, super.key});

  final bool halted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: halted ? Colors.black : null,
        border: Border.all(color: Colors.black),
        shape: BoxShape.circle,
      ),
    );
  }
}
```

**New file `lib/features/cover/widgets/cover_top_bar.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'status_dot.dart';

/// Press masthead strip: identity left, plate specs right.
class CoverTopBar extends StatelessWidget {
  const CoverTopBar({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.draft?.pixelSize;
    // Em dashes until a plate exists — never claim a size we have not made.
    final dimensions = size == null
        ? '— × — PX'
        : '${size.width.toInt()} × ${size.height.toInt()} PX';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 11),
        child: Row(
          children: [
            StatusDot(halted: controller.failedStage != null),
            const SizedBox(width: 10),
            const Text('Nano Banana'),
            const SizedBox(width: 8),
            const Flexible(
              child: Text('/ CD Cover Press', overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Text(dimensions),
            const SizedBox(width: 24),
            const Text('300 DPI'),
            const SizedBox(width: 24),
            const Text('V2.4'),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. The press log

Three row states: done, running, and not yet. A fourth appears when a run
halts, and the marker underneath changes with it.

**New file `lib/features/cover/widgets/press_log.dart`:**

```dart
import 'package:flutter/material.dart';

/// The press log, shown while a cover is generating.
class PressLog extends StatelessWidget {
  const PressLog({
    required this.stages,
    required this.currentIndex,
    this.halted = false,
    super.key,
  });

  final List<String> stages;
  final int currentIndex;

  /// Where the run stopped, rather than where it has got to.
  final bool halted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRESS LOG', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 12),
        for (final (index, stage) in stages.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _LogRow(
              label: stage,
              state: switch (index) {
                _ when index < currentIndex => _RowState.done,
                _ when index == currentIndex && halted => _RowState.failed,
                _ when index == currentIndex => _RowState.running,
                _ => _RowState.pending,
              },
            ),
          ),
        const SizedBox(height: 4),
        _Marker(label: halted ? 'PRESS HALTED' : 'PRESS RUNNING'),
      ],
    );
  }
}

enum _RowState { done, running, failed, pending }

class _LogRow extends StatelessWidget {
  const _LogRow({required this.label, required this.state});

  final String label;
  final _RowState state;

  @override
  Widget build(BuildContext context) {
    final mark = switch (state) {
      _RowState.done => '✓',
      _RowState.running => '▸',
      _RowState.failed => '✕',
      _RowState.pending => '·',
    };
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            mark,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// Square and label under the log.
class _Marker extends StatelessWidget {
  const _Marker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, color: Colors.black),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
```

With no run in flight there is no log to show, so the same slot holds a
one-line status.

**New file `lib/features/cover/widgets/press_status.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// One-line press state, when no run is in flight or halted.
class PressStatus extends StatelessWidget {
  const PressStatus({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final label = switch (controller.status) {
      CoverStatus.generating => 'On press',
      CoverStatus.ready => 'Booth ready',
      CoverStatus.error => 'Plate error',
      CoverStatus.idle when controller.hasSelfie => 'Ready to print',
      CoverStatus.idle => 'Awaiting selfie',
    };
    return Row(
      children: [
        Container(width: 8, height: 8, color: Colors.black),
        const SizedBox(width: 10),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
```

---

## 5. The plate while it runs

A fold down the middle, a disc, the stage name and a count.

**New file `lib/features/cover/widgets/plate_spine.dart`:**

```dart
import 'package:flutter/material.dart';

/// The fold down the middle of a plate.
class PlateSpine extends StatelessWidget {
  const PlateSpine({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 9,
      child: ColoredBox(color: Colors.black26, child: SizedBox.expand()),
    );
  }
}
```

**New file `lib/features/cover/widgets/pressing_plate.dart`:**

```dart
import 'package:flutter/material.dart';

import 'plate_spine.dart';

/// The plate while a cover is being generated.
class PressingPlate extends StatelessWidget {
  const PressingPlate({
    required this.stage,
    required this.stageIndex,
    required this.stageCount,
    super.key,
  });

  /// Current stage label.
  final String stage;

  /// Zero-based position of [stage].
  final int stageIndex;

  final int stageCount;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: Colors.black12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black45, width: 2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      stage.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PLATES ${stageIndex + 1} OF $stageCount',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. The plate when it halts

Same geometry, opposite meaning.

**New file `lib/features/cover/widgets/failed_plate.dart`:**

```dart
import 'package:flutter/material.dart';

import 'plate_spine.dart';

/// The plate when a run halts.
class FailedPlate extends StatelessWidget {
  const FailedPlate({
    required this.headline,
    required this.detail,
    super.key,
  });

  /// e.g. "Plate 3 failed".
  final String headline;

  /// The real failure text.
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black12,
          border: Border.all(color: Colors.black),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Text('!', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        headline.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Under the plate, the failure itself. The mockup behind this design shows an
HTTP status and a JSON error body, and both would be fiction here. A status
code and a `"retryable": true` flag would look precise while you invented them.
The panel prints what the service threw.

**New file `lib/features/cover/widgets/server_response.dart`:**

```dart
import 'package:flutter/material.dart';

/// The raw failure, shown verbatim.
class ServerResponse extends StatelessWidget {
  const ServerResponse({required this.body, required this.at, super.key});

  final String body;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Row(
              children: [
                const Text('SERVER RESPONSE', style: TextStyle(fontSize: 11)),
                const Spacer(),
                if (at != null)
                  Text(_stamp(at!), style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              body,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static String _stamp(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(at.day)} ${_months[at.month - 1]} ${at.year} · '
        '${two(at.hour)}:${two(at.minute)}:${two(at.second)} UTC';
  }

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
}
```

---

## 7. The frame around the artwork

Crop marks, a caption, a bleed callout. The frame takes its aspect ratio from
the decoded artwork, so nothing here hardcodes 2:1.

**New file `lib/features/cover/widgets/proof_frame.dart`:**

```dart
import 'dart:ui' as ui show Size;

import 'package:flutter/material.dart';

/// The artwork at its own aspect ratio, not an assumed one.
class ProofFrame extends StatelessWidget {
  const ProofFrame({
    required this.child,
    required this.pixelSize,
    this.caption,
    this.rightNote,
    super.key,
  });

  final Widget child;

  /// Intrinsic size of the artwork, or null before anything is generated.
  final ui.Size? pixelSize;

  final String? caption;
  final String? rightNote;

  /// Printer's bleed callout. Describes the plate, not the artwork.
  static const String bleed = '242 MM BLEED';

  /// Placeholder shape while there is nothing to measure.
  static const double _placeholderRatio = 2;

  @override
  Widget build(BuildContext context) {
    final ratio = switch (pixelSize) {
      final s? when s.height > 0 => s.width / s.height,
      _ => _placeholderRatio,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: AspectRatio(aspectRatio: ratio, child: child),
        ),
        // Off the plate: the model prints its own label in those corners.
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 10),
            child: Row(
              children: [
                if (caption != null) ...[
                  Flexible(
                    child: Text(
                      caption!.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
                const Text('← $bleed →'),
                const Spacer(),
                if (rightNote != null) Text(rightNote!.toUpperCase()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

**Replace `lib/features/cover/widgets/proof_panel.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'proof_body.dart';
import 'proof_frame.dart';

/// The plate and its furniture. No eject disc — that is pure animation.
class ProofPanel extends StatelessWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
      ),
      child: ProofFrame(
        pixelSize: controller.draft?.pixelSize,
        caption: controller.failedStage != null
            ? 'Spread — not imposed'
            : 'Spread — back / front',
        rightNote: 'CMYK · uncoated',
        child: ProofBody(controller: controller),
      ),
    );
  }
}
```

**Replace `lib/features/cover/widgets/proof_body.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'failed_plate.dart';
import 'pressing_plate.dart';

/// What sits inside the proof frame.
class ProofBody extends StatelessWidget {
  const ProofBody({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status == CoverStatus.generating) {
      final index = controller.pressStage;
      return PressingPlate(
        stage: CoverController.pressStages[index],
        stageIndex: index,
        stageCount: CoverController.pressStages.length,
      );
    }
    if (controller.failedStage case final failed?) {
      return FailedPlate(
        headline: 'Plate ${failed + 1} failed — nothing printed',
        detail: controller.error ?? 'The run stopped without a reason.',
      );
    }
    final art = controller.draft?.image ?? controller.selfie;
    if (art == null) {
      return const ColoredBox(
        color: Colors.black12,
        child: Center(
          child: Text('AWAITING SELFIE', style: TextStyle(fontSize: 12)),
        ),
      );
    }
    // Contain, never cover: a portrait selfie would be cropped in half.
    return ColoredBox(
      color: Colors.black12,
      child: Image.memory(art, fit: BoxFit.contain),
    );
  }
}
```

The furniture stays off the plate. A caption over the artwork looks better in
a mockup with empty corners, and the prompt asks the model to print a label and
a copyright line on that part of the back panel, so the two collide.

---

## 8. Specs and masthead follow the run

The specs table gains the log beneath it, and the masthead's headline, job
line and blurb change while the press runs.

**Replace `lib/features/cover/widgets/plate_specs.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'press_log.dart';
import 'press_status.dart';
import 'spec_row.dart';

/// The specs table, with the press log or status line beneath it.
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
        const SizedBox(height: 22),
        if (controller.isBusy)
          PressLog(
            stages: CoverController.pressStages,
            currentIndex: controller.pressStage,
          )
        else if (controller.failedStage case final failed?)
          PressLog(
            stages: CoverController.pressStages,
            currentIndex: failed,
            halted: true,
          )
        else
          PressStatus(controller: controller),
      ],
    );
  }
}

extension on String {
  String orIfEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
```

**Replace `lib/features/cover/widgets/cover_masthead.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../cover_layout.dart';

/// Job line, headline and blurb — all three change while the press runs.
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
        LayoutBuilder(
          builder: (context, constraints) {
            final size = (constraints.maxWidth * 0.07).clamp(44.0, 86.0);
            final headline = Text(
              pressing ? 'PRINTING\nYOUR COVER' : 'MAKE THE\nCOVER',
              style: TextStyle(fontSize: size),
            );
            final blurb = Text(
              pressing
                  ? 'Nano Banana is reading the photo, naming the act and '
                        'setting the type. Sit tight — the whole spread lands '
                        'in one piece.'
                  : 'Step into the booth, solo or with the whole crew. Nano '
                        'Banana reads the photo, invents the act, writes the '
                        'tracklist and prints a full jewel-case spread — '
                        'front, spine and back.',
              style: const TextStyle(fontSize: 15),
            );

            if (constraints.maxWidth < CoverLayout.wideBreakpoint) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headline,
                  const SizedBox(height: 18),
                  blurb,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(flex: 5, child: headline),
                const SizedBox(width: 48),
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: blurb,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
```

---

## 9. The controls

The press button inverts after a failure and offers the attempt number. A
dotted line at the foot fills as the run progresses.

**Replace `lib/features/cover/widgets/press_action.dart`:**

```dart
import 'package:flutter/material.dart';

/// The primary press action.
class PressAction extends StatelessWidget {
  const PressAction({
    required this.label,
    required this.onPressed,
    this.trailing,
    this.halted = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailing;

  /// Unused here: only colours changed with it.
  final bool halted;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**New file `lib/features/cover/widgets/progress_row.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// Dotted run-out line plus the current press state.
class ProgressRow extends StatelessWidget {
  const ProgressRow({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final (label, filled) = switch (controller.status) {
      CoverStatus.generating => ('On press', 0.55),
      CoverStatus.ready => ('Plate ready', 1.0),
      CoverStatus.error => ('Plate error', 0.0),
      CoverStatus.idle when controller.hasSelfie => ('Ready to print', 0.25),
      CoverStatus.idle => ('Awaiting selfie', 0.0),
    };
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 9.0;
              final count = (constraints.maxWidth / spacing).floor();
              final lit = (count * filled).round();
              return Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: spacing - 2),
                      child: Container(
                        width: 2,
                        height: 2,
                        color: i < lit ? Colors.black : Colors.black26,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
```

**Replace `lib/features/cover/widgets/cover_actions.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'dashed_action.dart';
import 'press_action.dart';
import 'progress_row.dart';
import 'server_response.dart';

/// Everything below the plate: failure, inputs, press, download.
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
    final halted = controller.failedStage != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (halted && controller.error != null) ...[
          ServerResponse(body: controller.error!, at: controller.failedAt),
          const SizedBox(height: 22),
        ],
        Row(
          children: [
            Expanded(
              child: DashedAction(
                label: halted ? 'Use another photo' : 'Upload a photo',
                onPressed: busy ? null : controller.uploadSelfie,
                leading: const Icon(Icons.arrow_upward, size: 14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashedAction(
                label: halted ? 'Take a new selfie' : 'Take a selfie',
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
          label: halted ? 'Run it again' : 'Make the cover',
          halted: halted,
          trailing: halted ? 'ATTEMPT ${controller.attempt + 1}' : '~12 sec',
          onPressed: busy || !controller.hasSelfie ? null : controller.generate,
        ),
        const SizedBox(height: 22),
        DashedAction(
          label: 'Download spread',
          onPressed:
              controller.draft?.image == null ? null : controller.saveCover,
          leading: const Icon(Icons.arrow_downward, size: 14),
        ),
        const SizedBox(height: 18),
        ProgressRow(controller: controller),
      ],
    );
  }
}
```

`lib/main.dart` picks up a doc comment in this step and is otherwise unchanged.

---

## Run it

```
flutter pub get
flutter run -d chrome
```

| Do this | What you should see |
| --- | --- |
| Widen the window past 900px | The sheet splits. Specs left, plate and controls right. |
| Press *Make the cover* | The log walks its six stages, the plate names the current one, and the run-out line fills. |
| Let it fail | The plate turns into the failure plate, the log crosses out the stage it stopped on, and the raw error prints underneath. |
| Press *Run it again* | The button offers the attempt number. Load a different photo and the count resets. |

To reach the failure path without waiting for a real one, take the project off
Blaze for a moment, or point `defaultModel` at a name that does not exist.

---

## Next

Step 5 is the look: the Riso palette, JetBrains Mono and Archivo Black, and
seven animations. The hatch drifts, a highlight sweeps the plate, a disc spins,
two markers blink, and a CD ejects from behind the plate.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| 0 | `00_starter` | the static sheet |
| 1 | `01_state` | state and a stub service |
| 2 | `02_photo` | the photo: picker, camera, download |
| 3 | `03_model` | the model: Firebase AI Logic and Gemini |
| **4** | **`04_sheet`** | **the sheet: responsive layout, press log, error panel 📍** |
| 5 | `05_design` | the look: theme, fonts, animations |

## Layout

```
lib/features/cover/
  cover_layout.dart          the breakpoint and the page cap
  cover_page.dart            one column below 900px, two above
  widgets/
    cover_top_bar.dart       identity, plate dimensions, status dot
    press_log.dart           done / running / failed / pending
    press_status.dart        the one-liner when no run is in flight
    pressing_plate.dart      what the plate shows mid-run
    failed_plate.dart        what it shows when the run halts
    server_response.dart     the failure, verbatim
    proof_frame.dart         crop marks, caption, bleed callout
    progress_row.dart        the dotted run-out line
```
