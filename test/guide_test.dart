import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/app/theme/app_theme.dart';
import 'package:quran_flutter/features/guide/presentation/user_guide_page.dart';
import 'package:quran_flutter/features/guide/presentation/tutorial_video_controller.dart';
import 'package:quran_flutter/features/home/presentation/home_page.dart';
import 'package:quran_flutter/features/quran/presentation/reader_navigation.dart';
import 'package:quran_flutter/features/settings/presentation/settings_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Widget _host({
  String locale = 'en',
  double textScale = 1,
  bool reducedMotion = false,
  Widget? home,
  TutorialVideoFactory? factory,
}) => MaterialApp(
  theme: AppTheme.light(),
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: home ?? UserGuidePage(videoFactory: factory ?? (_) => _FakeVideo()),
);

class _FakeVideo extends TutorialVideoController {
  @override
  bool initialized = false;
  @override
  bool playing = false;
  @override
  bool hasError = false;
  bool released = false, rejectInitialize = false;
  @override
  Duration position = Duration.zero;
  @override
  Duration duration = const Duration(seconds: 30);
  @override
  bool get ended => position >= duration;
  @override
  Future<void> initialize() async {
    if (rejectInitialize) throw StateError('decoder');
    initialized = true;
    notifyListeners();
  }

  @override
  Future<void> play() async {
    playing = true;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    playing = false;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration v) async {
    position = v;
    notifyListeners();
  }

  @override
  Widget video() => const ColoredBox(
    key: ValueKey('test-video-surface'),
    color: Colors.black,
  );
  @override
  Future<void> release() async {
    playing = false;
    released = true;
    dispose();
  }
}

