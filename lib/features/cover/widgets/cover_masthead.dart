import 'package:flutter/material.dart';

/// Job line, headline and blurb.
class CoverMasthead extends StatelessWidget {
  const CoverMasthead({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('JOB — AWAITING PROOF', style: TextStyle(fontSize: 12)),
        SizedBox(height: 14),
        Text('MAKE THE\nCOVER', style: TextStyle(fontSize: 44)),
        SizedBox(height: 18),
        Text(
          'Step into the booth, solo or with the whole crew. Nano Banana reads '
          'the photo, invents the act, writes the tracklist and prints a full '
          'jewel-case spread — front, spine and back.',
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
