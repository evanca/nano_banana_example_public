import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The primary press action.
class PressAction extends StatelessWidget {
  const PressAction({
    required this.label,
    required this.onPressed,
    this.trailing,
    this.halted = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailing;

  /// After a failure the button inverts.
  final bool halted;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Stack(
        // The plate sits outside the block, so the stack must not clip.
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            right: -6,
            top: 6,
            bottom: -6,
            child: ColoredBox(color: halted ? Press.inkDeep : Press.pink),
          ),
          InkWell(
            onTap: onPressed,
            child: ColoredBox(
              color: halted ? Press.pink : Press.blue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style:
                            Press.display(26).copyWith(color: Press.paperLight),
                      ),
                    ),
                    if (trailing != null)
                      Text(
                        trailing!,
                        style: Press.mono(
                          size: 12,
                          color: Press.paperLight.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
