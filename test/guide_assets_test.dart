import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final language in ['ar', 'en', 'es']) {
    test(
      'four actual guide posters and animations are bundled for $language',
      () async {
        for (final topic in ['reader', 'library', 'plans', 'offline']) {
          for (final extension in ['png', 'gif']) {
            final data = await rootBundle.load(
              'assets/guides/$language/$topic.$extension',
            );
            final codec = await ui.instantiateImageCodec(
              data.buffer.asUint8List(),
            );
            if (extension == 'gif') expect(codec.frameCount, greaterThan(1));
            final frame = await codec.getNextFrame();
            expect(frame.image.width, 1280);
            expect(frame.image.height, 720);
            frame.image.dispose();
            codec.dispose();
          }
        }
      },
    );
  }
}
