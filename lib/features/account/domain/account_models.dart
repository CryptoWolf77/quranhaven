class AccountSession {
  const AccountSession({
    required this.email,
    required this.displayName,
    required this.accessToken,
  });

  final String email;
  final String displayName;
  final String accessToken;
}

class CloudBackup {
  const CloudBackup({
    required this.data,
    required this.revision,
    required this.updatedAt,
  });

  final Map<String, Object?>? data;
  final int revision;
  final DateTime? updatedAt;
}

enum AccountFailureKind {
  unavailable,
  invalidConfiguration,
  invalidCredentials,
  emailAlreadyUsed,
  validation,
  unauthorized,
  rateLimited,
  server,
}

class AccountFailure implements Exception {
  const AccountFailure(this.kind);

  final AccountFailureKind kind;
}
