import 'package:flutter/material.dart';

/// Secondary action, e.g. "Upload a photo".
class DashedAction extends StatelessWidget {
  const DashedAction({
    required this.label,
    required this.onPressed,
    this.leading,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: Colors.black45)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                // The default font is wider than the mono it replaces.
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
