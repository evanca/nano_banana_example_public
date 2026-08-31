import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The press log, shown while a cover is generating.
class PressLog extends StatelessWidget {
  const PressLog({
    required this.stages,
    required this.currentIndex,
    this.halted = false,
    super.key,
  });

  final List<String> stages;
  final int currentIndex;

  /// Where the run stopped, rather than where it has got to.
  final bool halted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESS LOG',
          style: Press.mono(size: 11, color: Press.inkAt(0.45), tracking: 0.22),
        ),
        const SizedBox(height: 12),
        for (final (index, stage) in stages.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _LogRow(
              label: stage,
              state: switch (index) {
                _ when index < currentIndex => _RowState.done,
                _ when index == currentIndex && halted => _RowState.failed,
                _ when index == currentIndex => _RowState.running,
                _ => _RowState.pending,
              },
            ),
          ),
        const SizedBox(height: 4),
        if (halted) const _HaltedMarker() else const _RunningMarker(),
      ],
    );
  }
}

enum _RowState { done, running, failed, pending }

/// Darker than the pink accent, so it reads as failure not decoration.
const Color _halt = Color(0xFFC2185B);

class _LogRow extends StatelessWidget {
  const _LogRow({required this.label, required this.state});

  final String label;
  final _RowState state;

  @override
  Widget build(BuildContext context) {
    final (mark, colour) = switch (state) {
      _RowState.done => ('✓', Press.inkAt(0.45)),
      _RowState.running => ('▸', Press.blue),
      _RowState.failed => ('✕', _halt),
      _RowState.pending => ('·', Press.inkAt(0.28)),
    };
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            mark,
            textAlign: TextAlign.center,
            style: Press.mono(size: 11, color: colour),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: Press.mono(size: 11, color: colour, tracking: 0.1),
          ),
        ),
      ],
    );
  }
}

class _HaltedMarker extends StatelessWidget {
  const _HaltedMarker();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, color: Press.pink),
        const SizedBox(width: 8),
        Text(
          'PRESS HALTED',
          style: Press.mono(size: 11, color: _halt, tracking: 0.14),
        ),
      ],
    );
  }
}

class _RunningMarker extends StatefulWidget {
  const _RunningMarker();

  @override
  State<_RunningMarker> createState() => _RunningMarkerState();
}

class _RunningMarkerState extends State<_RunningMarker>
    with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _blink,
          builder: (context, _) => Opacity(
            opacity: _blink.value < 0.5 ? 1 : 0,
            child: Container(width: 6, height: 6, color: Press.pink),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'PRESS RUNNING',
          style: Press.mono(size: 11, color: Press.inkAt(0.5), tracking: 0.14),
        ),
      ],
    );
  }
}
