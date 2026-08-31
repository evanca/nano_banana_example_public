import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'dashed_action.dart';
import 'press_action.dart';

/// Everything below the plate. Only generate is wired yet.
class CoverActions extends StatelessWidget {
  const CoverActions({required this.controller, super.key});

  final CoverController controller;

  static void _todo() {}

  @override
  Widget build(BuildContext context) {
    final busy = controller.isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.error case final error?) ...[
          Text(error, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 22),
        ],
        Row(
          children: [
            const Expanded(
              child: DashedAction(
                label: 'Upload a photo',
                onPressed: _todo,
                leading: Icon(Icons.arrow_upward, size: 14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashedAction(
                label: 'Take a selfie',
                onPressed: _todo,
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
          label: 'Make the cover',
          trailing: '~12 sec',
          onPressed: busy ? null : controller.generate,
        ),
        const SizedBox(height: 22),
        const DashedAction(
          label: 'Download spread',
          onPressed: _todo,
          leading: Icon(Icons.arrow_downward, size: 14),
        ),
      ],
    );
  }
}
