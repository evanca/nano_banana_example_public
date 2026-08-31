import 'package:flutter/foundation.dart';

import '../services/nano_banana_service.dart';

enum CoverStatus { idle, generating, ready, error }

/// Owns the generated cover and the state of the run that produced it.
class CoverController extends ChangeNotifier {
  CoverController({NanoBananaService? service})
    : _service = service ?? NanoBananaService();

  final NanoBananaService _service;

  CoverDraft? _draft;
  CoverDraft? get draft => _draft;

  CoverStatus _status = CoverStatus.idle;
  CoverStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool get isBusy => _status == CoverStatus.generating;

  Future<void> generate() async {
    if (isBusy) return;

    // A stale cover on screen would not match what is happening.
    _status = CoverStatus.generating;
    _error = null;
    _draft = null;
    notifyListeners();

    try {
      _draft = await _service.generateCover();
      _status = CoverStatus.ready;
    } on Exception catch (e) {
      _error = '$e';
      _status = CoverStatus.error;
    }
    notifyListeners();
  }

  void clear() {
    _draft = null;
    _error = null;
    _status = CoverStatus.idle;
    notifyListeners();
  }
}
