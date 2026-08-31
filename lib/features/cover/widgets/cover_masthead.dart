import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';

/// Job line, headline and blurb — all three change while generating.
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
        Text(job, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 14),
        Text(
          pressing ? 'PRINTING\nYOUR COVER' : 'MAKE THE\nCOVER',
          style: const TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 18),
        Text(
          pressing
              ? 'Nano Banana is reading the photo, naming the act and setting '
                    'the type. Sit tight — the whole spread lands in one piece.'
              : 'Step into the booth, solo or with the whole crew. Nano Banana '
                    'reads the photo, invents the act, writes the tracklist '
                    'and prints a full jewel-case spread — front, spine and '
                    'back.',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
