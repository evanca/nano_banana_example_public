import 'package:flutter_test/flutter_test.dart';
import 'package:nano_banana_example/models/album_meta.dart';

void main() {
  group('AlbumMeta.tryParse', () {
    test('reads a fenced json block', () {
      final meta = AlbumMeta.tryParse('''
```json
{"artistName":"Aethelred","albumTitle":"Synapse_v.1",
 "catalogNumber":"SY98.02.45","label":"Millennium Beats Corp."}
```
''');

      expect(meta, isNotNull);
      expect(meta!.artistName, 'Aethelred');
      expect(meta.albumTitle, 'Synapse_v.1');
      expect(meta.catalogNumber, 'SY98.02.45');
      expect(meta.label, 'Millennium Beats Corp.');
    });

    test('reads bare json with no fence', () {
      final meta = AlbumMeta.tryParse(
        '{"artistName":"Krystalia","albumTitle":"Chrome//Wave",'
        '"catalogNumber":"745.98.02","label":"Glowtek"}',
      );

      expect(meta?.artistName, 'Krystalia');
      expect(meta?.albumTitle, 'Chrome//Wave');
    });

    test('finds the object when the model wraps it in prose', () {
      final meta = AlbumMeta.tryParse(
        'Here is the album identity you asked for:\n'
        '{"artistName":"Static Signal","albumTitle":"Circuit Breaker",'
        '"catalogNumber":"745.98.02","label":"Signal Rekords"}\n'
        'The artwork follows.',
      );

      expect(meta?.artistName, 'Static Signal');
      expect(meta?.label, 'Signal Rekords');
    });

    test('returns null when the model sent no text at all', () {
      expect(AlbumMeta.tryParse(''), isNull);
      expect(AlbumMeta.tryParse('   \n  '), isNull);
    });

    test('returns null rather than throwing on malformed json', () {
      expect(AlbumMeta.tryParse('{"artistName": "unterminated'), isNull);
      expect(AlbumMeta.tryParse('Here is your cover!'), isNull);
    });

    test('missing keys become empty strings, not nulls or crashes', () {
      final meta = AlbumMeta.tryParse('{"artistName":"Lyra"}');

      expect(meta?.artistName, 'Lyra');
      expect(meta?.albumTitle, '');
      expect(meta?.catalogNumber, '');
      expect(meta?.label, '');
    });
  });
}
