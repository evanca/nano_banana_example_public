import 'package:flutter/material.dart';

import 'plate_spine.dart';

/// The plate while a cover is being generated.
class PressingPlate extends StatelessWidget {
  const PressingPlate({
    required this.stage,
    required this.stageIndex,
    required this.stageCount,
    super.key,
  });

  /// Current stage label.
  final String stage;

  /// Zero-based position of [stage].
  final int stageIndex;

  final int stageCount;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: Colors.black12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(alignment: Alignment.center, child: PlateSpine()),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black45, width: 2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      stage.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PLATES ${stageIndex + 1} OF $stageCount',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
