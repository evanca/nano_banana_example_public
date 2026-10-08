import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';

/// A fastened metal control module: 1px border, a stamped label strip
/// separated by a panel seam, and rivets in the corners.
class MachinedPanel extends StatelessWidget {
  const MachinedPanel({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final String label;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AutomatColors.panel,
        border: Border.all(color: AutomatColors.panelBorder),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AutomatColors.panelBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(label, style: AutomatText.labelSm)),
                    ?trailing,
                  ],
                ),
              ),
              Flexible(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
          for (final alignment in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Positioned.fill(
              child: Align(
                alignment: alignment,
                child: Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.all(3),
                  color: AutomatColors.panelBorder,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
