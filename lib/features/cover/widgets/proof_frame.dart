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
