import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/account_models.dart';

class AccountRepository {
  AccountRepository({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    Uri? apiBaseUri,
  }) : _client = client ?? http.Client(),
       _storage = secureStorage ?? const FlutterSecureStorage(),
       _apiBaseUri = apiBaseUri ?? AppConfig.apiBaseUri;

  static const _tokenKey = 'account.access_token.v1';
  static const _emailKey = 'account.email.v1';
  static const _displayNameKey = 'account.display_name.v1';
  static const _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final Uri? _apiBaseUri;

  bool get isConfigured => _apiBaseUri != null;

  Future<AccountSession?> loadSession() async {
    final values = await Future.wait([
      _storage.read(key: _tokenKey),
      _storage.read(key: _emailKey),
      _storage.read(key: _displayNameKey),
    ]);
    final token = values[0];
    final email = values[1];
    if (token == null || email == null) return null;
    return AccountSession(
      email: email,
      displayName: values[2] ?? email.split('@').first,
      accessToken: token,
    );
  }

  Future<AccountSession> register({
    required String displayName,
    required String email,
    required String password,
  }) {
    return _authenticate(
      path: '/v1/auth/register',
      body: {
        'display_name': displayName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
  }

  Future<AccountSession> signIn({
    required String email,
    required String password,
  }) {
    return _authenticate(
      path: '/v1/auth/login',
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _displayNameKey),
    ]);
  }

  Future<CloudBackup> backup({
    required AccountSession session,
    required Map<String, Object?> data,
  }) async {
    final response = await _send(
      () => _client.put(
        _endpoint('/v1/sync'),
        headers: _headers(session.accessToken),
        body: jsonEncode({'data': data}),
      ),
    );
    return _decodeBackup(response);
  }

  Future<CloudBackup> restore(AccountSession session) async {
    final response = await _send(
      () => _client.get(
        _endpoint('/v1/sync'),
        headers: _headers(session.accessToken),
      ),
    );
    return _decodeBackup(response);
  }

  Future<AccountSession> _authenticate({
    required String path,
    required Map<String, String> body,
  }) async {
    final response = await _send(
      () => _client.post(
        _endpoint(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
      authenticating: true,
    );
    final data = _decodeObject(response.body);
    final user = data['user']! as Map<String, Object?>;
    final session = AccountSession(
      email: user['email']! as String,
      displayName: user['display_name']! as String,
      accessToken: data['access_token']! as String,
    );
    await Future.wait([
      _storage.write(key: _tokenKey, value: session.accessToken),
      _storage.write(key: _emailKey, value: session.email),
      _storage.write(key: _displayNameKey, value: session.displayName),
    ]);
    return session;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool authenticating = false,
  }) async {
    if (!isConfigured) {
      throw const AccountFailure(AccountFailureKind.unavailable);
    }
    try {
      final response = await request().timeout(_requestTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      if (response.statusCode == 401) {
        throw AccountFailure(
          authenticating
              ? AccountFailureKind.invalidCredentials
              : AccountFailureKind.unauthorized,
        );
      }
      if (response.statusCode == 409) {
        throw const AccountFailure(AccountFailureKind.emailAlreadyUsed);
      }
      if (response.statusCode == 422) {
        throw const AccountFailure(AccountFailureKind.validation);
      }
      throw const AccountFailure(AccountFailureKind.server);
    } on AccountFailure {
      rethrow;
    } on TimeoutException {
      throw const AccountFailure(AccountFailureKind.unavailable);
    } on http.ClientException {
      throw const AccountFailure(AccountFailureKind.unavailable);
    }
  }

  CloudBackup _decodeBackup(http.Response response) {
    final data = _decodeObject(response.body);
    final rawData = data['data'];
    return CloudBackup(
      data: rawData == null ? null : rawData as Map<String, Object?>,
      revision: (data['revision'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? ''),
    );
  }

  Uri _endpoint(String path) {
    final base = _apiBaseUri!;
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(path: '$basePath$path');
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, Object?> _decodeObject(String body) {
    try {
      return jsonDecode(body) as Map<String, Object?>;
    } on FormatException {
      throw const AccountFailure(AccountFailureKind.server);
    } on TypeError {
      throw const AccountFailure(AccountFailureKind.server);
    }
  }
}
