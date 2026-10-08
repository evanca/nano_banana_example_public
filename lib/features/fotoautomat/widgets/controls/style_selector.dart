import 'package:flutter/material.dart';

import '../../../../shared/theme/automat_colors.dart';
import '../../../../shared/theme/automat_text.dart';
import '../../models/strip_style.dart';
import 'actuator.dart';

/// Square segments locked together like stamped switches.
class StyleSelector extends StatelessWidget {
  const StyleSelector({super.key, required this.selected, required this.onSelected});

  final StripStyle selected;

  /// Null locks the selector, e.g. while exposing.
  final ValueChanged<StripStyle>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: AutomatColors.toggleBorder)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, style) in StripStyle.all.indexed) ...[
                  if (i > 0) const VerticalDivider(width: 1, color: AutomatColors.toggleBorder),
                  Expanded(
                    child: _Segment(
                      style: style,
                      active: style.id == selected.id,
                      onSelected: onSelected,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${selected.subtitle.toUpperCase()} · ISO ${selected.iso}',
          style: AutomatText.labelSm,
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.style, required this.active, required this.onSelected});

  final StripStyle style;
  final bool active;
  final ValueChanged<StripStyle>? onSelected;

  @override
  Widget build(BuildContext context) {
    final onSelected = this.onSelected;
    return Actuator(
      onPressed: onSelected == null ? null : () => onSelected(style),
      selected: active,
      semanticLabel: 'Style ${style.label}, ${style.subtitle}',
      builder: (context, s) => Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        color: active
            ? AutomatColors.acid
            : s.hovered
            ? AutomatColors.panelRaised
            : AutomatColors.panel,
        child: Text(
          style.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: AutomatText.labelMd.copyWith(
            color: active
                ? AutomatColors.chassis
                : onSelected == null
                ? AutomatColors.slate
                : AutomatColors.paper,
          ),
        ),
      ),
    );
  }
}
