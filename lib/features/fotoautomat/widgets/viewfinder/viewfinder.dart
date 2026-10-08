import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../logic/booth_state.dart';
import '../controls/machine_button.dart';
import 'reticle_painter.dart';
import 'viewfinder_osd.dart';

/// Countersunk 4:5 aperture holding the live feed and its reticle.
class Viewfinder extends StatelessWidget {
  const Viewfinder({
    super.key,
    required this.state,
    required this.controller,
    required this.onPowerOn,
  });

  final BoothState state;
  final CameraController? controller;
  final VoidCallback onPowerOn;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final live = state.camera == CameraStatus.ready && controller != null;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: AutomatColors.recessed,
          border: Border.all(color: AutomatColors.black, width: 2),
        ),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The web video element is styled object-fit: cover, so it
              // fills the aperture without a Flutter-side aspect box.
              if (live) controller.buildPreview() else _Offline(state: state, onPowerOn: onPowerOn),
              IgnorePointer(
                child: CustomPaint(
                  painter: ReticlePainter(
                    bracketColor: live ? AutomatColors.acid : AutomatColors.reticle,
                  ),
                ),
              ),
              IgnorePointer(child: ViewfinderOsd(state: state)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline({required this.state, required this.onPowerOn});

  final BoothState state;
  final VoidCallback onPowerOn;

  @override
  Widget build(BuildContext context) {
    final starting = state.camera == CameraStatus.starting;
    final error = state.cameraError;
    // After a session the optics are parked, not broken.
    final parked = state.phase != BoothPhase.idle && error == null && !starting;
    final title = starting
        ? 'ARMING OPTICS'
        : parked
        ? 'OPTICS PARKED'
        : 'OPTICS OFFLINE';
    final body =
        error ??
        switch (state.phase) {
          BoothPhase.developing => 'Camera is off while the darkroom works.',
          BoothPhase.developed ||
          BoothPhase.failed => 'Camera is off. Retake to re-arm the optics.',
          _ => 'The booth needs your camera. Frames stay in this browser until you develop them.',
        };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center, style: AutomatText.headlineMd),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AutomatText.bodySm.copyWith(
                color: error == null ? AutomatColors.halftone : AutomatColors.amber,
              ),
            ),
            if (state.phase != BoothPhase.developing) ...[
              const SizedBox(height: 20),
              MachineButton(
                label: error != null
                    ? 'RETRY'
                    : parked
                    ? 'RETAKE'
                    : 'POWER ON',
                icon: parked ? Icons.replay : Icons.power_settings_new,
                onPressed: starting ? null : onPowerOn,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
