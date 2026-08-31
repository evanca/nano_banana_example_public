import 'dart:convert';

/// The album identity the model invented, reported alongside the artwork.
class AlbumMeta {
  const AlbumMeta({
    required this.artistName,
    required this.albumTitle,
    required this.catalogNumber,
    required this.label,
  });

  final String artistName;
  final String albumTitle;
  final String catalogNumber;
  final String label;

  factory AlbumMeta.fromJson(Map<String, dynamic> json) => AlbumMeta(
        artistName: (json['artistName'] as String? ?? '').trim(),
        albumTitle: (json['albumTitle'] as String? ?? '').trim(),
        catalogNumber: (json['catalogNumber'] as String? ?? '').trim(),
        label: (json['label'] as String? ?? '').trim(),
      );

  /// Pulls the metadata out of the model's text.
  ///
  /// Returns null rather than throwing — artwork without specs is still
  /// worth showing.
  static AlbumMeta? tryParse(String raw) {
    if (raw.trim().isEmpty) return null;

    final fenced = RegExp(r'```(?:json)?\s*(\{.*?\})\s*```', dotAll: true)
        .firstMatch(raw)
        ?.group(1);
    final candidate = fenced ?? _firstBalancedObject(raw);
    if (candidate == null) return null;

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! Map<String, dynamic>) return null;
      return AlbumMeta.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  static String? _firstBalancedObject(String raw) {
    final start = raw.indexOf('{');
    if (start == -1) return null;
    var depth = 0;
    for (var i = start; i < raw.length; i++) {
      if (raw[i] == '{') depth++;
      if (raw[i] == '}') {
        depth--;
        if (depth == 0) return raw.substring(start, i + 1);
      }
    }
    return null;
  }
}
