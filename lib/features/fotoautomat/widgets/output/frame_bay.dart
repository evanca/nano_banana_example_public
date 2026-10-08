import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../logic/booth_state.dart';

/// Four exposure slots. In the darkroom the frames turn into negatives.
class FrameBay extends StatelessWidget {
  const FrameBay({super.key, required this.frames, this.negative = false});

  final List<Uint8List> frames;
  final bool negative;

  static const _invert = ColorFilter.matrix([
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < BoothState.frameTotal; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _slot(i)),
        ],
      ],
    );
  }

  Widget _slot(int i) {
    final frame = i < frames.length ? frames[i] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            decoration: BoxDecoration(
              color: AutomatColors.recessed,
              border: Border.all(color: AutomatColors.black, width: 2),
            ),
            alignment: Alignment.center,
            child: frame == null
                ? Text('+', style: AutomatText.labelLg.copyWith(color: AutomatColors.slate))
                : _print(frame),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${negative ? 'NEG' : 'FR'} ${(i + 1).toString().padLeft(2, '0')}',
          style: AutomatText.labelSm.copyWith(
            color: frame == null ? AutomatColors.slate : AutomatColors.halftone,
          ),
        ),
      ],
    );
  }

  Widget _print(Uint8List frame) {
    final image = Image.memory(
      frame,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    );
    return negative ? ColorFiltered(colorFilter: _invert, child: image) : image;
  }
}
