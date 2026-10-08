import 'package:flutter/material.dart';

typedef ActuatorBuilder =
    Widget Function(BuildContext context, ({bool hovered, bool pressed, bool focused}) s);

/// Shared mechanics for every physical control: hover, keyboard focus and
/// activation, and a 2px-by-2px depression with zero travel lag.
class Actuator extends StatefulWidget {
  const Actuator({
    super.key,
    required this.onPressed,
    required this.builder,
    required this.semanticLabel,
    this.selected,
  });

  /// Null disables the control.
  final VoidCallback? onPressed;
  final ActuatorBuilder builder;
  final String semanticLabel;
  final bool? selected;

  @override
  State<Actuator> createState() => _ActuatorState();
}

class _ActuatorState extends State<Actuator> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _enabled && _pressed;
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapCancel: () => _setPressed(false),
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTap: widget.onPressed,
          child: Transform.translate(
            offset: pressed ? const Offset(2, 2) : Offset.zero,
            child: widget.builder(context, (
              hovered: _enabled && _hovered,
              pressed: pressed,
              focused: _enabled && _focused,
            )),
          ),
        ),
      ),
    );
  }
}
