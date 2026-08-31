import 'package:flutter/material.dart';

import 'plate_spine.dart';

/// The plate when a run halts.
class FailedPlate extends StatelessWidget {
  const FailedPlate({
    required this.headline,
    required this.detail,
    super.key,
  });

  /// e.g. "Plate 3 failed".
  final String headline;

  /// The real failure text.
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black12,
          border: Border.all(color: Colors.black),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Text('!', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        headline.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
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
