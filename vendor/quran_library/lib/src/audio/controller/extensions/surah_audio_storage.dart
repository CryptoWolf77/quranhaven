part of '../../audio.dart';

extension SurahAudioStorage on AudioCtrl {
  /// -------- [Storage] ----------

  /// تحميل آخر سورة ومكان مستمع إليهما من التخزين المحلي
  void loadLastSurahAndPosition() {
    final int lastSurah = state.box.read(StorageConstants.lastSurah) ?? 1;
    final int selectedSurah =
        state.box.read(StorageConstants.selectedSurahIndex) ?? 0;
    final int lastPosition = state.box.read(StorageConstants.lastPosition) ?? 0;

    final restored = lastSurah >= 1 && lastSurah <= 114
        ? lastSurah
        : (selectedSurah >= 0 && selectedSurah < 114 ? selectedSurah + 1 : 1);
    state.selectSurahNumber(restored);
    state.lastPosition.value = lastPosition;

    log('Loaded last Surah index: ${state.selectedSurahIndex.value + 1}, last Surah ${state.currentAudioListSurahNum.value} position: ${state.lastPosition.value}');
  }

  void saveLastSurahListen(int? surahNumber) {
    state.box.write(StorageConstants.lastSurah,
        surahNumber ?? state.selectedSurahIndex.value + 1);
    state.box.write(
      StorageConstants.selectedSurahIndex,
      state.selectedSurahIndex.value,
    );
    log('Saved last Surah index: ${state.selectedSurahIndex.value + 1}, last Surah ${surahNumber ?? state.selectedSurahIndex.value + 1}');
  }

  void loadReaderIndex() {
    state.surahReaderIndex.value =
        state.box.read(StorageConstants.surahReaderIndex) ?? 0;
    state.ayahReaderIndex.value =
        state.box.read(StorageConstants.ayahReaderIndex) ?? 0;
  }
}
