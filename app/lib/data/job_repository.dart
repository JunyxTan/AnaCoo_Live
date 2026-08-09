import 'package:drift/drift.dart' show Value;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_rule.dart';
import '../domain/shop_time.dart';
import '../services/notification_scheduler.dart';
import 'database.dart';
import 'enums.dart';

/// One appointment as the form holds it, before it becomes a database row.
class AppointmentDraft {
  AppointmentDraft({
    required this.at,
    this.durationMinutes = 15,
    this.status = AppointmentStatus.pending,
    this.rules,
    this.notes,
  });

  tz.TZDateTime at;
  int durationMinutes;
  AppointmentStatus status;

  /// Null means "use the Settings defaults".
  List<ReminderRule>? rules;
  String? notes;

  AppointmentDraft copy() => AppointmentDraft(
        at: at,
        durationMinutes: durationMinutes,
        status: status,
        rules: rules == null ? null : List.of(rules!),
        notes: notes,
      );

  static AppointmentDraft fromRow(Appointment row) => AppointmentDraft(
        at: toShop(row.scheduledAt),
        durationMinutes: row.durationMinutes,
        status: row.status,
        rules: row.reminderRules == null
            ? null
            : ReminderRule.decodeList(row.reminderRules),
        notes: row.notes,
      );
}

/// Everything the New/Edit Job form collects.
class JobDraft {
  JobDraft({
    this.jobId,
    this.customerId,
    this.customerName = '',
    this.phone,
    this.whatsappNumber,
    this.service,
    this.serviceFreeText,
    this.itemDescription,
    this.quantity = 1,
    this.quotedPrice,
    this.depositPaid,
    this.status = JobStatus.requested,
    this.isRush = false,
    this.notes,
    this.rawMessage,
    required this.dropOff,
    this.collection,
  });

  int? jobId;
  int? customerId;
  String customerName;
  String? phone;
  String? whatsappNumber;

  /// Null when the parser could not match a service — the field stays empty
  /// rather than being filled with a guess.
  ServiceType? service;
  String? serviceFreeText;
  String? itemDescription;
  int quantity;
  double? quotedPrice;
  double? depositPaid;
  JobStatus status;
  bool isRush;
  String? notes;
  String? rawMessage;

  AppointmentDraft dropOff;

  /// Null while the collection date is still unknown — the normal case at
  /// drop-off, and always skippable.
  AppointmentDraft? collection;

  /// A job must be attached to someone identifiable.
  bool get hasIdentifiableCustomer =>
      customerId != null ||
      customerName.trim().isNotEmpty ||
      (phone?.trim().isNotEmpty ?? false);

  bool get isNew => jobId == null;
}

/// Writes jobs, keeps the two appointments in step, and re-plans notifications
/// after every change.
///
/// Every mutation ends with a scheduler rebuild. That is what makes the
/// zero-orphan promise hold in the app rather than only in tests: there is no
/// path that edits a time without the reminders following it.
class JobRepository {
  const JobRepository({required this.db, required this.scheduler});

  final AppDatabase db;
  final NotificationScheduler scheduler;

  Future<int> save(JobDraft draft) async {
    final now = DateTime.now().toUtc();

    final customerId = await _resolveCustomer(draft, now);

    final companion = JobsCompanion(
      customerId: Value(customerId),
      service: Value(draft.service ?? ServiceType.other),
      serviceFreeText: Value(draft.serviceFreeText),
      itemDescription: Value(draft.itemDescription),
      quantity: Value(draft.quantity),
      quotedPrice: Value(draft.quotedPrice),
      depositPaid: Value(draft.depositPaid),
      status: Value(draft.status),
      isRush: Value(draft.isRush),
      notes: Value(draft.notes),
      rawMessage: Value(draft.rawMessage),
      readyAt: draft.status == JobStatus.ready
          ? Value(now)
          : const Value(null),
    );

    final int jobId;
    if (draft.jobId == null) {
      jobId = await db.insertJob(
        companion.copyWith(createdAt: Value(now)),
      );
    } else {
      jobId = draft.jobId!;
      // Keep the original readyAt if the job was already ready.
      final existing = await db.getJob(jobId);
      await db.updateJob(
        jobId,
        companion.copyWith(
          readyAt: draft.status == JobStatus.ready
              ? Value(existing.readyAt ?? now)
              : const Value(null),
        ),
      );
    }

    await db.upsertAppointment(
      _appointmentCompanion(jobId, AppointmentType.dropOff, draft.dropOff),
    );

    final collection = draft.collection;
    if (collection == null) {
      final existing = await db.appointmentOf(jobId, AppointmentType.collection);
      if (existing != null) {
        await scheduler.cancelForAppointment(existing.id);
        await db.deleteAppointment(existing.id);
      }
    } else {
      await db.upsertAppointment(
        _appointmentCompanion(jobId, AppointmentType.collection, collection),
      );
    }

    await scheduler.rebuild();
    return jobId;
  }

