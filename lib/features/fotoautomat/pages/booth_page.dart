import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/theme/automat_colors.dart';
import '../../../shared/theme/automat_text.dart';
import '../logic/booth_cubit.dart';
import '../logic/booth_state.dart';
import '../widgets/chassis/led.dart';
import '../widgets/chassis/machined_panel.dart';
import '../widgets/control_bay.dart';
import '../widgets/output/output_bay.dart';
import '../widgets/viewfinder/viewfinder.dart';
import '../widgets/xenon_flash.dart';

class BoothPage extends StatelessWidget {
  const BoothPage({super.key});

  static const _wideBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BoothCubit>();
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.space): cubit.shoot},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: BlocBuilder<BoothCubit, BoothState>(
            builder: (context, state) => Stack(
              children: [
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final wide = box.maxWidth >= _wideBreakpoint;
                      final margin = wide ? 32.0 : 16.0;
                      return Padding(
                        padding: EdgeInsets.all(margin),
                        child: wide ? _wide(context, state) : _narrow(context, state),
                      );
                    },
                  ),
                ),
                Positioned.fill(child: XenonFlash(flashCount: state.flashCount)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wide(BuildContext context, BoothState state) {
    // While exposing, auxiliary bays collapse to lock focus on the optics.
    final locked = state.phase == BoothPhase.exposing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(state: state, wide: true),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Center(child: _viewfinder(context, state))),
              if (!locked) ...[
                const SizedBox(width: 16),
                SizedBox(width: 380, child: SingleChildScrollView(child: _bays(context, state))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _narrow(BuildContext context, BoothState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(state: state, wide: false),
          const SizedBox(height: 12),
          _viewfinder(context, state),
          if (state.phase != BoothPhase.exposing) ...[
            const SizedBox(height: 12),
            _bays(context, state),
          ],
        ],
      ),
    );
  }

  Widget _viewfinder(BuildContext context, BoothState state) {
    final cubit = context.read<BoothCubit>();
    return Viewfinder(
      state: state,
      controller: cubit.camera.controller,
      onPowerOn: state.phase == BoothPhase.idle ? cubit.powerOn : cubit.retake,
    );
  }

  Widget _bays(BuildContext context, BoothState state) {
    final cubit = context.read<BoothCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MachinedPanel(
          label: 'BAY 01 · CONTROLS',
          child: ControlBay(
            state: state,
            onStyle: cubit.selectStyle,
            onFlash: cubit.toggleFlash,
            onSound: cubit.toggleSound,
            onShoot: cubit.shoot,
          ),
        ),
        const SizedBox(height: 16),
        MachinedPanel(
          label: 'BAY 02 · OUTPUT',
          child: OutputBay(
            state: state,
            onSave: cubit.saveStrip,
            onRetake: cubit.retake,
            onRedevelop: cubit.redevelop,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.wide});

  final BoothState state;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final (status, color) = switch (state.phase) {
      _ when state.camera != CameraStatus.ready && state.phase == BoothPhase.idle => (
        'STANDBY',
        AutomatColors.slate,
      ),
      BoothPhase.idle => ('READY', AutomatColors.acid),
      BoothPhase.exposing => ('EXPOSING', AutomatColors.amber),
      BoothPhase.developing => ('DEVELOPING', AutomatColors.amber),
      BoothPhase.developed => ('DISPENSED', AutomatColors.acid),
      BoothPhase.failed => ('FAULT', AutomatColors.amber),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'BERLIN FOTOAUTOMAT',
            style: wide ? AutomatText.headlineXl : AutomatText.headlineXlMobile,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('AUTOMAT_BER_09', style: AutomatText.labelSm),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Led(on: color != AutomatColors.slate, color: color),
                const SizedBox(width: 8),
                Text(status, style: AutomatText.labelMd.copyWith(color: AutomatColors.paper)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
