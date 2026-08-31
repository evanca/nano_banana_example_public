import 'package:flutter/material.dart';

/// The fold down the middle of a plate.
class PlateSpine extends StatelessWidget {
  const PlateSpine({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 9,
      child: ColoredBox(color: Colors.black26, child: SizedBox.expand()),
    );
  }
}
