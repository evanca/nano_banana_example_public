import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';

/// Dotted run-out line plus the current press state.
class ProgressRow extends StatelessWidget {
  const ProgressRow({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final (label, filled) = switch (controller.status) {
      CoverStatus.generating => ('On press', 0.55),
      CoverStatus.ready => ('Plate ready', 1.0),
      CoverStatus.error => ('Plate error', 0.0),
      CoverStatus.idle when controller.hasSelfie => ('Ready to print', 0.25),
      CoverStatus.idle => ('Awaiting selfie', 0.0),
    };
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 9.0;
              final count = (constraints.maxWidth / spacing).floor();
              final lit = (count * filled).round();
              return Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: spacing - 2),
                      child: Container(
                        width: 2,
                        height: 2,
                        color: i < lit ? Press.blue : Press.inkAt(0.28),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label.toUpperCase(),
          style: Press.mono(size: 10, color: Press.inkAt(0.45), tracking: 0.22),
        ),
      ],
    );
  }
}
