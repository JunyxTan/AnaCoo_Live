import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../data/database.dart';
import '../../domain/reminder_rule.dart';
import '../../domain/shop_time.dart';
import '../../domain/working_hours.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import '../../services/backup_service.dart';
import '../job/reminder_editor.dart';
import '../widgets/common.dart';
import 'templates_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.tabSettings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (settings) => _Body(settings: settings),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.settings});

  final AppSetting settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final hours = WorkingHours.decode(settings.workingHours);
    final defaults = ReminderRule.decodeList(settings.defaultReminderRules);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        SectionHeader(strings.notificationsSection, icon: Icons.notifications_outlined),
        const _NotificationStatusCard(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.dailyAgenda),
          subtitle: Text(formats.minutesAsClock(settings.dailyAgendaMinutes)),
          value: settings.dailyAgendaEnabled,
          onChanged: (value) => _save(
            ref,
            AppSettingsCompanion(dailyAgendaEnabled: Value(value)),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.dailyAgendaTime),
          trailing: Text(formats.minutesAsClock(settings.dailyAgendaMinutes)),
          onTap: () => _pickAgendaTime(context, ref),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.reminderDefaults),
          subtitle: Text(
            defaults.isEmpty
                ? strings.none
                : defaults.map((r) => describeRule(r, language)).join(' · '),
          ),
          onTap: () => _editDefaultReminders(context, ref, defaults),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.overdueNudges),
          value: settings.overdueNudgesEnabled,
          onChanged: (value) => _save(
            ref,
            AppSettingsCompanion(overdueNudgesEnabled: Value(value)),
          ),
        ),
        _ChoiceRow<int>(
          title: strings.readyNudgeAfter,
          value: settings.readyNudgeDays,
          options: _choices(1, 30, including: settings.readyNudgeDays),
          labelOf: strings.days,
          onPicked: (value) =>
              _save(ref, AppSettingsCompanion(readyNudgeDays: Value(value))),
        ),
        SectionHeader(strings.workingHours, icon: Icons.access_time),
        for (var weekday = 1; weekday <= 7; weekday++)
          _WeekdayRow(
            weekday: weekday,
            hours: hours,
            formats: formats,
            onChanged: (next) =>
                _save(ref, AppSettingsCompanion(workingHours: Value(next.encode()))),
          ),
        _ChoiceRow<int>(
          title: strings.slotLength,
          value: settings.slotMinutes,
          options: _choices(5, 120, step: 5, including: settings.slotMinutes),
          labelOf: strings.minutesShort,
          onPicked: (value) =>
              _save(ref, AppSettingsCompanion(slotMinutes: Value(value))),
        ),
        _ChoiceRow<int>(
          title: strings.turnaroundDays,
          value: settings.defaultTurnaroundDays,
          options: _choices(
            0,
            60,
            including: settings.defaultTurnaroundDays,
          ),
          labelOf: strings.days,
          onPicked: (value) => _save(
            ref,
            AppSettingsCompanion(defaultTurnaroundDays: Value(value)),
          ),
        ),
        SectionHeader(strings.blockedDates, icon: Icons.event_busy_outlined),
        const _BlockedDatesList(),
        SectionHeader(strings.messageTemplates, icon: Icons.chat_outlined),
        ListTile(
          contentPadding: EdgeInsets.zero,
          // The section header already says Templates; the row is worth more
          // saying which ones are in there.
          title: Text(
            [
              strings.whatsappConfirm,
              strings.whatsappReady,
              strings.whatsappReschedule,
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TemplatesScreen()),
          ),
        ),
        SectionHeader(
          strings.language,
          icon: Icons.language,
          // One line rather than a row per language: the section already names
          // itself, so a row saying Language under it would only repeat it.
          trailing: _ChoiceDropdown<String>(
            value: _languageNames.containsKey(settings.languageCode)
                ? settings.languageCode
                // Unknown code from an old backup. The app already falls back
                // to the device language, so say so rather than assert.
                : 'system',
            options: _languageNames.keys.toList(),
            labelOf: (code) => _languageNames[code] ?? strings.systemLanguage,
            onPicked: (code) =>
                _save(ref, AppSettingsCompanion(languageCode: Value(code))),
          ),
        ),
        SectionHeader(strings.exportBackup, icon: Icons.ios_share),
        const _BackupSection(),
      ],
    );
  }

  void _save(WidgetRef ref, AppSettingsCompanion patch) {
    ref.read(databaseProvider).saveSettings(patch).then(
          (_) => ref.read(schedulerProvider).rebuild(),
        );
  }

  Future<void> _pickAgendaTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dailyAgendaMinutes ~/ 60,
        minute: settings.dailyAgendaMinutes % 60,
      ),
    );
    if (picked == null) return;
    _save(
      ref,
      AppSettingsCompanion(
        dailyAgendaMinutes: Value(picked.hour * 60 + picked.minute),
      ),
    );
  }

  Future<void> _editDefaultReminders(
    BuildContext context,
    WidgetRef ref,
    List<ReminderRule> current,
  ) async {
    final next = await showModalBottomSheet<List<ReminderRule>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReminderRuleSheet(initial: current),
    );
    if (next == null) return;
    _save(
      ref,
      AppSettingsCompanion(
        defaultReminderRules: Value(ReminderRule.encodeList(next)),
      ),
    );
  }

  /// `min`..`max` in steps of [step], always containing [including].
  ///
  /// A restored backup can hold a value the steps miss — a dropdown whose
  /// current value is not one of its own options throws, so it is folded in.
  static List<int> _choices(
    int min,
    int max, {
    int step = 1,
    required int including,
  }) {
    final options = {
      for (var value = min; value <= max; value += step) value,
      including,
    }.toList()
      ..sort();
    return options;
  }
}

