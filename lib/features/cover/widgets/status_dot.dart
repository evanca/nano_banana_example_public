import 'package:flutter/material.dart';

/// The state dot. Filled once a run has halted.
class StatusDot extends StatelessWidget {
  const StatusDot({required this.halted, super.key});

  final bool halted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: halted ? Colors.black : null,
        border: Border.all(color: Colors.black),
        shape: BoxShape.circle,
      ),
    );
  }
}
