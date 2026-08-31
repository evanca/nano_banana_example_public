import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../prompts/cover_prompt.dart';
import '../prompts/cover_styles.dart';
import '../services/cover_download.dart';
import '../services/nano_banana_service.dart';

enum CoverStatus { idle, generating, ready, error }

/// Owns the selfie and the generated cover draft.
class CoverController extends ChangeNotifier {
  CoverController({ImagePicker? picker, NanoBananaService? service})
    : _picker = picker ?? ImagePicker(),
      _service = service ?? NanoBananaService();

  final ImagePicker _picker;
  final NanoBananaService _service;

  Uint8List? _selfie;
  Uint8List? get selfie => _selfie;

  CoverDraft? _draft;
  CoverDraft? get draft => _draft;

  /// Which art direction this draft was rolled with.
  CoverStyle? _style;
  CoverStyle? get style => _style;

  CoverStatus _status = CoverStatus.idle;
  CoverStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool get hasSelfie => _selfie != null;
  bool get isBusy => _status == CoverStatus.generating;

  /// Longest edge the selfie is scaled to before being sent.
  static const double _maxSelfieEdge = 1280;

  /// Opens the platform file dialog.
  Future<void> uploadSelfie() async {
    _error = null;
    notifyListeners();
    try {
      // firebase_ai base64-encodes on the main isolate, so a full-size
      // photo freezes the UI while the request is built.
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxSelfieEdge,
        maxHeight: _maxSelfieEdge,
        imageQuality: 85,
      );
      if (file == null) return;
      _selfie = await file.readAsBytes();
      _draft = null;
      _status = CoverStatus.idle;
    } on Exception catch (e) {
      _error = 'Could not read that image: $e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  /// Accepts bytes captured elsewhere.
  void setSelfie(Uint8List bytes) {
    _selfie = bytes;
    _draft = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }

  Future<void> generate() async {
    final selfie = _selfie;
    if (selfie == null || isBusy) return;

    _status = CoverStatus.generating;
    _error = null;
    _draft = null;
    _style = CoverStyle.random();
    debugPrint('Cover style: ${_style!.name}');
    notifyListeners();

    try {
      _draft = await _service.generateCover(
        selfie: selfie,
        prompt: buildCoverPrompt(_style!),
      );
      _status = CoverStatus.ready;
    } on Exception catch (e) {
      _error = '$e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  /// Hands the artwork to the browser's download dialog.
  ///
  /// The bytes only live in memory — generating again discards them.
  Future<void> saveCover() async {
    final bytes = _draft?.image;
    if (bytes == null) return;

    final slug = (_style?.name ?? 'cover')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    try {
      await downloadCover(bytes, 'cd-cover-$slug.png');
    } on Object catch (e) {
      _error = 'Could not save the cover: $e';
      notifyListeners();
    }
  }

  void clear() {
    _selfie = null;
    _draft = null;
    _style = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }
}
