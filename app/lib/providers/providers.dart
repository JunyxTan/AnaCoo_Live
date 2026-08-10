import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../data/enums.dart';
import '../data/job_repository.dart';
import '../domain/message_templates.dart';
import '../domain/reminder_rule.dart';
import '../domain/shop_time.dart';
import '../domain/working_hours.dart';
import '../l10n/app_strings.dart';
import '../services/backup_service.dart';
import '../services/intake_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';
import '../services/whatsapp_launcher.dart';

/// Overridden in `main` once the on-disk database is open.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider must be overridden'),
);

final schedulerProvider = Provider<NotificationScheduler>(
  (ref) => NotificationScheduler(
    db: ref.watch(databaseProvider),
    sink: ref.watch(notificationServiceProvider),
  ),
);

final jobRepositoryProvider = Provider<JobRepository>(
  (ref) => JobRepository(
    db: ref.watch(databaseProvider),
    scheduler: ref.watch(schedulerProvider),
  ),
);

final intakeServiceProvider = Provider<IntakeService>((ref) {
  final service = IntakeService(ref.watch(databaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

final backupServiceProvider =
    Provider<BackupService>((ref) => BackupService(ref.watch(databaseProvider)));

final whatsAppLauncherProvider =
    Provider<WhatsAppLauncher>((ref) => const WhatsAppLauncher());

// ------------------------------------------------------------------ settings

final settingsProvider = StreamProvider<AppSetting>(
  (ref) => ref.watch(databaseProvider).watchSettings(),
);

/// The resolved UI language: the explicit choice, or the device's if it is one
/// of the three the shop speaks, or English.
final languageCodeProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final choice = settings?.languageCode ?? 'system';
  if (choice != 'system' && MessageTemplates.languages.contains(choice)) {
    return choice;
  }
  final device = ui.PlatformDispatcher.instance.locale.languageCode;
  return MessageTemplates.languages.contains(device) ? device : 'en';
});

final appStringsProvider =
    Provider<AppStrings>((ref) => AppStrings(ref.watch(languageCodeProvider)));

final workingHoursProvider = Provider<WorkingHours>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return WorkingHours.decode(settings?.workingHours);
});

final slotMinutesProvider = Provider<int>(
  (ref) => ref.watch(settingsProvider).value?.slotMinutes ?? 30,
);

final turnaroundDaysProvider = Provider<int>(
  (ref) => ref.watch(settingsProvider).value?.defaultTurnaroundDays ?? 3,
);

final defaultReminderRulesProvider = Provider<List<ReminderRule>>((ref) {
  final settings = ref.watch(settingsProvider).value;
  if (settings == null) return ReminderRule.defaults;
  final rules = ReminderRule.decodeList(settings.defaultReminderRules);
  return rules.isEmpty ? ReminderRule.defaults : rules;
});

final templatesProvider = Provider<MessageTemplates>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return MessageTemplates.decode(settings?.templates);
});

// ------------------------------------------------------------- blocked dates

final blockedDatesProvider = StreamProvider<List<BlockedDate>>(
  (ref) => ref.watch(databaseProvider).watchBlockedDates(),
);

final blockedDayKeysProvider = Provider<Set<String>>(
  (ref) =>
      ref.watch(blockedDatesProvider).value?.map((b) => b.day).toSet() ??
      const {},
);

final blockedReasonsProvider = Provider<Map<String, String?>>((ref) {
  final rows = ref.watch(blockedDatesProvider).value ?? const [];
  return {for (final row in rows) row.day: row.reason};
});

// -------------------------------------------------------------- appointments

/// Appointments on a given shop-local day.
final dayAppointmentsProvider =
    StreamProvider.family<List<AppointmentEntry>, String>((ref, day) {
  final start = parseDayKey(day) ?? startOfDay(shopNow());
  return ref
      .watch(databaseProvider)
      .watchAppointmentsBetween(start.toUtc(), endOfDay(start).toUtc());
});

/// Appointments in a month, for the calendar's density dots.
final monthAppointmentsProvider =
    StreamProvider.family<List<AppointmentEntry>, String>((ref, monthKey) {
  final parts = monthKey.split('-');
  final year = int.tryParse(parts.first) ?? shopNow().year;
  final month = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
  final start = shopDateTime(year, month, 1);
  final end = shopDateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);
  return ref
      .watch(databaseProvider)
      .watchAppointmentsBetween(start.toUtc(), end.toUtc());
});

/// Today's date key. Invalidated on resume so a session left open overnight
/// does not keep showing yesterday.
final todayKeyProvider = Provider<String>((ref) => dayKey(shopNow()));

final todayAppointmentsProvider = Provider<AsyncValue<List<AppointmentEntry>>>(
  (ref) => ref.watch(dayAppointmentsProvider(ref.watch(todayKeyProvider))),
);

final overdueAppointmentsProvider = StreamProvider<List<AppointmentEntry>>(
  (ref) => ref.watch(databaseProvider).watchOverdue(DateTime.now().toUtc()),
);

final readyJobsProvider = StreamProvider<List<JobBundle>>(
  (ref) => ref.watch(databaseProvider).watchReadyJobs(),
);

/// Live appointments as clash candidates for the scheduling warnings.
final busySlotsProvider = StreamProvider<List<AppointmentEntry>>(
  (ref) => ref.watch(databaseProvider).watchAllAppointmentEntries(),
);

/// Every appointment across all time — the home list data source.
final allAppointmentsProvider = busySlotsProvider;

// ------------------------------------------------------------------ job view

final jobBundleProvider = StreamProvider.family<JobBundle?, int>(
  (ref, jobId) => ref.watch(databaseProvider).watchJobBundle(jobId),
);

final customersProvider =
    StreamProvider.family<List<Customer>, String>((ref, query) {
  return ref.watch(databaseProvider).watchCustomers(query: query);
});

final customerJobCountsProvider = FutureProvider<Map<int, int>>(
  (ref) => ref.watch(databaseProvider).jobCountsByCustomer(),
);

final customerJobsProvider = StreamProvider.family<List<JobBundle>, int>(
  (ref, customerId) =>
      ref.watch(databaseProvider).watchJobsForCustomer(customerId),
);

// ------------------------------------------------------------- notifications

final notificationCapabilitiesProvider =
    FutureProvider<NotificationCapabilities>(
  (ref) => ref.watch(notificationServiceProvider).capabilities(),
);

final pendingNotificationsProvider = FutureProvider<List<PendingNotification>>(
  (ref) => ref.watch(databaseProvider).allPending(),
);

/// Convenience for widgets that need "now" in shop time without importing the
/// timezone package directly.
tz.TZDateTime nowInShop() => shopNow();

/// Counts for the Today header.
({int dropOffs, int collections}) countByType(List<AppointmentEntry> entries) {
  final dropOffs =
      entries.where((e) => e.appointment.type == AppointmentType.dropOff).length;
  return (dropOffs: dropOffs, collections: entries.length - dropOffs);
}
