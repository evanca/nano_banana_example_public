import 'dart:async';

import 'package:flutter/widgets.dart';

/// Toggles its child on and off with a hard cut, like a relay-driven lamp.
class Blink extends StatefulWidget {
  const Blink({
    super.key,
    required this.child,
    this.period = const Duration(seconds: 1),
    this.enabled = true,
  });

  final Widget child;

  /// Full on/off cycle; one second gives the 1 Hz tally light.
  final Duration period;
  final bool enabled;

  @override
  State<Blink> createState() => _BlinkState();
}

class _BlinkState extends State<Blink> {
  Timer? _timer;
  bool _lit = true;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(Blink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled || oldWidget.period != widget.period) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _lit = true;
    if (!widget.enabled) return;
    _timer = Timer.periodic(widget.period ~/ 2, (_) => setState(() => _lit = !_lit));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Opacity(opacity: _lit ? 1 : 0, child: widget.child);
}
