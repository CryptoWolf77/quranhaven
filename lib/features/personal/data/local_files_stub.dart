import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'local_restore_lifecycle.dart';

bool get supportsLocalFiles => true;
bool get localFilesUseShareSheet => Platform.isIOS;
Future<String?> chooseBackupFile({Future<XFile?> Function()? picker}) async {
  final file = picker != null
      ? await picker()
      : await openFile(
          acceptedTypeGroups: const [
            XTypeGroup(
              label: 'JSON',
              extensions: ['json'],
              mimeTypes: ['application/json'],
              uniformTypeIdentifiers: ['public.json'],
            ),
          ],
        );
  if (file == null) return null;
  return readBoundedBackupFile(file);
}

Future<String> readBoundedBackupFile(XFile file) async {
  const cap = 5 * 1024 * 1024;
  if (await file.length() > cap) {
    throw const FormatException('Backup is too large');
  }
  final buffer = BytesBuilder(copy: false);
  await for (final chunk in file.openRead()) {
    if (buffer.length + chunk.length > cap) {
      throw const FormatException('Backup is too large');
    }
    buffer.add(chunk);
  }
  return utf8.decode(buffer.takeBytes(), allowMalformed: false);
}

Future<bool> downloadLocalFile(
  Uint8List bytes,
  String name,
  String mime, {
  Rect? origin,
}) async {
  if (Platform.isAndroid) {
    return saveAndroidDocument(bytes, name, mime);
  }
  if (localFilesUseShareSheet) {
    return shareLocalFile(bytes, name, mime, origin: origin);
  }
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return false;
  await XFile.fromData(bytes, mimeType: mime, name: name).saveTo(location.path);
  return true;
}

Future<bool> saveAndroidDocument(
  Uint8List bytes,
  String name,
  String mime,
) async {
  const documents = MethodChannel('org.quranhaven/local_documents');
  final cap = mime == 'application/json' ? 5 * 1024 * 1024 : 32 * 1024 * 1024;
  if (!['application/json', 'image/png'].contains(mime) ||
      bytes.isEmpty ||
      bytes.length > cap ||
      !RegExp(
        r'^[A-Za-z0-9][A-Za-z0-9._ -]{0,127}\.(json|png)$',
      ).hasMatch(name)) {
    throw const FormatException('Invalid local export');
  }
  if ((mime == 'application/json' && !name.endsWith('.json')) ||
      (mime == 'image/png' && !name.endsWith('.png'))) {
    throw const FormatException('Invalid local export type');
  }
  return await documents.invokeMethod<bool>('save', {
        'bytes': bytes,
        'name': name,
        'mime': mime,
      }) ??
      false;
}

Future<bool> shareLocalFile(
  Uint8List bytes,
  String name,
  String mime, {
  Rect? origin,
  Future<ShareResult> Function(ShareParams)? share,
}) async {
  if (origin == null || origin.isEmpty) {
    throw StateError('Share sheet requires a visible origin');
  }
  final result = await (share ?? SharePlus.instance.share)(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: mime)],
      fileNameOverrides: [name],
      sharePositionOrigin: origin,
    ),
  );
  // A chosen share action is not proof the destination saved the file.
  return result.status == ShareResultStatus.success;
}

Future<void> reloadAfterRestore() => LocalRestoreLifecycle.refresh();
