import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import 'press_log.dart';
import 'press_status.dart';
import 'spec_row.dart';

/// The specs table, with the press log or status line beneath it.
class PlateSpecs extends StatelessWidget {
  const PlateSpecs({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final meta = controller.draft?.meta;
    // "Unknown yet" and "in progress" are different states.
    final pending = controller.isBusy ? '···' : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PLATE SPECS',
          style: Press.mono(size: 11, color: Press.inkAt(0.5), tracking: 0.3),
        ),
        const SizedBox(height: 14),
        Divider(height: 1, color: Press.rule),
        SpecRow(
          label: 'Artist',
          value: meta?.artistName.orIfEmpty(pending) ?? pending,
        ),
        Divider(height: 1, color: Press.rule),
        SpecRow(
          label: 'Title',
          value: meta?.albumTitle.orIfEmpty(pending) ?? pending,
        ),
        Divider(height: 1, color: Press.rule),
        SpecRow(
          label: 'Catalog',
          value: meta?.catalogNumber.orIfEmpty(pending) ?? pending,
        ),
        Divider(height: 1, color: Press.rule),
        const SpecRow(label: 'Panels', value: 'front / back'),
        Divider(height: 1, color: Press.rule),
        const SpecRow(label: 'Stock', value: '300gsm matte'),
        Divider(height: 1, color: Press.rule),
        SpecRow(
          label: 'Press',
          value: meta?.label.orIfEmpty(pending) ?? pending,
        ),
        Divider(height: 1, color: Press.rule),
        const SizedBox(height: 22),
        if (controller.isBusy)
          PressLog(
            stages: CoverController.pressStages,
            currentIndex: controller.pressStage,
          )
        else if (controller.failedStage case final failed?)
          PressLog(
            stages: CoverController.pressStages,
            currentIndex: failed,
            halted: true,
          )
        else
          PressStatus(controller: controller),
      ],
    );
  }
}

extension on String {
  String orIfEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
