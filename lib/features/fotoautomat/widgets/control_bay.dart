import 'package:flutter/material.dart';

import '../logic/booth_state.dart';
import '../models/strip_style.dart';
import 'controls/relay_toggle.dart';
import 'controls/shutter_button.dart';
import 'controls/style_selector.dart';

/// Style selector, relays and the shutter trigger.
class ControlBay extends StatelessWidget {
  const ControlBay({
    super.key,
    required this.state,
    required this.onStyle,
    required this.onFlash,
    required this.onSound,
    required this.onShoot,
  });

  final BoothState state;
  final ValueChanged<StripStyle> onStyle;
  final VoidCallback onFlash;
  final VoidCallback onSound;
  final VoidCallback onShoot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyleSelector(selected: state.style, onSelected: state.isBusy ? null : onStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RelayToggle(label: 'XENON', on: state.flashEnabled, onPressed: onFlash),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RelayToggle(label: 'SOUND', on: state.soundEnabled, onPressed: onSound),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ShutterButton(
          label: 'AUSLÖSEN',
          caption: switch (state.phase) {
            BoothPhase.exposing => 'HOLD STILL',
            BoothPhase.developing => 'DEVELOPING…',
            _ when state.camera == CameraStatus.ready => 'RELEASE SHUTTER · SPACE',
            BoothPhase.idle => 'POWER ON THE OPTICS FIRST',
            _ => 'RETAKE TO RE-ARM THE OPTICS',
          },
          onPressed: state.canShoot ? onShoot : null,
        ),
      ],
    );
  }
}
