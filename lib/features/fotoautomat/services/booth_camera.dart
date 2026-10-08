import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Thrown with a message fit for the viewfinder.
class CameraFailure implements Exception {
  const CameraFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The booth's optics: a live preview plus single-frame capture.
abstract interface class BoothCamera {
  /// Non-null once [start] succeeded; drives the live preview.
  CameraController? get controller;

  Future<void> start();

  /// JPEG bytes of one frame, mirrored to match the preview.
  Future<Uint8List> capture();

  /// Releases the stream so the camera light goes off between sessions.
  Future<void> stop();

  Future<void> dispose();
}

class DeviceBoothCamera implements BoothCamera {
  CameraController? _controller;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> start() async {
    if (_controller?.value.isInitialized ?? false) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const CameraFailure('No camera found on this device.');
      }
      final lens = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      // 1280x720 holds faces comfortably and keeps base64 encoding cheap.
      final controller = CameraController(lens, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      _controller = controller;
    } on CameraException catch (e) {
      throw CameraFailure(_describe(e));
    }
  }

  @override
  Future<Uint8List> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraFailure('Camera is not running.');
    }
    final file = await controller.takePicture();
    return file.readAsBytes();
  }

  @override
  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  Future<void> dispose() => stop();

  static String _describe(CameraException e) => switch (e.code) {
    'CameraAccessDenied' ||
    'cameraPermission' => 'Camera access blocked. Allow it in the browser address bar, then retry.',
    'cameraNotFound' => 'No camera found on this device.',
    'cameraNotReadable' => 'Camera is busy in another app or tab.',
    'cameraNotSupported' => 'This browser cannot open a camera. Use HTTPS or localhost.',
    _ => e.description ?? 'Camera failed (${e.code}).',
  };
}
