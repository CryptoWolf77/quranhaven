import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Injectable playback boundary; tests exercise state, not fabricated videos.
abstract class TutorialVideoController extends ChangeNotifier {
  bool get initialized;
  bool get playing;
  bool get ended;
  bool get hasError;
  Duration get position;
  Duration get duration;
  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Widget video();
  Future<void> release();
}

typedef TutorialVideoFactory = TutorialVideoController Function(String asset);
TutorialVideoController createTutorialVideo(String asset) =>
    _AssetTutorialVideo(asset);

class _AssetTutorialVideo extends TutorialVideoController {
  _AssetTutorialVideo(String asset)
    : _player = VideoPlayerController.asset(
        asset,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      ) {
    _player.addListener(_changed);
  }
  final VideoPlayerController _player;
  bool _released = false;
  void _changed() {
    if (!_released) notifyListeners();
  }

  @override
  bool get initialized => _player.value.isInitialized;
  @override
  bool get playing => _player.value.isPlaying;
  @override
  bool get ended =>
      initialized && position >= duration && duration > Duration.zero;
  @override
  bool get hasError => _player.value.hasError;
  @override
  Duration get position => _player.value.position;
  @override
  Duration get duration => _player.value.duration;
  @override
  Future<void> initialize() async {
    await _player.initialize();
    await _player.setVolume(0);
    await _player.setLooping(false);
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seekTo(position);
  @override
  Widget video() => VideoPlayer(_player);
  @override
  Future<void> release() async {
    if (_released) return;
    _released = true;
    _player.removeListener(_changed);
    try {
      await _player.pause();
    } finally {
      await _player.dispose();
    }
    dispose();
  }
}
