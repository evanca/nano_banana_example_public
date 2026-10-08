import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import 'actuator.dart';

/// Secondary cast-metal actuator with a monospace label.
class MachineButton extends StatelessWidget {
  const MachineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Actuator(
      onPressed: onPressed,
      semanticLabel: label,
      builder: (context, s) {
        final enabled = onPressed != null;
        final ink = !enabled
            ? AutomatColors.slate
            : s.hovered
            ? AutomatColors.acid
            : AutomatColors.paper;
        return Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: s.pressed ? AutomatColors.recessed : AutomatColors.panel,
            border: Border.all(
              color: s.hovered || s.focused ? AutomatColors.acid : AutomatColors.toggleBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AutomatText.labelMd.copyWith(color: ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
