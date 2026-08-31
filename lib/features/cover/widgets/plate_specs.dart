import 'package:flutter/material.dart';

import '../../../state/cover_controller.dart';
import 'spec_row.dart';

/// The specs table.
class PlateSpecs extends StatelessWidget {
  const PlateSpecs({required this.controller, super.key});

  final CoverController controller;

  @override
  Widget build(BuildContext context) {
    final meta = controller.draft?.meta;
    // "Unknown yet" and "in progress" are different states.
    final pending = controller.isBusy ? '···' : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('PLATE SPECS', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 14),
        const Divider(height: 1),
        SpecRow(
          label: 'Artist',
          value: meta?.artistName.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        SpecRow(
          label: 'Title',
          value: meta?.albumTitle.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        SpecRow(
          label: 'Catalog',
          value: meta?.catalogNumber.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
        const SpecRow(label: 'Panels', value: 'front / back'),
        const Divider(height: 1),
        const SpecRow(label: 'Stock', value: '300gsm matte'),
        const Divider(height: 1),
        SpecRow(
          label: 'Press',
          value: meta?.label.orIfEmpty(pending) ?? pending,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

extension on String {
  String orIfEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
