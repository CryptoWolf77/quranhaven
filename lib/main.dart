import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';

import 'app/quran_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Noto Sans Bengali',
    ], await rootBundle.loadString('assets/fonts/OFL-NotoSansBengali.txt'));
  });
  QuranContentConfig.configure(
    baseUrl: AppConfig.contentBaseUri?.toString(),
    allowUpstreamFallback: false,
  );
  await QuranLibrary.init();
  QuranLibrary.initWordAudio();
  runApp(const QuranApp());
}
