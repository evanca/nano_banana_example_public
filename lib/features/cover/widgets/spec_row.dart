import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// A label/value row in the plate-specs table.
class SpecRow extends StatelessWidget {
  const SpecRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label.toUpperCase(),
              style: Press.mono(size: 11, color: Press.inkAt(0.5)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Press.mono(size: 12, tracking: 0.04),
            ),
          ),
        ],
      ),
    );
  }
}
