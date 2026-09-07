import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import 'app/quran_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  QuranContentConfig.configure(
    baseUrl: AppConfig.contentBaseUri?.toString(),
    allowUpstreamFallback: false,
  );
  await QuranLibrary.init();
  QuranLibrary.initWordAudio();
  runApp(const QuranApp());
}
