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
