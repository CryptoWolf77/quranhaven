import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_flutter/features/account/data/account_repository.dart';
import 'package:quran_flutter/features/account/domain/account_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('registration saves the returned session securely', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/auth/register');
      return http.Response(
        jsonEncode({
          'access_token': 'test-token',
          'token_type': 'bearer',
          'user': {
            'id': 'user-id',
            'email': 'reader@example.com',
            'display_name': 'Reader',
          },
        }),
        201,
      );
    });
    final repository = AccountRepository(
      client: client,
      apiBaseUri: Uri.parse('https://api.example.com'),
    );

    final registered = await repository.register(
      displayName: 'Reader',
      email: 'Reader@Example.com',
      password: 'long-password',
    );
    final restored = await repository.loadSession();

    expect(registered.accessToken, 'test-token');
    expect(restored?.email, 'reader@example.com');
    expect(restored?.displayName, 'Reader');
  });

  test('an unauthorized sync response expires the session action', () async {
    final repository = AccountRepository(
      client: MockClient((_) async => http.Response('{}', 401)),
      apiBaseUri: Uri.parse('https://api.example.com'),
    );
    const session = AccountSession(
      email: 'reader@example.com',
      displayName: 'Reader',
      accessToken: 'expired',
    );

    await expectLater(
      repository.restore(session),
      throwsA(
        isA<AccountFailure>().having(
          (failure) => failure.kind,
          'kind',
          AccountFailureKind.unauthorized,
        ),
      ),
    );
  });
}
