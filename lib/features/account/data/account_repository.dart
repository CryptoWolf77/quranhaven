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
       _apiBaseUri = apiBaseUri ?? Uri.tryParse(AppConfig.apiBaseUrl.trim()),
       _hasApiValue =
           apiBaseUri != null || AppConfig.apiBaseUrl.trim().isNotEmpty;

  static const _tokenKey = 'account.access_token.v1';
  static const _emailKey = 'account.email.v1';
  static const _displayNameKey = 'account.display_name.v1';
  static const _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final Uri? _apiBaseUri;
  final bool _hasApiValue;

  bool get isConfigured =>
      _apiBaseUri != null && isValidApiBaseUri(_apiBaseUri);

  bool get hasInvalidConfiguration => _hasApiValue && !isConfigured;

  /// Account credentials must use HTTPS, except for loopback development.
  static bool isValidApiBaseUri(Uri uri) {
    if (!uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return false;
    }
    final isLoopback = const {
      'localhost',
      '127.0.0.1',
      '::1',
    }.contains(uri.host);
    return uri.scheme == 'https' || (uri.scheme == 'http' && isLoopback);
  }

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

  /// Deletes the remote account and backup, but never touches device progress.
  Future<void> deleteAccount(AccountSession session) async {
    final response = await _send(
      () => _client.delete(
        _endpoint('/v1/account'),
        headers: _headers(session.accessToken),
      ),
    );
    if (response.statusCode != 204) {
      throw const AccountFailure(AccountFailureKind.server);
    }
    await signOut();
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
    final user = data['user'];
    final token = data['access_token'];
    if (user is! Map<String, Object?> ||
        user['email'] is! String ||
        user['display_name'] is! String ||
        token is! String ||
        token.isEmpty) {
      throw const AccountFailure(AccountFailureKind.server);
    }
    final session = AccountSession(
      email: user['email']! as String,
      displayName: user['display_name']! as String,
      accessToken: token,
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
      throw AccountFailure(
        hasInvalidConfiguration
            ? AccountFailureKind.invalidConfiguration
            : AccountFailureKind.unavailable,
      );
    }
    try {
      final response = await request().timeout(_requestTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      if (response.statusCode == 401) {
        if (!authenticating) await signOut();
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
      if (response.statusCode == 429) {
        throw const AccountFailure(AccountFailureKind.rateLimited);
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
    final revision = data['revision'];
    final rawDate = data['updated_at'];
    final updatedAt = rawDate is String ? DateTime.tryParse(rawDate) : null;
    if (!data.containsKey('data') ||
        (rawData != null && rawData is! Map<String, Object?>) ||
        revision is! int ||
        revision < 0 ||
        (rawDate != null && updatedAt == null)) {
      throw const AccountFailure(AccountFailureKind.server);
    }
    return CloudBackup(
      data: rawData == null ? null : rawData as Map<String, Object?>,
      revision: revision,
      updatedAt: updatedAt,
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
