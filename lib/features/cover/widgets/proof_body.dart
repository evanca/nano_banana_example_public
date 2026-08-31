import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import 'failed_plate.dart';
import 'pressing_plate.dart';

/// What sits inside the proof frame.
class ProofBody extends StatelessWidget {
  const ProofBody({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status == CoverStatus.generating) {
      final index = controller.pressStage;
      return PressingPlate(
        stage: CoverController.pressStages[index],
        stageIndex: index,
        stageCount: CoverController.pressStages.length,
      );
    }
    if (controller.failedStage case final failed?) {
      return FailedPlate(
        headline: 'Plate ${failed + 1} failed — nothing printed',
        detail: controller.error ?? 'The run stopped without a reason.',
      );
    }
    final art = controller.draft?.image ?? controller.selfie;
    if (art == null) {
      return ColoredBox(
        color: Press.inkAt(0.04),
        child: Center(
          child: Text(
            'AWAITING SELFIE',
            style: Press.mono(size: 12, color: Press.inkAt(0.4)),
          ),
        ),
      );
    }
    // Contain, never cover: a portrait selfie would be cropped in half.
    return ColoredBox(
      color: Press.inkAt(0.04),
      child: Image.memory(art, fit: BoxFit.contain),
    );
  }
}
