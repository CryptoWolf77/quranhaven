import 'package:web/web.dart' as web;

Future<bool> openLearningSource(String url) async {
  final uri = Uri.parse(url);
  if (uri.scheme != 'https' ||
      !const {'corpus.quran.com', 'tanzil.info'}.contains(uri.host)) {
    throw ArgumentError('Invalid source link');
  }
  web.window.open(url, '_blank', 'noopener,noreferrer');
  return true;
}
