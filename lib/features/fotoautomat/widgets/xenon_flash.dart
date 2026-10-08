import 'package:flutter/material.dart';

/// Total-white saturation for 100ms, then a 400ms phosphor decay. The white
/// screen doubles as the light source that falls on the sitter's face.
class XenonFlash extends StatefulWidget {
  const XenonFlash({super.key, required this.flashCount});

  /// Each increment fires one discharge.
  final int flashCount;

  @override
  State<XenonFlash> createState() => _XenonFlashState();
}

class _XenonFlashState extends State<XenonFlash> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: 1,
  );

  @override
  void didUpdateWidget(XenonFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashCount > oldWidget.flashCount) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final opacity = t >= 1
              ? 0.0
              : t < 0.2
              ? 1.0
              : 1 - (t - 0.2) / 0.8;
          if (opacity == 0) return const SizedBox.shrink();
          return ColoredBox(color: Colors.white.withValues(alpha: opacity));
        },
      ),
    );
  }
}
