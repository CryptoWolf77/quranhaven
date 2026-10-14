import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/guide/presentation/user_guide_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var totalBytes = 0;
  for (final language in ['ar', 'en', 'es']) {
    test(
      'all13 actual H264 MP4 lessons and matching posters bundled for $language',
      () async {
        for (final topic in tutorialTopicIds) {
          final prefix = 'assets/tutorials/$language/$topic';
          final data = await rootBundle.load('$prefix.mp4');
          final bytes = data.buffer.asUint8List();
          totalBytes += bytes.length;
          expect(
            bytes.length,
            greaterThan(10000),
            reason: '$topic is an actual recording',
          );
          expect(bytes.length, lessThanOrEqualTo(3 * 1024 * 1024));
          final structure = latin1.decode(bytes);
          expect(structure.substring(4, 8), 'ftyp');
          expect(structure, contains('moov'));
          expect(structure, contains('mdat'));
          expect(
            structure,
            contains('avc1'),
            reason: 'H264 compatible with web, Android and iOS',
          );
          final poster = await rootBundle.load('$prefix.png');
          totalBytes += poster.lengthInBytes;
          final codec = await ui.instantiateImageCodec(
            poster.buffer.asUint8List(),
          );
          expect(codec.frameCount, 1);
          final frame = await codec.getNextFrame();
          expect(frame.image.width / frame.image.height, closeTo(16 / 9, 0.01));
          expect(frame.image.width, greaterThanOrEqualTo(960));
          frame.image.dispose();
          codec.dispose();
        }
      },
    );
  }
  test('all bundled tutorial media stays within40MiB budget', () {
    expect(totalBytes, greaterThan(0));
    expect(totalBytes, lessThanOrEqualTo(40 * 1024 * 1024));
  });
}
