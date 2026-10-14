import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('selected Surah updates the actual zero-based listening index', () {
    final state = SurahState();
    state.selectSurahNumber(114);
    expect(state.selectedSurahIndex.value, 113);
    expect(state.currentAudioListSurahNum.value, 114);
    state.selectSurahNumber(1);
    expect(state.selectedSurahIndex.value, 0);
    expect(state.currentAudioListSurahNum.value, 1);
    state.selectSurahNumber(3);
    expect(state.selectedSurahIndex.value, 2);
    expect(state.currentAudioListSurahNum.value, 3);
  });
  test('invalid Surah never replaces a valid selection', () {
    final state = SurahState();
    state.selectSurahNumber(40);
    for (final invalid in [0, 115, -1]) {
      expect(() => state.selectSurahNumber(invalid), throwsRangeError);
      expect(state.currentAudioListSurahNum.value, 40);
    }
  });
  test('callers never write an ephemeral derived Rx value', () {
    final writes = RegExp(
      r'currentAudioListSurahNum\.value\s*(?:=(?!=)|\+=|-=|\+\+|--)',
    );
    final files = Directory('vendor/quran_library/lib/src/audio/controller')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      expect(
        writes.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
  test('native source changes republish the selected Surah metadata', () {
    final source = File(
      'vendor/quran_library/lib/src/audio/controller/extensions/surah_ui.dart',
    ).readAsStringSync();
    final change = source
        .split('Future<void> changeAudioSource() async {')[1]
        .split('Future<void> selectSurahFromList')[0];
    final guard = change.indexOf(
      'if (!kIsWeb && state.audioServiceInitialized.value)',
    );
    final publish = change.indexOf(
      'AudioHandler.instance.mediaItem.add(mediaItem)',
    );
    expect(guard, greaterThan(change.lastIndexOf('setAudioSource(')));
    expect(publish, greaterThan(guard));
  });
}
