import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../logic/booth_state.dart';
import '../chassis/led.dart';

/// On-screen display: tally light, frame index, exposure telemetry and the
/// oversized countdown.
class ViewfinderOsd extends StatelessWidget {
  const ViewfinderOsd({super.key, required this.state});

  final BoothState state;

  @override
  Widget build(BuildContext context) {
    final exposing = state.phase == BoothPhase.exposing;
    final live = state.camera == CameraStatus.ready;
    final frame = exposing
        ? (state.frames.length + 1).clamp(1, BoothState.frameTotal)
        : state.frames.length;
    final label = AutomatText.labelMd.copyWith(color: AutomatColors.paper);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Led(
                  on: live,
                  color: exposing ? AutomatColors.amber : AutomatColors.acid,
                  blink: exposing,
                  round: true,
                  size: 10,
                ),
                const SizedBox(width: 8),
                Text(
                  exposing
                      ? 'REC'
                      : live
                      ? 'LIVE'
                      : 'STBY',
                  style: label,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'FRAME: ${frame.toString().padLeft(2, '0')}/0${BoothState.frameTotal}',
              style: label,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'X: 00  Y: 00\nEXP 1/125 · f/2.8',
              style: AutomatText.labelSm.copyWith(color: AutomatColors.reticle),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'ISO ${state.style.iso}\n4:5 · ${state.style.label}',
              textAlign: TextAlign.right,
              style: AutomatText.labelSm.copyWith(color: AutomatColors.reticle),
            ),
          ),
          if (state.countdown case final n?)
            Center(child: Text('$n', style: AutomatText.countdown)),
        ],
      ),
    );
  }
}
