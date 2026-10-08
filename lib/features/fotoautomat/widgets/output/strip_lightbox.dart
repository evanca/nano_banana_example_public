import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../models/developed_strip.dart';
import '../controls/machine_button.dart';

/// Full-size viewer for a developed strip; four frames are small inline.
Future<void> showStripLightbox(
  BuildContext context,
  DevelopedStrip strip, {
  required VoidCallback onSave,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AutomatColors.recessed.withValues(alpha: 0.96),
    // States snap like relays; no fade.
    transitionDuration: Duration.zero,
    pageBuilder: (context, _, _) => _StripLightbox(strip: strip, onSave: onSave),
  );
}

class _StripLightbox extends StatelessWidget {
  const _StripLightbox({required this.strip, required this.onSave});

  final DevelopedStrip strip;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final close = Navigator.of(context).pop;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'STRIP · ${strip.style.label} · SCROLL OR PINCH TO ZOOM',
                    style: AutomatText.labelMd,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MachineButton(label: 'DOWNLOAD', icon: Icons.download, onPressed: onSave),
                const SizedBox(width: 8),
                MachineButton(label: 'CLOSE', icon: Icons.close, onPressed: close),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.memory(
                    strip.bytes,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: '${strip.style.label} photo strip, full size',
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
