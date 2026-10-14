import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';
import 'package:web/web.dart' as web;

bool get supportsLocalFiles => true;
bool get localFilesUseShareSheet => false;
Future<String?> chooseBackupFile() async {
  final result = Completer<String?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.json,application/json';
  input.style.display = 'none';
  web.document.body!.append(input);
  void finish(String? text) {
    if (!result.isCompleted) {
      result.complete(text);
    }
    input.remove();
  }

  void fail(Object error) {
    input.remove();
    if (!result.isCompleted) {
      result.completeError(error);
    }
  }

  input.oncancel = ((web.Event e) => finish(null)).toJS;
  Future<void> readSelectedFile() async {
    final file = input.files?.item(0);
    if (file == null) {
      finish(null);
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      fail(const FormatException('Backup is too large'));
      return;
    }
    try {
      final text = await file.text().toDart;
      finish(text.toDart);
    } catch (e) {
      fail(e);
    }
  }

  input.onchange = ((web.Event e) {
    unawaited(readSelectedFile());
  }).toJS;
  input.click();
  return result.future;
}

Future<bool> downloadLocalFile(
  Uint8List bytes,
  String name,
  String mime, {
  Rect? origin,
}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  Timer(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
  return true;
}

Future<void> reloadAfterRestore() async => web.window.location.reload();