/// The languages, by their own names, so a picker read in the wrong language is
/// still readable. `system` follows the device.
const Map<String, String?> _languageNames = {
  'system': null,
  'en': 'English',
  'zh': '中文',
  'ms': 'Bahasa Melayu',
  'vi': 'Tiếng Việt',
};

/// A settings row whose value is one of a fixed set.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onPicked,
  });

  final String title;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        trailing: _ChoiceDropdown<T>(
          value: value,
          options: options,
          labelOf: labelOf,
          onPicked: onPicked,
        ),
      );
}

/// The value itself, picked in place: it opens where it sits and shows the
/// choice it is showing now, so the current setting is never a screen away.
class _ChoiceDropdown<T> extends StatelessWidget {
  const _ChoiceDropdown({
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onPicked,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Without [selectedItemBuilder], the closed control is as wide as the
    // longest menu item — "Bahasa Melayu" would pad every language row.
    // Keep the builders as plain Text widgets: an Align expands to the max
    // constraint and then the button's own row overflows by the icon width.
    return DropdownButton<T>(
      value: value,
      // The row is the control; the dropdown is only its value.
      underline: const SizedBox.shrink(),
      isDense: true,
      borderRadius: BorderRadius.circular(12),
      style: theme.textTheme.bodyLarge,
      alignment: AlignmentDirectional.centerEnd,
      selectedItemBuilder: (context) => [
        for (final option in options) Text(labelOf(option)),
      ],
      items: [
        for (final option in options)
          DropdownMenuItem<T>(value: option, child: Text(labelOf(option))),
      ],
      onChanged: (next) {
        if (next != null) onPicked(next);
      },
    );
  }
}

/// Compact OS capability status — icons first, short labels.
class _NotificationStatusCard extends ConsumerWidget {
  const _NotificationStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final capabilities = ref.watch(notificationCapabilitiesProvider).value;
    final pending = ref.watch(pendingNotificationsProvider).value ?? const [];
    final registered = pending.where((p) => p.registered).length;
    final deferred = pending.length - registered;
    final theme = Theme.of(context);
    final notificationsOn = capabilities?.notificationsAllowed ?? true;
    final exactOn = capabilities?.exactAlarmsAllowed ?? true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notificationsOn) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.notifications_off_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(strings.notificationsBlocked),
                trailing: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .requestPermissions();
                    ref.invalidate(notificationCapabilitiesProvider);
                  },
                  child: Text(strings.enableNotifications),
                ),
              ),
              const Divider(height: 16),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                exactOn ? Icons.alarm_on_outlined : Icons.alarm_off_outlined,
              ),
              title: Text(exactOn ? strings.exactAlarmsOn : strings.exactAlarmsOff),
              trailing: exactOn
                  ? null
                  : OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(notificationServiceProvider)
                            .requestExactAlarmPermission();
                        ref.invalidate(notificationCapabilitiesProvider);
                      },
                      child: Text(strings.grantExactAlarms),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(strings.pendingReminders(registered)),
              subtitle: deferred > 0
                  ? Text(strings.deferredReminders(deferred))
                  : null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton.outlined(
                tooltip: strings.batteryExplainerTitle,
                onPressed: () => showBatteryExplainer(context, strings),
                icon: const Icon(Icons.battery_alert_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Doze / OEM battery-optimisation explainer. Shown once automatically on
/// Android, and always available from Settings.
Future<void> showBatteryExplainer(
  BuildContext context,
  AppStrings strings,
) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.batteryExplainerTitle),
        content: SingleChildScrollView(child: Text(strings.batteryExplainerBody)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.gotIt),
          ),
        ],
      ),
    );

