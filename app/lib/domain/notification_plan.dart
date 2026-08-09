import 'package:timezone/timezone.dart' as tz;

import '../data/enums.dart';
import 'notification_strings.dart';
import 'reminder_rule.dart';
import 'shop_time.dart';

enum NotificationKind { reminder, agenda, overdueCollection, readyNudge }

/// One notification the app intends the OS to show.
///
/// [dedupeKey] is the stable identity: rebuilding the plan produces the same
/// key for the same intent, which is what lets a reschedule cancel exactly the
/// notifications that changed and leave the rest alone.
class PlannedNotification {
  const PlannedNotification({
    required this.dedupeKey,
    required this.kind,
    required this.fireAt,
    required this.title,
    required this.body,
    this.appointmentId,
    this.jobId,
    this.payload,
  });

  final String dedupeKey;
  final NotificationKind kind;
  final tz.TZDateTime fireAt;
  final String title;
  final String body;
  final int? appointmentId;
  final int? jobId;
  final String? payload;

  @override
  String toString() => 'PlannedNotification($dedupeKey @ $fireAt)';
}

/// An appointment reduced to what the planner needs, so the planner stays free
/// of Drift and can be unit tested on its own.
class ScheduleSubject {
  const ScheduleSubject({
    required this.appointmentId,
    required this.jobId,
    required this.type,
    required this.scheduledAtUtc,
    required this.status,
    required this.jobStatus,
    required this.customerName,
    required this.service,
    this.serviceFreeText,
    this.rules,
    this.isRush = false,
  });

  final int appointmentId;
  final int jobId;
  final AppointmentType type;
  final DateTime scheduledAtUtc;
  final AppointmentStatus status;
  final JobStatus jobStatus;
  final String customerName;
  final ServiceType service;
  final String? serviceFreeText;

  /// Per-appointment override; null means "use the Settings defaults".
  final List<ReminderRule>? rules;
  final bool isRush;

  tz.TZDateTime get at => toShop(scheduledAtUtc);

  /// Cancelled jobs and finished appointments carry no reminders.
  bool get isLive => status.isLive && !jobStatus.isClosed;
}

/// A job parked in `ready`, for the pickup nudge.
class ReadySubject {
  const ReadySubject({
    required this.jobId,
    required this.customerName,
    required this.readyAtUtc,
  });

  final int jobId;
  final String customerName;
  final DateTime readyAtUtc;
}

