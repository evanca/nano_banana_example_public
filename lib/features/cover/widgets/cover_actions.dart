import 'package:flutter/material.dart';

import 'dashed_action.dart';
import 'press_action.dart';

/// Inputs, generate and download — none of them wired yet.
class CoverActions extends StatelessWidget {
  const CoverActions({super.key});

  static void _todo() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const PressAction(
          label: 'Make the cover',
          trailing: '~12 sec',
          onPressed: _todo,
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
