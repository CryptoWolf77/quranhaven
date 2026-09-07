import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../account/presentation/account_card.dart';
import '../../account/domain/reading_preferences.dart';
import '../../offline/presentation/offline_card.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../reminders/data/reminder_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.currentPage,
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.onCloudRestored,
    required this.onPreferencesRestored,
    super.key,
  });

  final int currentPage;
  final Locale? locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<int> onCloudRestored;
  final Future<void> Function(ReadingPreferences) onPreferencesRestored;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ReminderRepository _reminderRepository = ReminderRepository();
  final ReminderService _reminderService = ReminderService();

  ReminderSettings _reminder = const ReminderSettings(
    enabled: false,
    hour: 19,
    minute: 0,
  );
  bool _reminderLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final reminder = await _reminderRepository.load();
    if (!mounted) return;
    setState(() {
      _reminder = reminder;
      _reminderLoading = false;
    });
  }

  Future<void> _toggleReminder(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _reminderLoading = true);
    if (!enabled) {
      await _reminderService.cancelDaily();
      final updated = _reminder.copyWith(enabled: false);
      await _reminderRepository.save(updated);
      if (mounted) {
        setState(() {
          _reminder = updated;
          _reminderLoading = false;
        });
      }
      return;
    }

    final scheduled = await _reminderService.scheduleDaily(
      hour: _reminder.hour,
      minute: _reminder.minute,
      title: l10n.dailyReminderTitle,
      body: l10n.dailyReminderBody,
    );
    if (!mounted) return;
    final updated = _reminder.copyWith(enabled: scheduled);
    await _reminderRepository.save(updated);
    if (!mounted) return;
    setState(() {
      _reminder = updated;
      _reminderLoading = false;
    });
    _message(scheduled ? l10n.reminderEnabled : l10n.notificationDenied);
  }

  Future<void> _chooseReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminder.hour, minute: _reminder.minute),
    );
    if (selected == null || !mounted) return;
    final updated = _reminder.copyWith(
      hour: selected.hour,
      minute: selected.minute,
    );
    setState(() {
      _reminder = updated;
      _reminderLoading = true;
    });
    await _reminderRepository.save(updated);
    if (!mounted) return;
    if (updated.enabled) {
      final l10n = AppLocalizations.of(context);
      await _reminderService.scheduleDaily(
        hour: updated.hour,
        minute: updated.minute,
        title: l10n.dailyReminderTitle,
        body: l10n.dailyReminderBody,
      );
    }
    if (mounted) setState(() => _reminderLoading = false);
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
              AccountCard(
                currentPage: widget.currentPage,
                locale: widget.locale,
                themeMode: widget.themeMode,
                onCloudRestored: widget.onCloudRestored,
                onPreferencesRestored: widget.onPreferencesRestored,
              ),
              const SizedBox(height: 14),
              if (kIsWeb) ...[const OfflineCard(), const SizedBox(height: 14)],
              _SettingsCard(
                title: l10n.dailyReminder,
                icon: Icons.notifications_none_rounded,
                child: _ReminderControls(
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
