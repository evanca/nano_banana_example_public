import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../logic/booth_state.dart';
import '../../models/developed_strip.dart';
import '../controls/machine_button.dart';
import 'darkroom_progress.dart';
import 'frame_bay.dart';
import 'strip_lightbox.dart';

/// What comes out of the machine: frames, darkroom progress, the strip.
class OutputBay extends StatelessWidget {
  const OutputBay({
    super.key,
    required this.state,
    required this.onSave,
    required this.onRetake,
    required this.onRedevelop,
  });

  final BoothState state;
  final VoidCallback onSave;
  final VoidCallback onRetake;
  final VoidCallback onRedevelop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (state.phase) {
        BoothPhase.idle || BoothPhase.exposing => [
          FrameBay(frames: state.frames),
          const SizedBox(height: 12),
          Text('4 FRAMES → 1 STRIP · ~30 S IN THE DARKROOM', style: AutomatText.labelSm),
        ],
        BoothPhase.developing => [
          FrameBay(frames: state.frames, negative: true),
          const SizedBox(height: 16),
          DarkroomProgress(stage: state.stage, startedAt: state.developStartedAt),
        ],
        BoothPhase.developed => [
          if (state.strip case final strip?) ...[
            _Strip(strip: strip, onOpen: () => _open(context, strip)),
            const SizedBox(height: 16),
            _Receipt(strip: strip),
          ],
          const SizedBox(height: 16),
          _actions(context, save: true),
        ],
        BoothPhase.failed => [
          Text('FAULT', style: AutomatText.labelMd.copyWith(color: AutomatColors.amber)),
          const SizedBox(height: 8),
          Text(state.error ?? 'Unknown fault.', style: AutomatText.bodySm),
          const SizedBox(height: 16),
          _actions(context, save: false),
        ],
      },
    );
  }

  void _open(BuildContext context, DevelopedStrip strip) =>
      showStripLightbox(context, strip, onSave: onSave);

  Widget _actions(BuildContext context, {required bool save}) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      if (save && state.strip != null)
        MachineButton(
          label: 'FULL SIZE',
          icon: Icons.open_in_full,
          onPressed: () => _open(context, state.strip!),
        ),
      if (save) MachineButton(label: 'DOWNLOAD', icon: Icons.download, onPressed: onSave),
      MachineButton(label: 'RETAKE', icon: Icons.replay, onPressed: onRetake),
      if (state.canRedevelop)
        MachineButton(
          label: 'REDEVELOP',
          icon: Icons.autorenew,
          onPressed: onRedevelop,
          tooltip: 'Same frames, new generation (billed again)',
        ),
    ],
  );
}

class _Strip extends StatelessWidget {
  const _Strip({required this.strip, required this.onOpen});

  final DevelopedStrip strip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 720),
        child: AspectRatio(
          aspectRatio: strip.aspectRatio ?? 9 / 16,
          child: DecoratedBox(
            decoration: const BoxDecoration(boxShadow: AutomatColors.mediaShadow),
            child: MouseRegion(
              cursor: SystemMouseCursors.zoomIn,
              child: GestureDetector(
                onTap: onOpen,
                child: Image.memory(
                  strip.bytes,
                  fit: BoxFit.contain,
                  semanticLabel: '${strip.style.label} photo strip, tap for full size',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thermal printout under the strip.
class _Receipt extends StatelessWidget {
  const _Receipt({required this.strip});

  final DevelopedStrip strip;

  @override
  Widget build(BuildContext context) {
    final style = strip.style;
    final ink = AutomatText.labelSm.copyWith(color: AutomatColors.chassis);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AutomatColors.paper,
        boxShadow: AutomatColors.mediaShadow,
      ),
      child: Text(
        [
          'AUTOMAT_BER_09',
          'UNIX ${strip.developedAt.millisecondsSinceEpoch ~/ 1000}',
          'STYLE ${style.label} · ISO ${style.iso}',
          'GRAIN σ${style.grain} · CONTRAST γ${style.gamma}',
          'MODEL ${strip.model}',
          if (strip.labNote case final note?) '\n"$note"',
        ].join('\n'),
        style: ink,
      ),
    );
  }
}
