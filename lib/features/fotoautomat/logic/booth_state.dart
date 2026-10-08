import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../models/developed_strip.dart';
import '../models/strip_style.dart';

enum CameraStatus { off, starting, ready, failed }

enum BoothPhase { idle, exposing, developing, developed, failed }

class BoothState extends Equatable {
  const BoothState({
    this.camera = CameraStatus.off,
    this.cameraError,
    this.phase = BoothPhase.idle,
    this.style = StripStyle.silber,
    this.frames = const [],
    this.countdown,
    this.flashCount = 0,
    this.stage = 0,
    this.developStartedAt,
    this.strip,
    this.error,
    this.flashEnabled = true,
    this.soundEnabled = true,
  });

  static const frameTotal = 4;

  final CameraStatus camera;
  final String? cameraError;
  final BoothPhase phase;
  final StripStyle style;
  final List<Uint8List> frames;

  /// Seconds left before the next exposure; null between countdowns.
  final int? countdown;

  /// Increments on every xenon discharge, so listeners can fire the flash.
  final int flashCount;

  /// Index into the darkroom stages, paced on a timer.
  final int stage;
  final DateTime? developStartedAt;
  final DevelopedStrip? strip;
  final String? error;
  final bool flashEnabled;
  final bool soundEnabled;

  bool get isBusy => phase == BoothPhase.exposing || phase == BoothPhase.developing;

  bool get canShoot => camera == CameraStatus.ready && !isBusy;

  bool get canRedevelop => !isBusy && frames.length == frameTotal;

  BoothState copyWith({
    CameraStatus? camera,
    String? Function()? cameraError,
    BoothPhase? phase,
    StripStyle? style,
    List<Uint8List>? frames,
    int? Function()? countdown,
    int? flashCount,
    int? stage,
    DateTime? Function()? developStartedAt,
    DevelopedStrip? Function()? strip,
    String? Function()? error,
    bool? flashEnabled,
    bool? soundEnabled,
  }) => BoothState(
    camera: camera ?? this.camera,
    cameraError: cameraError != null ? cameraError() : this.cameraError,
    phase: phase ?? this.phase,
    style: style ?? this.style,
    frames: frames ?? this.frames,
    countdown: countdown != null ? countdown() : this.countdown,
    flashCount: flashCount ?? this.flashCount,
    stage: stage ?? this.stage,
    developStartedAt: developStartedAt != null ? developStartedAt() : this.developStartedAt,
    strip: strip != null ? strip() : this.strip,
    error: error != null ? error() : this.error,
    flashEnabled: flashEnabled ?? this.flashEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
  );

  @override
  List<Object?> get props => [
    camera,
    cameraError,
    phase,
    style.id,
    frames,
    countdown,
    flashCount,
    stage,
    developStartedAt,
    strip,
    error,
    flashEnabled,
    soundEnabled,
  ];
}
