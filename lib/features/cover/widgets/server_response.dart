import 'package:flutter/material.dart';

/// The raw failure, shown verbatim.
class ServerResponse extends StatelessWidget {
  const ServerResponse({required this.body, required this.at, super.key});

  final String body;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Row(
              children: [
                const Text('SERVER RESPONSE', style: TextStyle(fontSize: 11)),
                const Spacer(),
                if (at != null)
                  Text(_stamp(at!), style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              body,
              style: const TextStyle(fontSize: 11),
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
