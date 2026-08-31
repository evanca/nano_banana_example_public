import 'package:flutter/material.dart';

/// The plate the artwork sits on.
class ProofPanel extends StatelessWidget {
  const ProofPanel({super.key});

  static const double _spreadRatio = 2;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black45),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: _spreadRatio,
          child: ColoredBox(
            color: Colors.black12,
            child: Image(
              image: AssetImage('assets/placeholder_cover.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
