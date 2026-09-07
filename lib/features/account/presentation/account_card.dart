import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../plans/data/plans_repository.dart';
import '../data/account_repository.dart';
import '../data/bookmarks_backup_repository.dart';
import '../data/cloud_restore_service.dart';
import '../domain/account_models.dart';
import '../domain/reading_preferences.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({
    required this.currentPage,
    required this.locale,
    required this.themeMode,
    required this.onCloudRestored,
    required this.onPreferencesRestored,
    super.key,
  });

  final int currentPage;
  final Locale? locale;
  final ThemeMode themeMode;
  final ValueChanged<int> onCloudRestored;
  final Future<void> Function(ReadingPreferences) onPreferencesRestored;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final AccountRepository _accounts = AccountRepository();
  final PlansRepository _plans = PlansRepository();

  AccountSession? _session;
  DateTime? _lastSync;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _accounts.loadSession();
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  Future<void> _authenticate({required bool register}) async {
    final request = await showDialog<_AuthRequest>(
      context: context,
      builder: (context) => _AccountDialog(register: register),
    );
    if (request == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final session = register
          ? await _accounts.register(
              displayName: request.displayName,
              email: request.email,
              password: request.password,
            )
          : await _accounts.signIn(
              email: request.email,
              password: request.password,
            );
      if (!mounted) return;
      setState(() => _session = session);
      _message(AppLocalizations.of(context).signedInSuccessfully);
    } on AccountFailure catch (failure) {
      _handleFailure(failure.kind);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup() async {
    final session = _session;
    if (session == null) return;
    setState(() => _busy = true);
    try {
      final planData = await _plans.exportForCloud();
      final backup = await _accounts.backup(
        session: session,
        data: {
          'schema_version': 1,
          'last_read_page': widget.currentPage,
          'plans': planData,
          'bookmarks': BookmarksBackupRepository().exportForCloud(),
          'preferences': {
            'locale': widget.locale?.languageCode,
            'theme_mode': widget.themeMode.name,
          },
        },
      );
      if (!mounted) return;
      setState(() => _lastSync = backup.updatedAt ?? DateTime.now());
      _message(AppLocalizations.of(context).backupComplete);
    } on AccountFailure catch (failure) {
      _handleFailure(failure.kind);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final session = _session;
    if (session == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.restoreBackup),
            content: Text(l10n.restoreBackupWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.restore),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      final backup = await _accounts.restore(session);
      final data = backup.data;
      if (data == null) {
        _message(l10n.noCloudBackup);
        return;
      }
      if (!mounted) return;
      await CloudRestoreService(plans: _plans).restore(
        data: data,
        currentPreferences: ReadingPreferences(
          locale: widget.locale,
          themeMode: widget.themeMode,
        ),
        ayahsInSurah: (surah) => QuranCtrl.instance.surahsList
            .singleWhere((info) => info.number == surah)
            .ayahsNumber,
        pageForAyah: (id) => QuranCtrl.instance.getAyahByUq(id).page,
        onPreferencesRestored: widget.onPreferencesRestored,
        onProgressRestored: (page) {
          if (mounted) widget.onCloudRestored(page ?? widget.currentPage);
        },
      );
      if (!mounted) return;
      setState(() => _lastSync = backup.updatedAt ?? DateTime.now());
      _message(l10n.restoreComplete);
    } on AccountFailure catch (failure) {
      _handleFailure(failure.kind);
    } on TypeError {
      _message(l10n.cloudDataInvalid);
    } on FormatException {
      _message(l10n.cloudDataInvalid);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await _accounts.signOut();
    if (!mounted) return;
    setState(() {
      _session = null;
      _lastSync = null;
    });
  }

  Future<void> _deleteAccount() async {
    final session = _session;
    if (session == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteCloudAccount),
            content: Text(l10n.deleteCloudAccountWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.deleteCloudAccount),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await _accounts.deleteAccount(session);
      if (!mounted) return;
      setState(() {
        _session = null;
        _lastSync = null;
      });
      _message(l10n.cloudAccountDeleted);
    } on AccountFailure catch (failure) {
      _handleFailure(failure.kind);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _handleFailure(AccountFailureKind kind) {
    if (!mounted) return;
    if (kind == AccountFailureKind.unauthorized) {
      setState(() {
        _session = null;
        _lastSync = null;
      });
    }
    _message(_failureMessage(kind));
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _failureMessage(AccountFailureKind kind) {
    final l10n = AppLocalizations.of(context);
    return switch (kind) {
      AccountFailureKind.invalidConfiguration => l10n.cloudInvalidConfiguration,
      AccountFailureKind.invalidCredentials => l10n.invalidCredentials,
      AccountFailureKind.emailAlreadyUsed => l10n.emailAlreadyUsed,
      AccountFailureKind.validation => l10n.accountValidationFailed,
      AccountFailureKind.unauthorized => l10n.sessionExpired,
      AccountFailureKind.rateLimited => l10n.cloudRateLimited,
      AccountFailureKind.server => l10n.cloudServerError,
      AccountFailureKind.unavailable => l10n.cloudUnavailable,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.accountAndSync,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_busy || _loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (!_accounts.isConfigured)
              _InfoPanel(
                icon: Icons.cloud_off_outlined,
                text: _accounts.hasInvalidConfiguration
                    ? l10n.cloudInvalidConfiguration
                    : l10n.cloudNotConfigured,
              )
            else if (_session == null && !_loading) ...[
              Text(l10n.accountOptionalBody),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _authenticate(register: false),
                    icon: const Icon(Icons.login_rounded),
                    label: Text(l10n.signIn),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _authenticate(register: true),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(l10n.createAccount),
                  ),
                ],
              ),
            ] else if (_session != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  foregroundColor: scheme.primary,
                  child: const Icon(Icons.person_outline_rounded),
                ),
                title: Text(
                  _session!.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(_session!.email),
              ),
              if (_lastSync != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.lastSynced(
                      MaterialLocalizations.of(
                        context,
                      ).formatFullDate(_lastSync!.toLocal()),
                    ),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : _backup,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.backupNow),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: Text(l10n.restoreBackup),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _signOut,
                    child: Text(l10n.signOut),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _deleteAccount,
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    icon: const Icon(Icons.person_remove_outlined),
                    label: Text(l10n.deleteCloudAccount),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.accountPrivacyNote,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 11),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AuthRequest {
  const _AuthRequest({
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String displayName;
  final String email;
  final String password;
}

class _AccountDialog extends StatefulWidget {
  const _AccountDialog({required this.register});

  final bool register;

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _AuthRequest(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.register ? l10n.createAccount : l10n.signIn),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.register) ...[
                Text(l10n.cloudRegistrationNotice),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.displayName),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? l10n.displayNameRequired
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.email),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return email.contains('@') && email.contains('.')
                      ? null
                      : l10n.validEmailRequired;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.password,
                  helperText: widget.register ? l10n.passwordRules : null,
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _obscurePassword,
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
                validator: (value) =>
                    (value?.length ?? 0) < 8 ? l10n.passwordTooShort : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.register ? l10n.createAccount : l10n.signIn),
        ),
      ],
    );
  }
}

/// The tooltip describes the action, not the current password visibility.
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    required this.obscured,
    required this.onPressed,
    super.key,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: obscured ? l10n.showPassword : l10n.hidePassword,
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}
