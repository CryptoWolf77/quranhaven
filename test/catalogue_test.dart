import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_library/src/core/platform/verified_tafsir_cache.dart';

void main() {
  test(
    'all 44 resources have semantic categories without changing file formats',
    () {
      final catalogue = defaultTafsirResources;
      expect(catalogue, hasLength(44));
      expect(
        catalogue.where((item) => !item.isCommentary).map((e) => e.fileName),
        ['en', 'es', 'be', 'urdu', 'so', 'in', 'ku', 'tr', 'fr'],
      );
      expect(catalogue.where((item) => item.isCommentary), hasLength(35));
      expect(catalogue.indexWhere((item) => item.fileName == 'en'), 28);
      for (final resource in catalogue) {
        final decoded = jsonDecode(
          utf8.decode(
            gzip.decode(
              File(
                'content/public/v1/tafsir/${resource.databaseName}',
              ).readAsBytesSync(),
            ),
          ),
        );
        VerifiedTafsirCache.validateJson(
          decoded,
          translation: resource.isTranslation,
        );
        final reloaded = TafsirNameModel.fromJson(resource.toJson());
        expect(reloaded.isCommentary, resource.isCommentary);
        expect(reloaded.isTranslation, resource.isTranslation);
        expect(reloaded.databaseName, resource.databaseName);
      }
    },
  );

  test('legacy custom metadata uses its existing parser category', () {
    final old = TafsirNameModel.fromJson({
      'name': 'Custom',
      'fileName': 'custom',
      'bookName': 'Custom',
      'databaseName': 'custom.json',
      'isCustom': true,
    });
    expect(old.isCommentary, isTrue);
    expect(old.isTranslation, isFalse);
  });
}
