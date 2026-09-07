import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_flutter/features/account/data/account_repository.dart';
import 'package:quran_flutter/features/account/domain/account_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _session = AccountSession(
  email: 'reader@example.com',
  displayName: 'Reader',
  accessToken: 'test-token',
);

const _storedSession = {
  'account.access_token.v1': 'test-token',
  'account.email.v1': 'reader@example.com',
  'account.display_name.v1': 'Reader',
  'unrelated.secure.value': 'keep-me',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({
      'plans.khatmah.v1': '{"completedPages":42}',
      'plans.memorization.v1': '[{"surahNumber":1}]',
      'reader.lastPage': 42,
    });
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

  test(
    'an unauthorized sync persistently expires only the cloud session',
    () async {
      FlutterSecureStorage.setMockInitialValues({..._storedSession});
      final preferences = await SharedPreferences.getInstance();
      final repository = AccountRepository(
        client: MockClient((_) async => http.Response('{}', 401)),
        apiBaseUri: Uri.parse('https://api.example.com'),
      );
      await expectLater(
        repository.restore(_session),
        throwsA(
          isA<AccountFailure>().having(
            (failure) => failure.kind,
            'kind',
            AccountFailureKind.unauthorized,
          ),
        ),
      );
      expect(await repository.loadSession(), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'unrelated.secure.value'),
        'keep-me',
      );
      expect(preferences.getInt('reader.lastPage'), 42);
      expect(
        preferences.getString('plans.khatmah.v1'),
        '{"completedPages":42}',
      );
    },
  );

  test('API roots accept HTTPS and loopback-only HTTP development', () {
    for (final root in [
      'https://quranhaven.org/api',
      'https://api.example.com/',
      'http://localhost:8000',
      'http://127.0.0.1:8000',
      'http://[::1]:8000',
    ]) {
      final repository = AccountRepository(apiBaseUri: Uri.parse(root));
      expect(repository.isConfigured, isTrue, reason: root);
      expect(repository.hasInvalidConfiguration, isFalse, reason: root);
    }
  });

  test('unsafe API roots fail before credentials can be sent', () async {
    for (final root in [
      'http://quranhaven.org/api',
      'http://localhost.example.com',
      'http://192.168.1.2:8000',
      'https://user:secret@api.example.com',
      'https://api.example.com?token=secret',
      'https://api.example.com#fragment',
      'file:///api',
      '/api',
      'https:///api',
    ]) {
      var requested = false;
      final repository = AccountRepository(
        apiBaseUri: Uri.parse(root),
        client: MockClient((_) async {
          requested = true;
          return http.Response('{}', 200);
        }),
      );
      expect(repository.hasInvalidConfiguration, isTrue, reason: root);
      await expectLater(
        repository.signIn(email: _session.email, password: 'long-password'),
        throwsA(
          isA<AccountFailure>().having(
            (failure) => failure.kind,
            'kind',
            AccountFailureKind.invalidConfiguration,
          ),
        ),
        reason: root,
      );
      expect(requested, isFalse, reason: root);
    }
  });

  test(
    'deleting an account removes its session but preserves device data',
    () async {
      FlutterSecureStorage.setMockInitialValues({..._storedSession});
      final preferences = await SharedPreferences.getInstance();
      final before = {
        for (final key in preferences.getKeys()) key: preferences.get(key),
      };
      final repository = AccountRepository(
        apiBaseUri: Uri.parse('https://quranhaven.org/api/'),
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString(),
            'https://quranhaven.org/api/v1/account',
          );
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response('', 204);
        }),
      );

      await repository.deleteAccount(_session);

      expect(await repository.loadSession(), isNull);
      expect(await const FlutterSecureStorage().readAll(), {
        'unrelated.secure.value': 'keep-me',
      });
      expect({
        for (final key in preferences.getKeys()) key: preferences.get(key),
      }, before);
    },
  );

  test('failed deletion does not discard the saved cloud session', () async {
    FlutterSecureStorage.setMockInitialValues({..._storedSession});
    final repository = AccountRepository(
      apiBaseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response('{}', 500)),
    );

    await expectLater(
      repository.deleteAccount(_session),
      throwsA(isA<AccountFailure>()),
    );
    expect((await repository.loadSession())?.accessToken, _session.accessToken);
  });

  test(
    'rate limiting is distinct from server failure and keeps the session',
    () async {
      FlutterSecureStorage.setMockInitialValues({..._storedSession});
      final repository = AccountRepository(
        apiBaseUri: Uri.parse('https://api.example.com'),
        client: MockClient((_) async => http.Response('{}', 429)),
      );

      await expectLater(
        repository.backup(session: _session, data: {'last_read_page': 42}),
        throwsA(
          isA<AccountFailure>().having(
            (failure) => failure.kind,
            'kind',
            AccountFailureKind.rateLimited,
          ),
        ),
      );
      expect(
        (await repository.loadSession())?.accessToken,
        _session.accessToken,
      );
    },
  );

  test('wrong sign-in credentials do not erase an existing session', () async {
    FlutterSecureStorage.setMockInitialValues({..._storedSession});
    final repository = AccountRepository(
      apiBaseUri: Uri.parse('https://api.example.com'),
      client: MockClient((_) async => http.Response('{}', 401)),
    );

    await expectLater(
      repository.signIn(email: _session.email, password: 'wrong-password'),
      throwsA(
        isA<AccountFailure>().having(
          (failure) => failure.kind,
          'kind',
          AccountFailureKind.invalidCredentials,
        ),
      ),
    );
    expect((await repository.loadSession())?.accessToken, _session.accessToken);
  });

  test(
    'malformed authentication data is reported without saving a session',
    () async {
      final repository = AccountRepository(
        apiBaseUri: Uri.parse('https://api.example.com'),
        client: MockClient((_) async => http.Response('{"user":{}}', 200)),
      );

      await expectLater(
        repository.signIn(email: _session.email, password: 'long-password'),
        throwsA(
          isA<AccountFailure>().having(
            (failure) => failure.kind,
            'kind',
            AccountFailureKind.server,
          ),
        ),
      );
      expect(await repository.loadSession(), isNull);
    },
  );
}
