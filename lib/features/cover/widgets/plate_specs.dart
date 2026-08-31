import 'package:flutter/material.dart';

import 'spec_row.dart';

/// The specs table. Every value is written in here.
class PlateSpecs extends StatelessWidget {
  const PlateSpecs({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('PLATE SPECS', style: TextStyle(fontSize: 11)),
        SizedBox(height: 14),
        Divider(height: 1),
        SpecRow(label: 'Artist', value: 'Placeholder'),
        Divider(height: 1),
        SpecRow(label: 'Title', value: 'Nothing Was Generated'),
        Divider(height: 1),
        SpecRow(label: 'Catalog', value: '000.00.00'),
        Divider(height: 1),
        SpecRow(label: 'Panels', value: 'front / back'),
        Divider(height: 1),
        SpecRow(label: 'Stock', value: '300gsm matte'),
        Divider(height: 1),
        SpecRow(label: 'Press', value: 'Stub Records'),
        Divider(height: 1),
      ],
    );
  }
}