  Future<int> _resolveCustomer(JobDraft draft, DateTime now) async {
    final name = draft.customerName.trim();
    final companion = CustomersCompanion(
      id: draft.customerId == null ? const Value.absent() : Value(draft.customerId!),
      name: Value(name.isEmpty ? (draft.phone?.trim() ?? '—') : name),
      phone: Value(draft.phone?.trim().isEmpty ?? true ? null : draft.phone!.trim()),
      whatsappNumber: Value(
        draft.whatsappNumber?.trim().isEmpty ?? true
            ? null
            : draft.whatsappNumber!.trim(),
      ),
      createdAt: draft.customerId == null ? Value(now) : const Value.absent(),
    );
    return db.upsertCustomer(companion);
  }

  AppointmentsCompanion _appointmentCompanion(
    int jobId,
    AppointmentType type,
    AppointmentDraft draft,
  ) =>
      AppointmentsCompanion.insert(
        jobId: jobId,
        type: type,
        scheduledAt: draft.at.toUtc(),
        durationMinutes: Value(draft.durationMinutes),
        status: draft.status,
        reminderRules: Value(
          draft.rules == null ? null : ReminderRule.encodeList(draft.rules!),
        ),
        notes: Value(draft.notes),
      );

  Future<void> setStatus(int jobId, JobStatus status) async {
    await db.setJobStatus(jobId, status);
    // Collecting the garment closes both appointments off.
    if (status == JobStatus.collected) {
      for (final type in AppointmentType.values) {
        final appointment = await db.appointmentOf(jobId, type);
        if (appointment == null || !appointment.status.isLive) continue;
        await db.upsertAppointment(
          AppointmentsCompanion.insert(
            jobId: jobId,
            type: type,
            scheduledAt: appointment.scheduledAt,
            durationMinutes: Value(appointment.durationMinutes),
            status: AppointmentStatus.done,
            reminderRules: Value(appointment.reminderRules),
            notes: Value(appointment.notes),
          ),
        );
      }
    }
    await scheduler.rebuild();
  }

  Future<void> setAppointmentStatus(
    int jobId,
    AppointmentType type,
    AppointmentStatus status,
  ) async {
    final appointment = await db.appointmentOf(jobId, type);
    if (appointment == null) return;
    await db.upsertAppointment(
      AppointmentsCompanion.insert(
        jobId: jobId,
        type: type,
        scheduledAt: appointment.scheduledAt,
        durationMinutes: Value(appointment.durationMinutes),
        status: status,
        reminderRules: Value(appointment.reminderRules),
        notes: Value(appointment.notes),
      ),
    );
    await scheduler.rebuild();
  }

  /// Confirms a still-pending drop-off — used when the tailor sends the
  /// WhatsApp confirm template so the appointment chip stays in step.
  Future<void> confirmDropOffIfPending(int jobId) async {
    final appointment = await db.appointmentOf(jobId, AppointmentType.dropOff);
    if (appointment == null) return;
    if (appointment.status != AppointmentStatus.pending) return;
    await setAppointmentStatus(
      jobId,
      AppointmentType.dropOff,
      AppointmentStatus.confirmed,
    );
  }

  /// Sets (or replaces) the collection appointment without rewriting the job.
  Future<void> scheduleCollection(int jobId, AppointmentDraft draft) async {
    await db.upsertAppointment(
      _appointmentCompanion(jobId, AppointmentType.collection, draft),
    );
    await scheduler.rebuild();
  }

  Future<void> deleteJob(int jobId) async {
    for (final type in AppointmentType.values) {
      final appointment = await db.appointmentOf(jobId, type);
      if (appointment != null) {
        await scheduler.cancelForAppointment(appointment.id);
      }
    }
    await db.deleteJob(jobId);
    await scheduler.rebuild();
  }
}
