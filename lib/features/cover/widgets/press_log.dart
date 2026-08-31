import 'package:flutter/material.dart';

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
        const Text('PRESS LOG', style: TextStyle(fontSize: 11)),
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
        _Marker(label: halted ? 'PRESS HALTED' : 'PRESS RUNNING'),
      ],
    );
  }
}

enum _RowState { done, running, failed, pending }

class _LogRow extends StatelessWidget {
  const _LogRow({required this.label, required this.state});

  final String label;
  final _RowState state;

  @override
  Widget build(BuildContext context) {
    final mark = switch (state) {
      _RowState.done => '✓',
      _RowState.running => '▸',
      _RowState.failed => '✕',
      _RowState.pending => '·',
    };
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            mark,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// Square and label under the log.
class _Marker extends StatelessWidget {
  const _Marker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, color: Colors.black),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
