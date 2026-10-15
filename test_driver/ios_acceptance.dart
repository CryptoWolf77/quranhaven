import 'dart:io';
import 'dart:convert';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory(
    Platform.environment['IOS_EVIDENCE_DIR'] ?? 'build/ios-acceptance',
  );
  await output.create(recursive: true);
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (name, bytes, [args]) async {
      await File('${output.path}/$name.png').writeAsBytes(bytes);
      if (Platform.environment['IOS_CAPTURE_NETWORK'] == 'true' &&
          driver is VMServiceFlutterDriver) {
        final profile = await driver.serviceClient.callServiceExtension(
          'ext.dart.io.getHttpProfile',
          isolateId: driver.appIsolate.id,
        );
        final requests = (profile.json!['requests'] as List)
            .map(
              (dynamic r) => {
                'method': r['method'],
                'uri': r['uri'],
                'requestContentLength': r['request']?['contentLength'],
                'statusCode': r['response']?['statusCode'],
              },
            )
            .toList();
        await File(
          '${output.path}/native-http-summary.json',
        ).writeAsString(const JsonEncoder.withIndent('  ').convert(requests));
      }
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) => writeResponseData(
      data == null
          ? null
          : (Map<String, dynamic>.from(data)..remove('screenshots')),
      destinationDirectory: output.path,
      testOutputFilename: 'results',
    ),
    writeResponseOnFailure: true,
  );
}
