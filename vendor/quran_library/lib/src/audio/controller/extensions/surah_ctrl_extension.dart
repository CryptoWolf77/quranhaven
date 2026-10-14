part of '../../audio.dart';

extension SurahCtrlExtension on AudioCtrl {
  Future<void> playPreviousSurah() async {
    final previous = state.currentAudioListSurahNum.value - 1;
    final cached = previous >= 1 ? await cachedWebSurahUrl(previous) : null;
    if (previous < 1 ||
        (!InternetConnectionController.instance.isConnected &&
            !state.isSurahDownloadedByNumber(previous).value &&
            cached == null)) {
      state.isPlaying.value = false;
      await state.audioPlayer.pause();
      return;
    }
    state.isPlayingSurahsMode = true;
    enableSurahAutoNextListener();
    enableSurahPositionSaving();
    if (state.currentAudioListSurahNum.value > 1) {
      state.selectedSurahIndex.value -= 1;
      state.isPlaying.value = true;
      saveLastSurahListen(state.currentAudioListSurahNum.value);
      await updateMediaItemAndPlay();
      await changeAudioSource()
          .then((_) async => await state.audioPlayer.play());
    } else {
      await state.audioPlayer.pause();
    }
  }

  Future<void> playNextSurah() async {
    final next = state.currentAudioListSurahNum.value + 1;
    final cached = next <= 114 ? await cachedWebSurahUrl(next) : null;
    if (next > 114 ||
        (!InternetConnectionController.instance.isConnected &&
            !state.isSurahDownloadedByNumber(next).value &&
            cached == null)) {
      state.isPlaying.value = false;
      await state.audioPlayer.pause();
      return;
    }
    state.isPlayingSurahsMode = true;
    enableSurahAutoNextListener();
    enableSurahPositionSaving();
    if (state.currentAudioListSurahNum.value < 114) {
      state.selectedSurahIndex.value += 1;
      state.isPlaying.value = true;
      saveLastSurahListen(state.currentAudioListSurahNum.value);
      await updateMediaItemAndPlay();
      await changeAudioSource()
          .then((_) async => await state.audioPlayer.play());
    } else {
      await state.audioPlayer.pause();
    }
  }

  Future<void> playSurah(
      {required BuildContext context,
      required int surahNumber,
      SurahAudioStyle? style}) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114);
    }
    final isConnected = InternetConnectionController.instance.isConnected;
    final browserUrl = await cachedWebSurahUrl(surahNumber);
    if (!context.mounted) return;

    // إذا كانت نفس السورة محمّلة والمشغّل جاهز (إيقاف مؤقت)، استأنف فقط
    if (state.isPlayingSurahsMode &&
        state.currentAudioListSurahNum.value == surahNumber &&
        state.audioPlayer.processingState == ProcessingState.ready &&
        !state.audioPlayer.playing) {
      state.isPlaying.value = true;
      enableSurahAutoNextListener();
      enableSurahPositionSaving();
      await state.audioPlayer.play();
      return;
    }

    if (!isConnected &&
        (state.isSurahDownloadedByNumber(surahNumber).value ||
            browserUrl != null)) {
      state.isPlayingSurahsMode = true;
      disableSurahAutoNextListener();
      state.selectSurahNumber(surahNumber);
      await changeAudioSource();
      enableSurahAutoNextListener();
      enableSurahPositionSaving();
      state.isPlaying.value = true;
      await state.audioPlayer.play();
    } else if (!isConnected) {
      ToastUtils().showToast(context,
          style?.noInternetConnectionText ?? 'لا يوجد اتصال بالإنترنت');
    } else {
      // التحقق من إمكانية التشغيل / Check if playback is allowed
      if (!await canPlayAudio()) {
        return;
      }

      state.isPlayingSurahsMode = true;
      disableSurahAutoNextListener();
      state.selectSurahNumber(surahNumber);
      cancelDownload();
      // تعيين مصدر الصوت: محلي إذا محمّل، أو بث مباشر من الرابط
      await changeAudioSource();
      enableSurahAutoNextListener();
      enableSurahPositionSaving();
      state.isPlaying.value = true;
      await state.audioPlayer.play();
    }
  }

  Future<void> _addFileAudioSourceToPlayList(String filePath) async {
    state.downloadSurahsPlayList.add({
      state.currentAudioListSurahNum.value: AudioSource.file(
        filePath,
        tag: mediaItem,
      )
    });
  }
}
