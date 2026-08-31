# Nano Banana CD Cover: step 5, the design

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Where you are.** You finished the sheet in step 4 and fixed its rows and
measurements there. This step paints it, with a Riso palette, three typefaces
and the motion that makes a press look like a press.

This branch is the finished app. Start on `04_sheet` and follow along, or read
it here beside the result.

```
git checkout 04_sheet
```

## What you are building

Twenty-two files change. In nine of them you swap tokens and touch nothing
else: `Colors.black45` becomes `Press.inkAt(0.42)`, `TextStyle(fontSize: 11)`
becomes `Press.mono(size: 11)`. This page prints one of those in full and names
the other eight, to spare you the same substitution nine times.

The remaining thirteen gain a painter, a controller or a stateful widget, and
this page prints each of them in full.

You add one package, one theme file, one widget and seven looping animations.

---

## 1. The tokens

The colours, the typefaces and the graph-paper grid live in one file. No other
file in the app names a colour.

```yaml
  google_fonts: ^8.2.1
```

**New file `lib/theme/press_theme.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the proof-sheet look.
abstract final class Press {
  static const Color ink = Color(0xFF101C33);
  static const Color inkDeep = Color(0xFF0B1426);
  static const Color paper = Color(0xFFE4E7EA);
  static const Color paperLight = Color(0xFFF2F4FF);
  static const Color rule = Color(0xFFCCD3DA);
  static const Color blue = Color(0xFF2B3DF5);
  static const Color pink = Color(0xFFFF3D7F);

  static Color inkAt(double opacity) => ink.withValues(alpha: opacity);

  /// Monospace, wide-tracked — every label and spec value.
  static TextStyle mono({
    double size = 11,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double tracking = 0.16,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color ?? ink,
        fontWeight: weight,
        letterSpacing: size * tracking,
        height: 1.4,
      );

  /// Archivo Black, tight — headlines only.
  static TextStyle display(double size) => GoogleFonts.archivoBlack(
        fontSize: size,
        color: ink,
        letterSpacing: size * -0.035,
        height: 0.94,
      );

  static TextStyle body({double size = 15, Color? color}) => GoogleFonts.archivo(
        fontSize: size,
        color: color ?? inkAt(0.75),
        height: 1.5,
      );

  /// The sheet's ground.
  static Decoration get sheet => const BoxDecoration(color: paper);
}

/// Draws the 48px graph-paper grid behind the sheet.
class GridPainter extends CustomPainter {
  const GridPainter();

  static const double cell = 48;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Press.ink.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
```

Three faces, each with one job. JetBrains Mono carries the labels and spec
values, wide-tracked and upper-case. Archivo Black takes the headlines and
Archivo takes the body text. The tracking runs as a fraction of the size, so it
holds at any scale.

---

## 2. The substitution

The whole mechanical change, on the smallest file that has it.

**Replace `lib/features/cover/widgets/spec_row.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// A label/value row in the plate-specs table.
class SpecRow extends StatelessWidget {
  const SpecRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label.toUpperCase(),
              style: Press.mono(size: 11, color: Press.inkAt(0.5)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Press.mono(size: 12, tracking: 0.04),
            ),
          ),
        ],
      ),
    );
  }
}
```

Make that same edit in `cover_actions.dart`, `cover_masthead.dart`,
`cover_top_bar.dart`, `plate_specs.dart`, `press_status.dart`,
`progress_row.dart`, `proof_body.dart` and `server_response.dart`. Check the
branch out for those; they hold nothing you have yet to see.

`main.dart` swaps tokens too, and hands `MaterialApp` a seeded `ThemeData`.

---

## 3. The ground

The sheet sits on 48px graph paper, painted behind the whole page.

