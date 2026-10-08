import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../logic/booth_cubit.dart';
import '../chassis/led.dart';

/// Chemical bath sequence. Paced on a timer because the API reports no
/// progress; it parks on the last bath instead of claiming completion.
class DarkroomProgress extends StatelessWidget {
  const DarkroomProgress({super.key, required this.stage, required this.startedAt});

  final int stage;
  final DateTime? startedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, name) in BoothCubit.darkroomStages.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Led(
                  on: i <= stage,
                  color: i < stage ? AutomatColors.acid : AutomatColors.amber,
                  blink: i == stage,
                ),
                const SizedBox(width: 10),
                Text(
                  'BATH ${i + 1}',
                  style: AutomatText.labelSm.copyWith(
                    color: i <= stage ? AutomatColors.halftone : AutomatColors.slate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: AutomatText.labelMd.copyWith(
                      color: i <= stage ? AutomatColors.paper : AutomatColors.slate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _Elapsed(startedAt: startedAt),
      ],
    );
  }
}

class _Elapsed extends StatefulWidget {
  const _Elapsed({required this.startedAt});

  final DateTime? startedAt;

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startedAt;
    final seconds = start == null ? 0 : DateTime.now().difference(start).inSeconds;
    return Text(
      'T+${seconds.toString().padLeft(3, '0')} S · NANO BANANA PRO DEVELOPING',
      style: AutomatText.labelSm.copyWith(color: AutomatColors.acid),
    );
  }
}