class _WeekdayRow extends ConsumerWidget {
  const _WeekdayRow({
    required this.weekday,
    required this.hours,
    required this.formats,
    required this.onChanged,
  });

  final int weekday;
  final WorkingHours hours;
  final Formats formats;
  final ValueChanged<WorkingHours> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final day = hours.forWeekday(weekday);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(formats.weekdayFull(weekday)),
      subtitle: day == null
          ? Text(strings.closed)
          : Text(
              '${formats.minutesAsClock(day.openMinutes)} – '
              '${formats.minutesAsClock(day.closeMinutes)}',
            ),
      trailing: Switch(
        value: day != null,
        onChanged: (open) => onChanged(
          hours.withDay(
            weekday,
            open
                ? const DayHours(openMinutes: 11 * 60, closeMinutes: 22 * 60)
                : null,
          ),
        ),
      ),
      onTap: day == null ? null : () => _editHours(context, strings, day),
    );
  }

  Future<void> _editHours(
    BuildContext context,
    AppStrings strings,
    DayHours day,
  ) async {
    final open = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: day.openMinutes ~/ 60,
        minute: day.openMinutes % 60,
      ),
      helpText: strings.opensAt,
    );
    if (open == null || !context.mounted) return;
    final close = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: day.closeMinutes ~/ 60,
        minute: day.closeMinutes % 60,
      ),
      helpText: strings.closesAt,
    );
    if (close == null) return;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;
    if (closeMinutes <= openMinutes) return;
    onChanged(
      hours.withDay(
        weekday,
        DayHours(openMinutes: openMinutes, closeMinutes: closeMinutes),
      ),
    );
  }
}

class _BlockedDatesList extends ConsumerWidget {
  const _BlockedDatesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final language = ref.watch(languageCodeProvider);
    final formats = Formats(language);
    final blocked = ref.watch(blockedDatesProvider).value ?? const [];

    return Column(
      children: [
        for (final row in blocked)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(
              parseDayKey(row.day) == null
                  ? row.day
                  : formats.fullDate(parseDayKey(row.day)!),
            ),
            subtitle: row.reason == null ? null : Text(row.reason!),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(databaseProvider).unblockDay(row.day),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addBlockedDate(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: Text(strings.add),
          ),
        ),
      ],
    );
  }

  Future<void> _addBlockedDate(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appStringsProvider);
    final now = shopNow();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: shopDateTime(now.year - 1, 1, 1),
      lastDate: shopDateTime(now.year + 3, 12, 31),
    );
    if (picked == null || !context.mounted) return;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.blockReason),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await ref.read(databaseProvider).blockDay(
          dayKey(shopDateTime(picked.year, picked.month, picked.day)),
          reason.trim().isEmpty ? null : reason.trim(),
        );
  }
}

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.ios_share),
          title: Text(strings.exportBackup),
          onTap: () async {
            final service = ref.read(backupServiceProvider);
            final file = await service.writeJsonBackup();
            await service.share(file, subject: 'AnaCoo Tailor backup');
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.table_chart_outlined),
          title: Text(strings.exportCsv),
          onTap: () async {
            final service = ref.read(backupServiceProvider);
            final file = await service.writeJobsCsv();
            await service.share(file, subject: 'AnaCoo Tailor jobs');
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.file_download_outlined),
          title: Text(strings.importBackup),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appStringsProvider);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings.importReplacesWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.importBackup),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    try {
      final json = await File(path).readAsString();
      // Clear the OS's pending list first: the imported rows carry different
      // ids, so anything still armed would be an orphan.
      await ref.read(schedulerProvider).cancelEverything();
      final result = await ref.read(backupServiceProvider).restore(json);
      await ref.read(schedulerProvider).rebuild();
      messenger.showSnackBar(
        SnackBar(content: Text(strings.backupImported(result.jobs, result.customers))),
      );
    } on BackupFormatException {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.backupImportFailed)),
      );
    } on FileSystemException {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.backupImportFailed)),
      );
    }
  }
}