/// Builds the complete set of notifications that *should* exist right now.
///
/// The planner is deterministic and side-effect free: given the same diary and
/// the same `now`, it returns the same plan. Everything that talks to the OS
/// works by diffing against this, which is what keeps orphans impossible.
List<PlannedNotification> planNotifications({
  required tz.TZDateTime now,
  required List<ScheduleSubject> appointments,
  required List<ReadySubject> readyJobs,
  required List<ReminderRule> defaultRules,
  required NotificationStrings strings,
  required int dailyAgendaMinutes,
  bool dailyAgendaEnabled = true,
  bool overdueNudgesEnabled = true,
  int readyNudgeDays = 3,
  int agendaHorizonDays = 14,
}) {
  final planned = <PlannedNotification>[];

  // 1. Per-appointment reminders.
  for (final subject in appointments) {
    if (!subject.isLive) continue;
    final rules = subject.rules ?? defaultRules;
    final at = subject.at;
    for (final rule in rules) {
      final fireAt = rule.resolve(at);
      if (!fireAt.isAfter(now)) continue;
      planned.add(
        PlannedNotification(
          dedupeKey: 'reminder:${subject.appointmentId}:${rule.encode()}',
          kind: NotificationKind.reminder,
          fireAt: fireAt,
          title: strings.reminderTitle(subject.type),
          body: strings.reminderBody(
            customerName: subject.customerName,
            service: subject.service,
            serviceFreeText: subject.serviceFreeText,
            at: at,
            isRush: subject.isRush,
          ),
          appointmentId: subject.appointmentId,
          jobId: subject.jobId,
          payload: 'job:${subject.jobId}',
        ),
      );
    }
  }

  // 2. Daily agenda, only on days that actually have something on them.
  if (dailyAgendaEnabled) {
    final byDay = <String, List<ScheduleSubject>>{};
    for (final subject in appointments) {
      if (!subject.isLive) continue;
      byDay.putIfAbsent(dayKey(subject.at), () => []).add(subject);
    }
    for (var offset = 0; offset <= agendaHorizonDays; offset++) {
      final day = addDays(startOfDay(now), offset);
      final fireAt = day.add(Duration(minutes: dailyAgendaMinutes));
      if (!fireAt.isAfter(now)) continue;
      final onThatDay = byDay[dayKey(day)] ?? const <ScheduleSubject>[];
      if (onThatDay.isEmpty) continue;
      final dropOffs =
          onThatDay.where((s) => s.type == AppointmentType.dropOff).length;
      planned.add(
        PlannedNotification(
          dedupeKey: 'agenda:${dayKey(day)}',
          kind: NotificationKind.agenda,
          fireAt: fireAt,
          title: strings.agendaTitle,
          body: strings.agendaBody(dropOffs, onThatDay.length - dropOffs),
          payload: 'agenda:${dayKey(day)}',
        ),
      );
    }
  }

  // 3. Overdue collections — one nudge per appointment, at the next agenda
  //    time. Rebuilt on every app open, so a still-overdue job gets nudged
  //    again tomorrow without ever queueing a backlog of them.
  if (overdueNudgesEnabled) {
    for (final subject in appointments) {
      if (!subject.isLive) continue;
      if (subject.type != AppointmentType.collection) continue;
      final due = subject.at;
      if (!due.isBefore(now)) continue;
      final fireAt = _nextAgendaTime(now, dailyAgendaMinutes);
      final daysLate = startOfDay(now).difference(startOfDay(due)).inDays;
      planned.add(
        PlannedNotification(
          dedupeKey: 'overdue:${subject.appointmentId}:${dayKey(fireAt)}',
          kind: NotificationKind.overdueCollection,
          fireAt: fireAt,
          title: strings.overdueTitle,
          body: strings.overdueBody(
            customerName: subject.customerName,
            dueAt: due,
            daysLate: daysLate < 1 ? 1 : daysLate,
          ),
          appointmentId: subject.appointmentId,
          jobId: subject.jobId,
          payload: 'job:${subject.jobId}',
        ),
      );
    }
  }

  // 4. Jobs sitting in `ready` for too long.
  for (final job in readyJobs) {
    final readyAt = toShop(job.readyAtUtc);
    final threshold = addDays(startOfDay(readyAt), readyNudgeDays)
        .add(Duration(minutes: dailyAgendaMinutes));
    final fireAt =
        threshold.isAfter(now) ? threshold : _nextAgendaTime(now, dailyAgendaMinutes);
    final days = startOfDay(fireAt).difference(startOfDay(readyAt)).inDays;
    planned.add(
      PlannedNotification(
        dedupeKey: 'readyNudge:${job.jobId}:${dayKey(fireAt)}',
        kind: NotificationKind.readyNudge,
        fireAt: fireAt,
        title: strings.readyNudgeTitle,
        body: strings.readyNudgeBody(
          customerName: job.customerName,
          days: days < 1 ? 1 : days,
        ),
        jobId: job.jobId,
        payload: 'job:${job.jobId}',
      ),
    );
  }

  planned.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned;
}

/// Today's agenda time if it has not passed yet, otherwise tomorrow's.
tz.TZDateTime _nextAgendaTime(tz.TZDateTime now, int dailyAgendaMinutes) {
  final todayAt = startOfDay(now).add(Duration(minutes: dailyAgendaMinutes));
  if (todayAt.isAfter(now)) return todayAt;
  return addDays(startOfDay(now), 1).add(Duration(minutes: dailyAgendaMinutes));
}