**Replace `lib/features/cover/cover_page.dart`:**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../state/cover_controller.dart';
import '../../theme/press_theme.dart';
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
      backgroundColor: Press.paper,
      body: CustomPaint(
        painter: const GridPainter(),
        child: ListenableBuilder(
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
      ),
    );
  }
}
```

---

## 4. Painted edges

You draw three borders that step 4 left plain: the dashed outline on the
secondary actions, the dashed fold down a plate, and the crop marks around the
artwork.

**Replace `lib/features/cover/widgets/dashed_action.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// Dashed-outline secondary action, e.g. "Upload a photo".
class DashedAction extends StatelessWidget {
  const DashedAction({
    required this.label,
    required this.onPressed,
    this.leading,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: onPressed,
        child: CustomPaint(
          painter: const _DashedBorderPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                Text(label.toUpperCase(), style: Press.mono(size: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Press.inkAt(0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dash = 5.0;
    const gap = 4.0;
    void line(Offset from, Offset to) {
      final total = (to - from).distance;
      final dir = (to - from) / total;
      var travelled = 0.0;
      while (travelled < total) {
        final end = (travelled + dash).clamp(0.0, total);
        canvas.drawLine(from + dir * travelled, from + dir * end, paint);
        travelled += dash + gap;
      }
    }

    line(Offset.zero, Offset(size.width, 0));
    line(Offset(size.width, 0), Offset(size.width, size.height));
    line(Offset(size.width, size.height), Offset(0, size.height));
    line(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
```

**Replace `lib/features/cover/widgets/plate_spine.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The dashed fold down the middle of a plate.
class PlateSpine extends StatelessWidget {
  const PlateSpine({this.highlight = true, super.key});

  /// The pressing plate catches light on the fold; the failed plate is flat.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 9,
      child: CustomPaint(
        painter: _SpinePainter(highlight: highlight),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SpinePainter extends CustomPainter {
  const _SpinePainter({required this.highlight});

  final bool highlight;

  static const double _segment = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()..color = Press.ink.withValues(alpha: 0.22);
    final light = Paint()..color = Colors.white.withValues(alpha: 0.2);
    for (var y = 0.0; y < size.height; y += _segment * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, _segment), dark);
      if (highlight) {
        canvas.drawRect(Rect.fromLTWH(0, y + _segment, size.width, 1), light);
      }
    }
  }

  @override
  bool shouldRepaint(_SpinePainter oldDelegate) =>
      oldDelegate.highlight != highlight;
}
```

**Replace `lib/features/cover/widgets/proof_frame.dart`:**

```dart
import 'dart:ui' as ui show Size;

import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

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
          child: Stack(
            children: [
              AspectRatio(aspectRatio: ratio, child: child),
              const Positioned.fill(child: IgnorePointer(child: _CropMarks())),
            ],
          ),
        ),
        // Off the plate: the model prints its own label in those corners.
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: DefaultTextStyle(
            style: Press.mono(size: 10, color: Press.inkAt(0.45)),
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
                Text('← $bleed →'),
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

/// Corner registration marks.
class _CropMarks extends StatelessWidget {
  const _CropMarks();

  static const double _len = 16;

  @override
  Widget build(BuildContext context) {
    Widget corner({required bool top, required bool left}) {
      final side = BorderSide(color: Press.inkAt(0.55));
      return Positioned(
        top: top ? -12 : null,
        bottom: top ? null : -12,
        left: left ? -12 : null,
        right: left ? null : -12,
        child: SizedBox(
          width: _len,
          height: _len,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: top ? side : BorderSide.none,
                bottom: top ? BorderSide.none : side,
                left: left ? side : BorderSide.none,
                right: left ? BorderSide.none : side,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        corner(top: true, left: true),
        corner(top: true, left: false),
        corner(top: false, left: true),
        corner(top: false, left: false),
      ],
    );
  }
}
```

The press button gains a plate offset behind it. That stack must not clip its
own children, because the plate sits outside the block.

**Replace `lib/features/cover/widgets/press_action.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

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

  /// After a failure the button inverts.
  final bool halted;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Stack(
        // The plate sits outside the block, so the stack must not clip.
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            right: -6,
            top: 6,
            bottom: -6,
            child: ColoredBox(color: halted ? Press.inkDeep : Press.pink),
          ),
          InkWell(
            onTap: onPressed,
            child: ColoredBox(
              color: halted ? Press.pink : Press.blue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style:
                            Press.display(26).copyWith(color: Press.paperLight),
                      ),
                    ),
                    if (trailing != null)
                      Text(
                        trailing!,
                        style: Press.mono(
                          size: 12,
                          color: Press.paperLight.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. The blinking markers

Two of them. The status dot in the top bar blinks once a run has halted, and
the marker under the press log blinks while one runs.

Both snap rather than fade. The controller runs without stopping and the widget
reads its value as a boolean, so the square sits on or off with no state in
between.

**Replace `lib/features/cover/widgets/status_dot.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// Blue and steady; pink and blinking once a run has halted.
class StatusDot extends StatefulWidget {
  const StatusDot({required this.halted, super.key});

  final bool halted;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.halted) _blink.repeat();
  }

  @override
  void didUpdateWidget(StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.halted && !_blink.isAnimating) {
      _blink.repeat();
    } else if (!widget.halted) {
      _blink
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: widget.halted ? Press.pink : Press.blue,
        shape: BoxShape.circle,
      ),
    );
    if (!widget.halted) return dot;
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, child) =>
          Opacity(opacity: _blink.value < 0.5 ? 1 : 0, child: child),
      child: dot,
    );
  }
}
```

**Replace `lib/features/cover/widgets/press_log.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

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
        Text(
          'PRESS LOG',
          style: Press.mono(size: 11, color: Press.inkAt(0.45), tracking: 0.22),
        ),
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
        if (halted) const _HaltedMarker() else const _RunningMarker(),
      ],
    );
  }
}

enum _RowState { done, running, failed, pending }

/// Darker than the pink accent, so it reads as failure not decoration.
const Color _halt = Color(0xFFC2185B);

class _LogRow extends StatelessWidget {
  const _LogRow({required this.label, required this.state});

  final String label;
  final _RowState state;

  @override
  Widget build(BuildContext context) {
    final (mark, colour) = switch (state) {
      _RowState.done => ('✓', Press.inkAt(0.45)),
      _RowState.running => ('▸', Press.blue),
      _RowState.failed => ('✕', _halt),
      _RowState.pending => ('·', Press.inkAt(0.28)),
    };
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            mark,
            textAlign: TextAlign.center,
            style: Press.mono(size: 11, color: colour),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: Press.mono(size: 11, color: colour, tracking: 0.1),
          ),
        ),
      ],
    );
  }
}

class _HaltedMarker extends StatelessWidget {
  const _HaltedMarker();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, color: Press.pink),
        const SizedBox(width: 8),
        Text(
          'PRESS HALTED',
          style: Press.mono(size: 11, color: _halt, tracking: 0.14),
        ),
      ],
    );
  }
}

class _RunningMarker extends StatefulWidget {
  const _RunningMarker();

  @override
  State<_RunningMarker> createState() => _RunningMarkerState();
}

class _RunningMarkerState extends State<_RunningMarker>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _blink,
          builder: (context, _) => Opacity(
            opacity: _blink.value < 0.5 ? 1 : 0,
            child: Container(width: 6, height: 6, color: Press.pink),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'PRESS RUNNING',
          style: Press.mono(size: 11, color: Press.inkAt(0.5), tracking: 0.14),
        ),
      ],
    );
  }
}
```

---

## 6. The plate under way

Three animations at once. A diagonal hatch drifts sideways, a highlight sweeps
across the plate, and a disc spins in the middle.

The painter draws the hatch as vertical bars on a rotated canvas, which costs
far less than computing diagonals. The sweep translates a gradient band from
-120% to 320% of its own width.

**Replace `lib/features/cover/widgets/pressing_plate.dart`:**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';
import 'plate_spine.dart';

/// The plate while a cover is being generated.
class PressingPlate extends StatefulWidget {
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
  State<PressingPlate> createState() => _PressingPlateState();
}

class _PressingPlateState extends State<PressingPlate>
    with TickerProviderStateMixin {
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    _sweep.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: Press.rule,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _drift,
              builder: (context, _) => CustomPaint(
                painter: _HatchPainter(phase: _drift.value),
              ),
            ),
            AnimatedBuilder(
              animation: _sweep,
              builder: (context, child) {
                final curved = Curves.easeInOut.transform(_sweep.value);
                return FractionalTranslation(
                  // -120% to 320% of the band's own width.
                  translation: Offset(-1.2 + curved * 4.4, 0),
                  child: child,
                );
              },
              child: FractionallySizedBox(
                widthFactor: 0.26,
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _spin,
                      builder: (context, _) => CustomPaint(
                        size: const Size.square(92),
                        painter: _DiscPainter(turns: _spin.value),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.stage.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Press.display(26).copyWith(height: 1.05),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PLATES ${widget.stageIndex + 1} OF ${widget.stageCount}',
                      style: Press.mono(size: 10, color: Press.inkAt(0.5)),
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

/// Diagonal hatch that slides sideways.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.phase});

  final double phase;

  static const double period = 28;
  static const double bandWidth = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Press.ink.withValues(alpha: 0.08);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // 135° stripes: drawn vertical, canvas rotated.
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    final extent = size.width + size.height;
    final offset = phase * period;
    for (var x = -extent + offset; x < extent; x += period) {
      canvas.drawRect(
        Rect.fromLTWH(x, -extent, bandWidth, extent * 2),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.phase != phase;
}

/// The spinning disc: track, two-tone arc, hub.
class _DiscPainter extends CustomPainter {
  const _DiscPainter({required this.turns});

  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2 - 1;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Press.ink.withValues(alpha: 0.16),
    );

    final rotation = turns * 2 * math.pi;
    void arc(double startFraction, Color colour) {
      canvas.drawArc(
        rect,
        rotation + startFraction * 2 * math.pi,
        math.pi / 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = colour,
      );
    }

    arc(-0.25, Press.blue);
    arc(0, Press.pink);

    canvas.drawCircle(centre, 13, Paint()..color = Press.paper);
    canvas.drawCircle(
      centre,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Press.ink.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) => oldDelegate.turns != turns;
}
```

The failed plate keeps that geometry and drops the motion. The run has
stopped, so the plate holds still.

**Replace `lib/features/cover/widgets/failed_plate.dart`:**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';
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
          color: Press.rule,
          border: Border.all(color: Press.pink),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _PinkHatchPainter()),
            const Align(
              alignment: Alignment.center,
              child: PlateSpine(highlight: false),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _WarningDiamond(),
                      const SizedBox(height: 18),
                      Text(
                        headline.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Press.display(26).copyWith(height: 1.05),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Press.mono(
                          size: 11,
                          color: Press.inkAt(0.55),
                          tracking: 0.14,
                        ).copyWith(height: 1.7),
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

/// Rotated square with an upright exclamation mark.
class _WarningDiamond extends StatelessWidget {
  const _WarningDiamond();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(border: Border.all(color: Press.pink, width: 2)),
        child: Center(
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Text(
              '!',
              style: Press.display(30).copyWith(color: Press.pink),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinkHatchPainter extends CustomPainter {
  const _PinkHatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Press.pink.withValues(alpha: 0.13);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    final extent = size.width + size.height;
    for (var x = -extent; x < extent; x += 28) {
      canvas.drawRect(Rect.fromLTWH(x, -extent, 12, extent * 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PinkHatchPainter oldDelegate) => false;
}
```

---

## 7. The disc

This is the one addition in the step that moves the layout as well as the
paint.

A CD slides out from behind the plate once a cover exists, and turns while it
sits there. Eject runs slow and eased-out, retract quicker and eased-in. That
asymmetry makes it read as a mechanism instead of a slide.

**New file `lib/features/cover/widgets/eject_disc.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The finished disc. Tap it to load it back in.
class EjectDisc extends StatefulWidget {
  const EjectDisc({
    required this.ejected,
    required this.onTap,
    required this.left,
    required this.reserve,
    this.size = 210,
    super.key,
  });

  final bool ejected;
  final VoidCallback onTap;
  final double size;

  /// Height of the strip reserved below the plate.
  final double reserve;

  /// From the plate's left edge. `Align` would drift as the disc grows.
  final double left;

  /// Fraction left protruding when ejected.
  static const double protrusion = 0.48;

  /// Disc diameter as a fraction of the plate width.
  static const double plateFraction = 0.42;

  /// Where the centre sits across the plate.
  static const double centreFraction = 0.725;

  @override
  State<EjectDisc> createState() => _EjectDiscState();
}

class _EjectDiscState extends State<EjectDisc> with TickerProviderStateMixin {
  /// Eject is slow and eased-out, retract quicker and eased-in.
  late final _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    reverseDuration: const Duration(milliseconds: 550),
  );

  late final _travel = CurvedAnimation(
    parent: _slide,
    curve: const Cubic(0.22, 0.9, 0.25, 1),
    reverseCurve: const Cubic(0.5, 0, 0.7, 0.3),
  );

  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void initState() {
    super.initState();
    if (widget.ejected) _slide.forward();
  }

  @override
  void didUpdateWidget(EjectDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ejected != oldWidget.ejected) {
      widget.ejected ? _slide.forward() : _slide.reverse();
    }
  }

  @override
  void dispose() {
    _travel.dispose();
    _slide.dispose();
    _spin.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _travel,
      builder: (context, child) {
        // Measured from the bottom of the reserved strip.
        final bottom = _lerp(
          widget.reserve + 0.01 * widget.size,
          0,
          _travel.value,
        );
        return Positioned(left: widget.left, bottom: bottom, child: child!);
      },
      child: SizedBox.square(
        dimension: widget.size,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: RotationTransition(
              turns: _spin,
              child: const _DiscFace(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Iridescent CD face.
class _DiscFace extends StatelessWidget {
  const _DiscFace();

  static const List<Color> _sheen = [
    Color(0xFFC9D2F5),
    Color(0xFFF4A6C8),
    Color(0xFFBFE6E0),
    Color(0xFFE8E2B8),
    Color(0xFFC9D2F5),
    Color(0xFFA8B4EE),
    Color(0xFFF0B7D3),
    Color(0xFFC9D2F5),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(colors: _sheen),
        boxShadow: [
          BoxShadow(
            color: Press.ink.withValues(alpha: 0.6),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final d = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: d * 0.48,
                height: d * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Press.paper.withValues(alpha: 0.9),
                  border: Border.all(color: Press.inkAt(0.18)),
                ),
              ),
              Container(
                width: d * 0.18,
                height: d * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Press.paper,
                  border: Border.all(color: Press.inkAt(0.3)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

The plate reserves a strip beneath itself for the half that protrudes. Flutter
paints out-of-bounds children under `Clip.none` and skips them when it
hit-tests, so a disc hanging past the edge of its stack would sit there visible
and dead to the touch.

**Replace `lib/features/cover/widgets/proof_panel.dart`:**

```dart
import 'package:flutter/material.dart';

import '../../../services/nano_banana_service.dart';
import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import 'eject_disc.dart';
import 'proof_body.dart';
import 'proof_frame.dart';

/// The plate, its furniture, and the disc behind it.
class ProofPanel extends StatefulWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  @override
  State<ProofPanel> createState() => _ProofPanelState();
}

class _ProofPanelState extends State<ProofPanel> {
  /// Out as soon as a cover lands; tap to load it back in.
  bool _discOut = true;

  CoverDraft? _lastDraft;

  void _toggle() => setState(() => _discOut = !_discOut);

  @override
  void initState() {
    super.initState();
    _lastDraft = widget.controller.draft;
  }

  @override
  void didUpdateWidget(ProofPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new run is a new disc.
    final draft = widget.controller.draft;
    if (!identical(draft, _lastDraft)) {
      _lastDraft = draft;
      if (draft?.image != null && !_discOut) {
        setState(() => _discOut = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final done = controller.status == CoverStatus.ready &&
        controller.draft?.image != null;

    Widget plate = DecoratedBox(
      decoration: BoxDecoration(
        color: Press.paperLight,
        border: Border.all(color: Press.inkAt(0.42)),
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

    if (done && !_discOut) {
      // Absorbs the tap, or it falls through to the disc and toggles twice.
      plate = GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: plate,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sized from the plate so the proportion holds at every width.
        final discSize = (constraints.maxWidth * EjectDisc.plateFraction)
            .clamp(180.0, 420.0);
        final reserve = discSize * EjectDisc.protrusion;

        return Stack(
          children: [
            // Behind the plate. Flutter never hit-tests out-of-bounds children,
            // so the reserved strip is what keeps the ejected half clickable.
            if (done)
              EjectDisc(
                ejected: _discOut,
                size: discSize,
                reserve: reserve,
                left: constraints.maxWidth * EjectDisc.centreFraction -
                    discSize / 2,
                onTap: _toggle,
              ),
            Padding(
              padding: EdgeInsets.only(bottom: done ? reserve : 0),
              child: plate,
            ),
          ],
        );
      },
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

| Do this | What you should see |
| --- | --- |
| Load the page | Ink on paper over a faint grid, JetBrains Mono on every label. |
| Press *Make the cover* | The hatch drifts, a highlight sweeps across the plate, the disc spins, and the press-log marker blinks. |
| Wait for the cover | A CD slides out from behind the plate and keeps turning. Click it to load it back in, click the plate to eject it again. |
| Let a run fail | The status dot turns pink and blinks. Everything else stops. |

---

## You are done

That is the whole app. You put a photo in, one call to Gemini comes back with
artwork and an identity, and the sheet prints both.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| 0 | `00_starter` | the static sheet |
| 1 | `01_state` | state and a stub service |
| 2 | `02_photo` | the photo: picker, camera, download |
| 3 | `03_model` | the model: Firebase AI Logic and Gemini |
| 4 | `04_sheet` | the sheet: responsive layout, press log, error panel |
| **5** | **`05_design`** | **the look: theme, fonts, animations 📍** |

## Layout

```
lib/
  theme/press_theme.dart               palette, type, the graph-paper grid
  features/cover/widgets/
    eject_disc.dart                    slides out, spins, reserves its strip
    pressing_plate.dart                drifting hatch, sweep, spinning ring
    status_dot.dart                    blinks once a run has halted
    press_log.dart                     its marker blinks while one runs
    dashed_action.dart                 a painted dashed border
    proof_frame.dart                   printer's crop marks
    plate_spine.dart                   the dashed fold
```
