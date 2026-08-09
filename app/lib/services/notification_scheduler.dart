import 'package:drift/drift.dart' show Value;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../data/enums.dart';
import '../domain/notification_plan.dart';
import '../domain/notification_strings.dart';
import '../domain/reminder_rule.dart';
import '../domain/shop_time.dart';
import 'notification_service.dart';

/// Result of a rebuild, for the Settings diagnostics panel and for tests.
class SyncReport {
  const SyncReport({
    required this.planned,
    required this.scheduled,
    required this.cancelled,
    required this.deferred,
    required this.usedExactAlarms,
  });

  final int planned;
  final int scheduled;
  final int cancelled;

  /// Planned but held back because the platform's pending limit was reached.
  final int deferred;
  final bool usedExactAlarms;

  @override
  String toString() =>
      'SyncReport(planned: $planned, scheduled: $scheduled, '
      'cancelled: $cancelled, deferred: $deferred)';
}

/// Keeps the OS's pending notifications equal to what `planNotifications` says
/// they should be.
///
/// Every mutation — create, reschedule, cancel, status change — funnels through
/// [rebuild]. It diffs the fresh plan against the app's own ledger by dedupe
/// key, so a rescheduled appointment cancels precisely its old reminders and
/// nothing survives that the plan no longer contains. That is the zero-orphan
/// guarantee, and it holds without ever needing to trust the OS's own list.
class NotificationScheduler {
  NotificationScheduler({required this.db, required this.sink});

  final AppDatabase db;
  final NotificationSink sink;

  Future<SyncReport> rebuild({tz.TZDateTime? now}) async {
    final reference = now ?? shopNow();
    final settings = await db.loadSettings();
    final strings = NotificationStrings(settings.languageCode);

    final entries = await db.allAppointmentEntries();
    final ready = await db.readyJobEntries();

    final plan = planNotifications(
      now: reference,
      appointments: entries
          .map(
            (e) => ScheduleSubject(
              appointmentId: e.appointment.id,
              jobId: e.job.id,
              type: e.appointment.type,
              scheduledAtUtc: e.appointment.scheduledAt,
              status: e.appointment.status,
              jobStatus: e.job.status,
              customerName: e.customer.name,
              service: e.job.service,
              serviceFreeText: e.job.serviceFreeText,
              rules: e.appointment.reminderRules == null
                  ? null
                  : ReminderRule.decodeList(e.appointment.reminderRules),
              isRush: e.job.isRush,
            ),
          )
          .toList(),
      readyJobs: ready
          .where((r) => r.job.readyAt != null)
          .map(
            (r) => ReadySubject(
              jobId: r.job.id,
              customerName: r.customer.name,
              readyAtUtc: r.job.readyAt!,
            ),
          )
          .toList(),
      defaultRules: ReminderRule.decodeList(settings.defaultReminderRules),
      strings: strings,
      dailyAgendaMinutes: settings.dailyAgendaMinutes,
      dailyAgendaEnabled: settings.dailyAgendaEnabled,
      overdueNudgesEnabled: settings.overdueNudgesEnabled,
      readyNudgeDays: settings.readyNudgeDays,
    );

    return _applyPlan(plan);
  }

  Future<SyncReport> _applyPlan(List<PlannedNotification> plan) async {
    final capabilities = await sink.capabilities();
    final planByKey = {for (final p in plan) p.dedupeKey: p};

    var cancelled = 0;
    var scheduled = 0;

    // 1. Drop everything the plan no longer contains. This is the step that
    //    makes a cancellation or a reschedule leave nothing behind.
    for (final row in await db.allPending()) {
      if (planByKey.containsKey(row.dedupeKey)) continue;
      await sink.cancel(row.id);
      await db.deletePending(row.id);
      cancelled++;
    }

    // 2. Insert new entries, and re-arm any whose time or wording moved.
    final existing = {for (final row in await db.allPending()) row.dedupeKey: row};
    for (final planned in plan) {
      final row = existing[planned.dedupeKey];
      final fireAtUtc = planned.fireAt.toUtc();
      if (row == null) {
        await db.insertPending(
          PendingNotificationsCompanion.insert(
            appointmentId: Value(planned.appointmentId),
            jobId: Value(planned.jobId),
            kind: planned.kind.name,
            dedupeKey: planned.dedupeKey,
            fireAt: fireAtUtc,
            title: planned.title,
            body: planned.body,
            payload: Value(planned.payload),
          ),
        );
        continue;
      }
      final changed = !row.fireAt.isAtSameMomentAs(fireAtUtc) ||
          row.title != planned.title ||
          row.body != planned.body;
      if (!changed) continue;
      if (row.registered) {
        await sink.cancel(row.id);
        cancelled++;
      }
      await db.updatePending(
        row.id,
        fireAt: fireAtUtc,
        title: planned.title,
        body: planned.body,
        registered: false,
      );
    }

    // 3. Hand the OS only as many as it will hold, earliest first. iOS caps an
    //    app at 64 pending notifications; the rest stay in the ledger and are
    //    topped up on the next rebuild, which runs on every app open.
    final rows = await db.allPending();
    var deferred = 0;
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final planned = planByKey[row.dedupeKey];
      if (planned == null) continue;
      final withinCap = i < capabilities.maxPending;
      if (withinCap && !row.registered) {
        await sink.schedule(
          id: row.id,
          notification: planned,
          useExactAlarms: capabilities.exactAlarmsAllowed,
        );
        await db.markRegistered(row.id, true);
        scheduled++;
      } else if (!withinCap) {
        if (row.registered) {
          await sink.cancel(row.id);
          await db.markRegistered(row.id, false);
          cancelled++;
        }
        deferred++;
      }
    }

    return SyncReport(
      planned: plan.length,
      scheduled: scheduled,
      cancelled: cancelled,
      deferred: deferred,
      usedExactAlarms: capabilities.exactAlarmsAllowed,
    );
  }

  /// Cancels every notification this app owns and empties the ledger. Used by
  /// the Settings kill switch and before importing a backup.
  Future<void> cancelEverything() async {
    for (final row in await db.allPending()) {
      await sink.cancel(row.id);
    }
    await db.clearPending();
    await sink.cancelAll();
  }

  /// Cancels the reminders for one appointment immediately, without waiting for
  /// a full rebuild. [rebuild] would do the same thing; this exists so a delete
  /// can clean up before the row disappears.
  Future<void> cancelForAppointment(int appointmentId) async {
    for (final row in await db.allPending()) {
      if (row.appointmentId != appointmentId) continue;
      await sink.cancel(row.id);
      await db.deletePending(row.id);
    }
  }

  /// Convenience for the daily-agenda preview in Settings.
  static String agendaPreview(
    List<AppointmentEntry> today,
    NotificationStrings strings,
  ) {
    final dropOffs =
        today.where((e) => e.appointment.type == AppointmentType.dropOff).length;
    if (today.isEmpty) return strings.agendaEmpty;
    return strings.agendaBody(dropOffs, today.length - dropOffs);
  }
}
