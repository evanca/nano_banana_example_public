import 'package:flutter/material.dart';

import '../../../theme/press_theme.dart';

/// The raw failure, shown verbatim.
class ServerResponse extends StatelessWidget {
  const ServerResponse({required this.body, required this.at, super.key});

  final String body;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Press.pink)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Press.pink.withValues(alpha: 0.08),
              border: Border(bottom: BorderSide(color: Press.pink)),
            ),
            child: Row(
              children: [
                Text(
                  'SERVER RESPONSE',
                  style: Press.mono(size: 11, color: Press.pink, tracking: 0.22),
                ),
                const Spacer(),
                if (at != null)
                  Text(
                    _stamp(at!),
                    style: Press.mono(
                      size: 11,
                      color: Press.inkAt(0.45),
                      tracking: 0.14,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              body,
              style: Press.mono(size: 11, tracking: 0.02).copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  static String _stamp(DateTime at) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(at.day)} ${_months[at.month - 1]} ${at.year} · '
        '${two(at.hour)}:${two(at.minute)}:${two(at.second)} UTC';
  }

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
}