String _poster(WidgetTester t, String topic) =>
    (t.widget<Image>(find.byKey(ValueKey('guide-media-$topic'))).image
            as AssetImage)
        .assetName;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['ar', 'en', 'es']) {
    testWidgets(
      '$locale all13 lessons fit 360px at2x text with localized posters',
      (t) async {
        await t.binding.setSurfaceSize(const Size(360, 760));
        addTearDown(() => t.binding.setSurfaceSize(null));
        var created = 0;
        await t.pumpWidget(
          _host(
            locale: locale,
            textScale: 2,
            factory: (_) {
              created++;
              return _FakeVideo();
            },
          ),
        );
        await t.pumpAndSettle();
        expect(
          Directionality.of(t.element(find.byType(UserGuidePage))),
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        for (final topic in tutorialTopicIds) {
          final tile = find.byKey(ValueKey('guide-topic-$topic'));
          expect(tile, findsOneWidget);
          await t.ensureVisible(tile);
          await t.pumpAndSettle();
          await _tap(t, tile);
          await t.pumpAndSettle();
          expect(_poster(t, topic), 'assets/tutorials/$locale/$topic.png');
          expect(t.takeException(), isNull);
        }
        expect(created, 0);
      },
    );
    testWidgets('$locale Home tutorial entry is clear and opens local guide', (
      t,
    ) async {
      await t.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        _host(
          locale: locale,
          home: Scaffold(
            body: HomePage(
              currentPage: 42,
              onOpenReader: () {},
              onOpenLibrary: () {},
              onBrowseSurahs: () {},
              onSearch: () {},
              onBookmarks: () {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final entry = find.byKey(const ValueKey('home-guide-open'));
      await t.ensureVisible(entry);
      await t.pumpAndSettle();
      await _tap(t, entry);
      await t.pumpAndSettle();
      expect(find.byType(UserGuidePage), findsOneWidget);
      expect(_poster(t, 'reader'), 'assets/tutorials/$locale/reader.png');
      await _tap(t, find.byType(BackButton));
      await t.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(t.takeException(), isNull);
    });
    testWidgets(
      '$locale full-screen lesson fits2x text and closes explicitly',
      (t) async {
        await t.binding.setSurfaceSize(const Size(360, 760));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await t.pumpWidget(_host(locale: locale, textScale: 2));
        await t.pumpAndSettle();
        final larger = find.byKey(const ValueKey('guide-larger-reader'));
        await t.ensureVisible(larger);
        await t.pumpAndSettle();
        await _tap(t, larger);
        await t.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        final close = find.byKey(const ValueKey('guide-larger-close'));
        expect(
          t.widget<IconButton>(close).tooltip,
          MaterialLocalizations.of(t.element(close)).closeButtonLabel,
        );
        expect(t.takeException(), isNull);
        await _tap(t, close);
        await t.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('desktop uses scholarly lesson rail beside video', (t) async {
    await t.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(_host());
    await t.pumpAndSettle();
    expect(
      t.getTopLeft(find.byKey(const ValueKey('guide-media-reader'))).dx,
      greaterThan(
        t.getTopLeft(find.byKey(const ValueKey('guide-topic-reader'))).dx,
      ),
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'video is lazy, explicit play/pause/seek/restart and ended replay',
    (t) async {
      final videos = <_FakeVideo>[], assets = <String>[];
      await t.pumpWidget(
        _host(
          factory: (asset) {
            assets.add(asset);
            final v = _FakeVideo();
            videos.add(v);
            return v;
          },
        ),
      );
      await t.pumpAndSettle();
      expect(videos, isEmpty);
      final play = find.byKey(const ValueKey('guide-play-reader'));
      await t.ensureVisible(play);
      await _tap(t, play);
      await t.pumpAndSettle();
      expect(assets.single, 'assets/tutorials/en/reader.mp4');
      final v = videos.single;
      expect(v.playing, true);
      await _tap(t, play);
      await t.pumpAndSettle();
      expect(v.playing, false);
      final slider = t.widget<Slider>(find.byType(Slider));
      slider.onChanged!(18000);
      await t.pump();
      expect(v.position.inSeconds, 18);
      await _tap(t, find.text('Restart video'));
      await t.pumpAndSettle();
      expect(v.position, Duration.zero);
      expect(v.playing, true);
      v.position = v.duration;
      v.playing = false;
      v.notifyListeners();
      await t.pumpAndSettle();
      expect(find.textContaining('Lesson complete'), findsOneWidget);
      await _tap(t, play);
      await t.pumpAndSettle();
      expect(v.position, Duration.zero);
      expect(v.playing, true);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(v.released, true);
    },
  );
  testWidgets(
    'topic switch releases prior video and never autoplays next lesson',
    (t) async {
      final videos = <_FakeVideo>[];
      await t.pumpWidget(
        _host(
          factory: (_) {
            final v = _FakeVideo();
            videos.add(v);
            return v;
          },
        ),
      );
      await t.pumpAndSettle();
      final play = find.byKey(const ValueKey('guide-play-reader'));
      await t.ensureVisible(play);
      await _tap(t, play);
      await t.pumpAndSettle();
      final next = find.byKey(const ValueKey('guide-topic-library'));
      await t.ensureVisible(next);
      await t.pumpAndSettle();
      await _tap(t, next);
      await t.pumpAndSettle();
      expect(videos.single.released, true);
      expect(videos.length, 1);
      expect(_poster(t, 'library'), endsWith('/en/library.png'));
    },
  );
  testWidgets(
    'locale switch releases old decoder and chooses correct localized video',
    (t) async {
      final videos = <_FakeVideo>[], assets = <String>[];
      TutorialVideoController factory(String asset) {
        assets.add(asset);
        final v = _FakeVideo();
        videos.add(v);
        return v;
      }

      await t.pumpWidget(_host(factory: factory));
      await t.pumpAndSettle();
      await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
      await t.pumpAndSettle();
      await t.pumpWidget(_host(locale: 'es', factory: factory));
      await t.pumpAndSettle();
      expect(videos.first.released, true);
      expect(videos.length, 1);
      await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
      await t.pumpAndSettle();
      expect(assets.last, 'assets/tutorials/es/reader.mp4');
    },
  );
  testWidgets(
    'decoder failure preserves written steps and allows fresh retry',
    (t) async {
      final videos = <_FakeVideo>[];
      await t.pumpWidget(
        _host(
          factory: (_) {
            final v = _FakeVideo()..rejectInitialize = videos.isEmpty;
            videos.add(v);
            return v;
          },
        ),
      );
      await t.pumpAndSettle();
      await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
      await t.pumpAndSettle();
      expect(find.text('Retry video'), findsOneWidget);
      expect(find.textContaining('Use page arrows'), findsOneWidget);
      await _tap(t, find.text('Retry video'));
      await t.pumpAndSettle();
      expect(videos.length, 2);
      expect(videos.first.released, true);
      expect(videos.last.playing, true);
    },
  );
  testWidgets('lifecycle pause stops video, resume does not autoplay', (
    t,
  ) async {
    final v = _FakeVideo();
    await t.pumpWidget(_host(factory: (_) => v));
    await t.pumpAndSettle();
    await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
    await t.pumpAndSettle();
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await t.pump();
    expect(v.playing, false);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pump();
    expect(v.playing, false);
  });
  testWidgets('runtime decoder error retries with a fresh controller', (
    t,
  ) async {
    final videos = <_FakeVideo>[];
    await t.pumpWidget(
      _host(
        factory: (_) {
          final v = _FakeVideo();
          videos.add(v);
          return v;
        },
      ),
    );
    await t.pumpAndSettle();
    await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
    videos.first.hasError = true;
    videos.first.notifyListeners();
    await t.pumpAndSettle();
    await _tap(t, find.text('Retry video'));
    expect(videos.length, 2);
    expect(videos.first.released, true);
    expect(videos.last.playing, true);
  });
  testWidgets(
    'reduced motion stays still and permits an explicit user choice',
    (t) async {
      var created = 0;
      final v = _FakeVideo();
      await t.pumpWidget(
        _host(
          reducedMotion: true,
          factory: (_) {
            created++;
            return v;
          },
        ),
      );
      await t.pumpAndSettle();
      expect(created, 0);
      expect(_poster(t, 'reader'), endsWith('.png'));
      expect(find.textContaining('Reduced motion'), findsOneWidget);
      await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
      await t.pumpAndSettle();
      expect(v.playing, true);
    },
  );
  testWidgets(
    'enlargement pauses inline video and shares one decoder, Escape pauses',
    (t) async {
      final v = _FakeVideo();
      var created = 0;
      await t.pumpWidget(
        _host(
          factory: (_) {
            created++;
            return v;
          },
        ),
      );
      await t.pumpAndSettle();
      await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
      await t.pumpAndSettle();
      await _tap(t, find.byKey(const ValueKey('guide-larger-reader')));
      await t.pumpAndSettle();
      expect(v.playing, false);
      expect(created, 1);
      expect(find.byKey(const ValueKey('test-video-surface')), findsOneWidget);
      await _tap(t, find.byKey(const ValueKey('guide-larger-play')));
      await t.pumpAndSettle();
      expect(v.playing, true);
      expect(created, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(v.playing, false);
    },
  );
  for (final locale in ['ar', 'en', 'es']) {
    testWidgets(
      '$locale portrait full-screen zoom bounds, pan and reset keep controls outside',
      (t) async {
        await t.binding.setSurfaceSize(const Size(375, 812));
        addTearDown(() => t.binding.setSurfaceSize(null));
        final v = _FakeVideo();
        await t.pumpWidget(
          _host(locale: locale, textScale: 2, factory: (_) => v),
        );
        await t.pumpAndSettle();
        await _tap(t, find.byKey(const ValueKey('guide-larger-reader')));
        final viewer = t.widget<InteractiveViewer>(
          find.byKey(const ValueKey('guide-video-zoom')),
        );
        expect(viewer.minScale, 1);
        expect(viewer.maxScale, 4);
        final scale = viewer.transformationController!;
        expect(scale.value.getMaxScaleOnAxis(), 1);
        final zoomIn = find.byKey(const ValueKey('guide-zoom-in'));
        for (var i = 0; i < 6; i++) {
          await _tap(t, zoomIn);
        }
        expect(scale.value.getMaxScaleOnAxis(), 4);
        expect(t.widget<OutlinedButton>(zoomIn).onPressed, isNull);
        await t.ensureVisible(find.byKey(const ValueKey('guide-video-zoom')));
        await t.pumpAndSettle();
        await t.drag(
          find.byKey(const ValueKey('guide-video-zoom')),
          const Offset(35, 20),
        );
        await t.pumpAndSettle();
        expect(scale.value.storage[12], isNot(0));
        await _tap(t, find.byKey(const ValueKey('guide-reset-zoom')));
        expect(scale.value, Matrix4.identity());
        expect(
          find.ancestor(
            of: find.byKey(const ValueKey('guide-larger-play')),
            matching: find.byType(InteractiveViewer),
          ),
          findsNothing,
        );
        expect(t.takeException(), null);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
      },
    );
  }
  for (final initial in [const Size(375, 812), const Size(1440, 1000)]) {
    testWidgets(
      'playing enlarged lesson survives ${initial.width}px to812x375 reflow with one decoder',
      (t) async {
        await t.binding.setSurfaceSize(initial);
        addTearDown(() => t.binding.setSurfaceSize(null));
        final v = _FakeVideo();
        var created = 0;
        await t.pumpWidget(
          _host(
            factory: (_) {
              created++;
              return v;
            },
          ),
        );
        await t.pumpAndSettle();
        await _tap(t, find.byKey(const ValueKey('guide-play-reader')));
        await _tap(t, find.byKey(const ValueKey('guide-larger-reader')));
        await _tap(t, find.byKey(const ValueKey('guide-larger-play')));
        await t.binding.setSurfaceSize(const Size(812, 375));
        await t.pumpAndSettle();
        expect(created, 1);
        expect(v.released, false);
        expect(v.playing, true);
        expect(
          find.byKey(const ValueKey('test-video-surface')),
          findsOneWidget,
        );
        final pane = t.getSize(find.byKey(const ValueKey('guide-video-zoom')));
        expect(pane.width, greaterThan(500));
        expect(pane.height, greaterThan(230));
        expect(
          find.byKey(const ValueKey('guide-larger-close')),
          findsOneWidget,
        );
        expect(t.takeException(), null);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(v.playing, false);
      },
    );
  }
  testWidgets(
    'large-text missing poster explanation is outside the clipped video surface',
    (t) async {
      await t.binding.setSurfaceSize(const Size(320, 812));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        DefaultAssetBundle(
          bundle: _MissingTutorialBundle(),
          child: _host(locale: 'es', textScale: 2),
        ),
      );
      await t.pumpAndSettle();
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      final message = find.text(l.guideMediaUnavailable);
      expect(message, findsOneWidget);
      expect(
        find.ancestor(of: message, matching: find.byType(ClipRRect)),
        findsNothing,
      );
      expect(find.text(l.guideWrittenSteps), findsOneWidget);
      expect(t.takeException(), null);
    },
  );
  testWidgets('Settings guide opens locally and Back restores Settings', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = _ReminderPreferences();
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
    await t.pumpWidget(
      _host(
        home: Scaffold(
          body: SettingsPage(
            locale: const Locale('en'),
            themeMode: ThemeMode.system,
            onLocaleChanged: (_) {},
            onThemeModeChanged: (_) {},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await _tap(t, find.text('Open the guide'));
    await t.pumpAndSettle();
    expect(find.byType(UserGuidePage), findsOneWidget);
    await _tap(t, find.byType(BackButton));
    await t.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  for (final locale in ['ar', 'en', 'es']) {
    testWidgets('$locale navigation sheet has a translated Close control', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(locale: locale, home: const _NavigationHost()),
      );
      await tester.tap(find.text('Open test panel'));
      await tester.pumpAndSettle();
      final close = find.byKey(const ValueKey('reader-navigation-close'));
      final context = tester.element(close);
      expect(
        find.text(MaterialLocalizations.of(context).closeButtonLabel),
        findsOneWidget,
      );
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Escape dismisses the navigation sheet', (tester) async {
    await tester.pumpWidget(_host(home: const _NavigationHost()));
    await tester.tap(find.text('Open test panel'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsNothing);
  });

  testWidgets(
    'Escape dismisses an expanded group after focus leaves the frame',
    (tester) async {
      await tester.pumpWidget(_host(home: const _NavigationHost()));
      await tester.tap(find.text('Open test panel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bookmark group'));
      await tester.pumpAndSettle();
      expect(find.text('Saved Ayah'), findsOneWidget);
      final frameFocus = Focus.of(
        tester.element(find.byKey(const ValueKey('navigation-test-content'))),
      );
      frameFocus.unfocus();
      await tester.pump();
      expect(frameFocus.hasFocus, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Escape cannot dismiss a sheet underneath another dialog', (
    tester,
  ) async {
    await tester.pumpWidget(_host(home: const _NavigationHost()));
    await tester.tap(find.text('Open test panel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookmark group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open nested dialog'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(ReaderNavigationFrame), findsOneWidget);
    await tester.tap(find.text('Close nested dialog'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _NavigationHost extends StatelessWidget {
  const _NavigationHost();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ReaderNavigationFrame(
          child: SizedBox(height: 300, child: _NavigationTestContent()),
        ),
      ),
      child: const Text('Open test panel'),
    ),
  );
}

class _NavigationTestContent extends StatelessWidget {
  const _NavigationTestContent();

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey('navigation-test-content'),
    children: [
      const Text('Test panel'),
      ExpansionTile(
        title: const Text('Bookmark group'),
        children: [
          const ListTile(title: Text('Saved Ayah')),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close nested dialog'),
                ),
              ),
            ),
            child: const Text('Open nested dialog'),
          ),
        ],
      ),
    ],
  );
}

final class _ReminderPreferences extends SharedPreferencesAsyncPlatform {
  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async =>
      false;
  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async =>
      null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _tap(WidgetTester t, Finder control) async {
  await t.ensureVisible(control);
  await t.pumpAndSettle();
  await t.tap(control);
  await t.pumpAndSettle();
}

class _MissingTutorialBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith('assets/tutorials/')) {
      throw FlutterError('Missing poster in fault test');
    }
    return rootBundle.load(key);
  }
}
