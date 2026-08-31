import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// Blue and steady; pink and blinking once a run has halted.
class StatusDot extends StatefulWidget {
  const StatusDot({required this.halted, super.key});

  final bool halted;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.halted) _blink.repeat();
  }

  @override
  void didUpdateWidget(StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.halted && !_blink.isAnimating) {
      _blink.repeat();
    } else if (!widget.halted) {
      _blink
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: widget.halted ? Press.pink : Press.blue,
        shape: BoxShape.circle,
      ),
    );
    if (!widget.halted) return dot;
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, child) =>
          Opacity(opacity: _blink.value < 0.5 ? 1 : 0, child: child),
      child: dot,
    );
  }
}
