import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import '../cover_layout.dart';

/// Job line, headline and blurb — all three change while the press runs.
class CoverMasthead extends StatelessWidget {
  const CoverMasthead({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final pressing = controller.isBusy;
    final catalog = controller.draft?.meta?.catalogNumber;
    final job = switch ((pressing, catalog)) {
      (true, _) => 'JOB — ON PRESS',
      (false, final c?) when c.isNotEmpty => 'JOB $c — PROOF 01',
      _ => 'JOB — AWAITING PROOF',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job,
          style:
              Press.mono(size: 12, color: Press.blue, weight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = (constraints.maxWidth * 0.07).clamp(44.0, 86.0);
            final headline = Text(
              pressing ? 'PRINTING\nYOUR COVER' : 'MAKE THE\nCOVER',
              style: Press.display(size),
            );
            final blurb = Text(
              pressing
                  ? 'Nano Banana is reading the photo, naming the act and '
                        'setting the type. Sit tight — the whole spread lands '
                        'in one piece.'
                  : 'Step into the booth, solo or with the whole crew. Nano '
                        'Banana reads the photo, invents the act, writes the '
                        'tracklist and prints a full jewel-case spread — '
                        'front, spine and back.',
            );

            if (constraints.maxWidth < CoverLayout.wideBreakpoint) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headline,
                  const SizedBox(height: 18),
                  DefaultTextStyle(style: Press.body(), child: blurb),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(flex: 5, child: headline),
                const SizedBox(width: 48),
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DefaultTextStyle(style: Press.body(), child: blurb),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
