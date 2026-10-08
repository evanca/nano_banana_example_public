import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/strip_style.dart';
import '../services/booth_camera.dart';
import '../services/booth_hardware.dart';
import '../services/strip_developer.dart';
import 'booth_state.dart';

/// Runs one booth session: arm optics, count down and expose four frames,
/// then send them to the darkroom.
class BoothCubit extends Cubit<BoothState> {
  BoothCubit({
    required this.camera,
    required this.developer,
    required this.sound,
    required this.saver,
    this.countdownStep = const Duration(seconds: 1),
    this.flashLead = const Duration(milliseconds: 90),
    this.stageStep = const Duration(seconds: 7),
  }) : super(const BoothState());

  /// The API gives no progress signal, so these advance on a timer and
  /// stop at the last one rather than claiming completion.
  static const darkroomStages = ['DEVELOPER', 'STOP BATH', 'FIXER', 'WASH', 'DRY'];

  final BoothCamera camera;
  final StripDeveloper developer;
  final BoothSound sound;
  final StripSaver saver;
  final Duration countdownStep;

  /// How long the white screen lights the face before the frame is taken.
  final Duration flashLead;
  final Duration stageStep;

  Timer? _stageTimer;

  Future<void> powerOn() async {
    if (state.camera == CameraStatus.starting || state.camera == CameraStatus.ready) return;
    _play((s) => s.click());
    await _armOptics();
  }

  Future<void> _armOptics() async {
    if (state.camera == CameraStatus.starting || state.camera == CameraStatus.ready) return;
    emit(state.copyWith(camera: CameraStatus.starting, cameraError: () => null));
    try {
      await camera.start();
      if (!isClosed) emit(state.copyWith(camera: CameraStatus.ready));
    } on CameraFailure catch (e) {
      if (!isClosed) {
        emit(state.copyWith(camera: CameraStatus.failed, cameraError: () => e.message));
      }
    }
  }

  void selectStyle(StripStyle style) {
    if (state.isBusy || style.id == state.style.id) return;
    _play((s) => s.click());
    emit(state.copyWith(style: style));
  }

  void toggleFlash() {
    _play((s) => s.click());
    emit(state.copyWith(flashEnabled: !state.flashEnabled));
  }

  void toggleSound() {
    emit(state.copyWith(soundEnabled: !state.soundEnabled));
    _play((s) => s.click());
  }

  Future<void> shoot() async {
    if (!state.canShoot) return;
    emit(
      state.copyWith(
        phase: BoothPhase.exposing,
        frames: const [],
        strip: () => null,
        error: () => null,
      ),
    );

    final frames = <Uint8List>[];
    try {
      for (var i = 0; i < BoothState.frameTotal; i++) {
        for (var n = i == 0 ? 3 : 2; n > 0; n--) {
          if (isClosed) return;
          emit(state.copyWith(countdown: () => n));
          _play((s) => s.tick());
          await Future<void>.delayed(countdownStep);
        }
        if (isClosed) return;
        emit(
          state.copyWith(
            countdown: () => null,
            flashCount: state.flashEnabled ? state.flashCount + 1 : null,
          ),
        );
        _play((s) => s.shutter());
        if (state.flashEnabled) await Future<void>.delayed(flashLead);
        frames.add(await camera.capture());
        if (isClosed) return;
        emit(state.copyWith(frames: List.unmodifiable(frames)));
      }
    } catch (e) {
      if (isClosed) return;
      await _parkOptics();
      emit(
        state.copyWith(
          phase: BoothPhase.failed,
          countdown: () => null,
          error: () => e is CameraFailure ? e.message : 'Exposure failed: $e',
        ),
      );
      return;
    }

    // The stream only runs while shooting, never during the darkroom wait.
    await _parkOptics();
    await _develop(frames);
  }

  Future<void> _parkOptics() async {
    if (isClosed) return;
    emit(state.copyWith(camera: CameraStatus.off));
    await camera.stop();
  }

  /// Sends the same frames again. Costs a new generation, so it is only
  /// ever triggered by the user, never automatically.
  Future<void> redevelop() async {
    if (!state.canRedevelop) return;
    _play((s) => s.click());
    await _develop(state.frames);
  }

  /// Clears the session and re-arms the optics for a new one.
  Future<void> retake() async {
    if (state.isBusy) return;
    _play((s) => s.click());
    emit(
      state.copyWith(
        phase: BoothPhase.idle,
        frames: const [],
        strip: () => null,
        error: () => null,
      ),
    );
    await _armOptics();
  }

  void saveStrip() {
    final strip = state.strip;
    if (strip == null) return;
    _play((s) => s.click());
    final stamp = strip.developedAt.millisecondsSinceEpoch ~/ 1000;
    saver.save(
      strip.bytes,
      fileName: 'fotoautomat_${strip.style.id}_$stamp.${strip.fileExtension}',
      mimeType: strip.mimeType,
    );
  }

  Future<void> _develop(List<Uint8List> frames) async {
    emit(
      state.copyWith(
        phase: BoothPhase.developing,
        stage: 0,
        developStartedAt: DateTime.now,
        strip: () => null,
        error: () => null,
      ),
    );
    _stageTimer?.cancel();
    _stageTimer = Timer.periodic(stageStep, (timer) {
      if (isClosed || state.stage >= darkroomStages.length - 1) {
        timer.cancel();
      } else {
        emit(state.copyWith(stage: state.stage + 1));
      }
    });

    final style = state.style;
    try {
      final strip = await developer.develop(frames, style);
      if (isClosed) return;
      debugPrint('Developed strip: style=${style.id} model=${strip.model}');
      _play((s) => s.dispense());
      emit(state.copyWith(phase: BoothPhase.developed, strip: () => strip));
    } catch (e) {
      if (isClosed) return;
      debugPrint('Development failed: style=${style.id} error=$e');
      emit(
        state.copyWith(
          phase: BoothPhase.failed,
          error: () => e is DevelopFailure ? e.message : 'Darkroom fault: $e',
        ),
      );
    } finally {
      _stageTimer?.cancel();
    }
  }

  void _play(void Function(BoothSound sound) effect) {
    if (state.soundEnabled) effect(sound);
  }

  @override
  Future<void> close() async {
    _stageTimer?.cancel();
    await camera.dispose();
    return super.close();
  }
}
