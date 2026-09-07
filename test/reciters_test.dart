import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  test('eight new reciters match the verified provider catalogue', () {
    final entries =
        jsonDecode(File('deployment/reciters.json').readAsStringSync())
            as List<dynamic>;
    expect(entries, hasLength(8));
    expect(ReadersConstants.surahReaderInfo, hasLength(29));
    expect(ReadersConstants.ayahReaderInfo, hasLength(20));
    for (final entry in entries) {
      final surah =
          ReadersConstants.surahReaderInfo[entry['surah_index'] as int];
      final ayah = ReadersConstants.ayahReaderInfo[entry['ayah_index'] as int];
      expect(surah.index, entry['surah_index']);
      expect(ayah.index, entry['ayah_index']);
      expect(surah.name, entry['arabic']);
      expect(ayah.name, entry['arabic']);
      expect('${surah.url}${surah.readerNamePath}', entry['surah_root']);
      expect(ayah.url, 'https://everyayah.com/data/');
      expect(ayah.readerNamePath, entry['ayah_folder']);
    }
  });

  test('legacy selection indices and downloaded-file paths stay unchanged', () {
    const ayahPaths = [
      'Abdul_Basit_Murattal_192kbps',
      'Minshawy_Murattal_128kbps',
      'Husary_128kbps',
      '128/ar.ahmedajamy',
      'MaherAlMuaiqly128kbps',
      'Saood_ash-Shuraym_128kbps',
      'Abdullaah_3awwaad_Al-Juhaynee_128kbps',
      'Fares_Abbad_64kbps',
      '128/ar.muhammadayyoub',
      'MaherAlMuaiqly128kbps',
      'Yasser_Ad-Dussary_128kbps',
      'Ali_Jaber_64kbps',
    ];
    const surahPaths = [
      'abdulBasit/murattal/mp3/',
      'minshawy/murattal/mp3/',
      'mahmood_khaleel_al-husaree_iza3a/',
      'ahmed_ibn_3ali_al-3ajamy/',
      'maher_almu3aiqly/year1440/',
      'saudAlShuraim/murattal/mp3/',
      'ghamadi/murattal/mp3/',
      'mustafa_al3azzawi/',
      'nasser_bin_ali_alqatami/',
      'peshawa/Rewayat-Hafs-A-n-Assem/',
      'taher/',
      'aloosi/',
      'wdee3/',
      'yasser_ad-dussary/',
      'abdullaah_3awwaad_al-juhaynee/',
      'fares/',
      'muhammad_ayyoob_hq/',
      'maher/',
      'nufais/Rewayat-Hafs-A-n-Assem/',
      'yasser/',
      'ali_jaber/',
    ];
    for (var index = 0; index < ayahPaths.length; index++) {
      expect(ReadersConstants.ayahReaderInfo[index].index, index);
      expect(
        ReadersConstants.ayahReaderInfo[index].readerNamePath,
        ayahPaths[index],
      );
    }
    for (var index = 0; index < surahPaths.length; index++) {
      expect(ReadersConstants.surahReaderInfo[index].index, index);
      expect(
        ReadersConstants.surahReaderInfo[index].readerNamePath,
        surahPaths[index],
      );
    }
  });

  test(
    'new reciters have unique recordings and custom catalogues still work',
    () {
      for (final list in [
        ReadersConstants.surahReaderInfo.sublist(21),
        ReadersConstants.ayahReaderInfo.sublist(12),
      ]) {
        expect(
          list.map((r) => '${r.url}${r.readerNamePath}').toSet(),
          hasLength(8),
        );
      }
      final custom = [ReadersConstants.surahReaderInfo.last.copyWith(index: 0)];
      try {
        ReadersConstants.customSurahReaders = custom;
        ReadersConstants.customAyahReaders = custom;
        expect(ReadersConstants.activeSurahReaders, same(custom));
        expect(ReadersConstants.activeAyahReaders, same(custom));
      } finally {
        ReadersConstants.customSurahReaders = null;
        ReadersConstants.customAyahReaders = null;
      }
    },
  );
}
