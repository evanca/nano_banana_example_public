import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../chassis/led.dart';
import 'actuator.dart';

/// Secondary toggle with an embedded LED that snaps from inert slate to
/// phosphor when engaged.
class RelayToggle extends StatelessWidget {
  const RelayToggle({super.key, required this.label, required this.on, required this.onPressed});

  final String label;
  final bool on;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Actuator(
      onPressed: onPressed,
      selected: on,
      semanticLabel: '$label ${on ? 'on' : 'off'}',
      builder: (context, s) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AutomatColors.panel,
          border: Border.all(
            color: s.hovered || s.focused ? AutomatColors.halftone : AutomatColors.toggleBorder,
          ),
        ),
        child: Row(
          children: [
            Led(on: on),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AutomatText.labelMd.copyWith(
                  color: on ? AutomatColors.paper : AutomatColors.halftone,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(on ? 'ON' : 'OFF', style: AutomatText.labelSm),
          ],
        ),
      ),
    );
  }
}
