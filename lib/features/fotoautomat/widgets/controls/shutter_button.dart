import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import 'actuator.dart';

/// The heavy primary trigger: acid phosphor block, 2px white border and
/// 45-degree notched corners. Hover shifts it to amber.
class ShutterButton extends StatelessWidget {
  const ShutterButton({
    super.key,
    required this.label,
    required this.caption,
    required this.onPressed,
  });

  final String label;
  final String caption;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Actuator(
      onPressed: onPressed,
      semanticLabel: '$label, $caption',
      builder: (context, s) {
        final enabled = onPressed != null;
        final fill = !enabled
            ? AutomatColors.panelRaised
            : s.hovered || s.pressed
            ? AutomatColors.amber
            : AutomatColors.acid;
        final ink = enabled ? AutomatColors.chassis : AutomatColors.slate;
        return Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: ShapeDecoration(
            color: fill,
            shape: BeveledRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              side: BorderSide(
                color: enabled
                    ? (s.focused ? AutomatColors.amber : AutomatColors.white)
                    : AutomatColors.toggleBorder,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AutomatText.headlineMd.copyWith(color: ink)),
                    const SizedBox(height: 2),
                    Text(caption, style: AutomatText.labelSm.copyWith(color: ink)),
                  ],
                ),
              ),
              Icon(Icons.camera, color: ink, size: 32),
            ],
          ),
        );
      },
    );
  }
}
