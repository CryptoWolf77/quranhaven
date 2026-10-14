import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/creator_credit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../guide/presentation/user_guide_page.dart';
import '../../offline/presentation/offline_card.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../reminders/data/reminder_service.dart';
import '../../personal/presentation/backup_card.dart';
import 'privacy_contact_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    this.reminderRepository,
    this.reminderService,
    super.key,
  });

  final Locale? locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ReminderRepository? reminderRepository;
  final ReminderService? reminderService;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ReminderRepository _reminderRepository =
      widget.reminderRepository ?? ReminderRepository();
  late final ReminderService _reminderService =
      widget.reminderService ?? ReminderService();

  ReminderSettings _reminder = const ReminderSettings(
    enabled: false,
    hour: 19,
    minute: 0,
  );
  bool _reminderLoading = true;
  bool _reminderLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    if (mounted) {
      setState(() {
        _reminderLoading = true;
        _reminderLoadFailed = false;
      });
    }
    try {
      final reminder = await _reminderRepository.load();
      if (reminder.hour < 0 ||
          reminder.hour > 23 ||
          reminder.minute < 0 ||
          reminder.minute > 59) {
        throw const FormatException('Invalid reminder time');
      }
      if (mounted) setState(() => _reminder = reminder);
    } catch (_) {
      if (mounted) setState(() => _reminderLoadFailed = true);
    } finally {
      if (mounted) setState(() => _reminderLoading = false);
    }
  }

  Future<void> _toggleReminder(bool enabled) async {
    if (_reminderLoading || _reminderLoadFailed) return;
    await _applyReminder(_reminder.copyWith(enabled: enabled));
  }

  Future<void> _chooseReminderTime() async {
    if (_reminderLoading || _reminderLoadFailed) return;
    final device24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final display24 =
        hourFormat(
          of: MaterialLocalizations.of(
            context,
          ).timeOfDayFormat(alwaysUse24HourFormat: device24),
        ) !=
        HourFormat.h;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminder.hour, minute: _reminder.minute),
      // Match the locale's displayed hour, without changing device preferences.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(alwaysUse24HourFormat: device24 || display24),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;
    await _applyReminder(
      _reminder.copyWith(hour: selected.hour, minute: selected.minute),
    );
  }

  Future<void> _applyReminder(ReminderSettings desired) async {
    final l = AppLocalizations.of(context), previous = _reminder;
    setState(() => _reminderLoading = true);
    var cancelled = false, scheduling = false;
    try {
      // Do not claim a replacement until the old notification is cancelled.
      await _reminderService.cancelDaily();
      cancelled = true;
      final off = desired.copyWith(enabled: false);
      await _reminderRepository.save(off);
      if (mounted) setState(() => _reminder = off);
      if (!desired.enabled) return;
      scheduling = true;
      final scheduled = await _reminderService.scheduleDaily(
        hour: desired.hour,
        minute: desired.minute,
        title: l.dailyReminderTitle,
        body: l.dailyReminderBody,
      );
      if (!scheduled) {
        _message(l.notificationDenied);
        return;
      }
      scheduling = false;
      await _reminderRepository.save(desired);
      if (mounted) setState(() => _reminder = desired);
      _message(l.reminderEnabled);
    } catch (_) {
      if (!cancelled) {
        _message(l.reminderUpdateFailed);
        return;
      }
      // Stop a new notification when its enabled preference failed to persist.
      var recovered = true;
      try {
        await _reminderService.cancelDaily();
      } catch (_) {
        recovered = false;
      }
      final safe = previous.copyWith(enabled: false);
      try {
        await _reminderRepository.save(safe);
      } catch (_) {
        recovered = false;
      }
      if (mounted) setState(() => _reminder = safe);
      _message(
        !recovered
            ? l.reminderStateUncertain
            : scheduling
            ? l.reminderUpdateFailed
            : l.localSaveFailed,
      );
    } finally {
      if (mounted) setState(() => _reminderLoading = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedLanguage =
        widget.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsCard(
                title: l10n.guideTitle,
                icon: Icons.help_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guideEntryBody),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const UserGuidePage(),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: Text(l10n.guideOpen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: l10n.localStorageTitle,
                icon: Icons.phone_android_rounded,
                child: Text(l10n.localStorageBody),
              ),
              const SizedBox(height: 14),
              if (kIsWeb) ...[const OfflineCard(), const SizedBox(height: 14)],
              const BackupCard(),
              const SizedBox(height: 14),
              _SettingsCard(
                title: l10n.dailyReminder,
                icon: Icons.notifications_none_rounded,
                child: _reminderLoadFailed
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.localLoadFailed),
                          TextButton(
                            onPressed: _loadReminder,
                            child: Text(l10n.retry),
                          ),
                        ],
                      )
                    : _ReminderControls(
                        settings: _reminder,
                        supported: _reminderService.isSupported,
                        loading: _reminderLoading,
                        onToggle: _toggleReminder,
                        onChooseTime: _chooseReminderTime,
                      ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: l10n.language,
                icon: Icons.language_rounded,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('العربية')),
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'es', label: Text('Español')),
                  ],
                  selected: {selectedLanguage},
                  onSelectionChanged: (value) {
                    widget.onLocaleChanged(Locale(value.first));
                  },
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: l10n.theme,
                icon: Icons.palette_outlined,
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.system),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.light),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.dark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {widget.themeMode},
                  onSelectionChanged: (value) {
                    widget.onThemeModeChanged(value.first);
                  },
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: l10n.about,
                icon: Icons.info_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.aboutBody),
                    TextButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'Quran Haven',
                      ),
                      child: Text(
                        MaterialLocalizations.of(
                          context,
                        ).viewLicensesButtonLabel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.charityMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const PrivacyContactCard(),
              const SizedBox(height: 14),
              const CreatorCredit(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderControls extends StatelessWidget {
  const _ReminderControls({
    required this.settings,
    required this.supported,
    required this.loading,
    required this.onToggle,
    required this.onChooseTime,
  });

  final ReminderSettings settings;
  final bool supported;
  final bool loading;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChooseTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: settings.hour, minute: settings.minute));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.enabled && supported,
          onChanged: supported && !loading ? onToggle : null,
          title: Text(l10n.remindMeDaily),
          subtitle: Text(
            supported ? l10n.reminderBody : l10n.reminderMobileOnly,
          ),
          secondary: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : null,
        ),
        if (supported)
          OutlinedButton.icon(
            onPressed: loading ? null : onChooseTime,
            icon: const Icon(Icons.schedule_rounded),
            label: Text(l10n.reminderTime(time)),
          ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
