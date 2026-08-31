import 'package:flutter/material.dart';

/// The primary action.
class PressAction extends StatelessWidget {
  const PressAction({
    required this.label,
    required this.onPressed,
    this.trailing,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
