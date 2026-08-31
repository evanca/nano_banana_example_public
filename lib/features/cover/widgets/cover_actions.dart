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
