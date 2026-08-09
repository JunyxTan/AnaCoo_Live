import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../data/enums.dart';
import '../domain/shop_time.dart';

class ImportResult {
  const ImportResult({required this.jobs, required this.customers});

  final int jobs;
  final int customers;
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Manual JSON backup and CSV export, shared out through the system share
/// sheet. There is no cloud sync by design — this is the whole backup story.
class BackupService {
  const BackupService(this.db);

  final AppDatabase db;

  static const int formatVersion = 1;

  Future<Map<String, Object?>> buildBackup() async {
    final customers = await db.select(db.customers).get();
    final jobs = await db.select(db.jobs).get();
    final appointments = await db.select(db.appointments).get();
    final blocked = await db.allBlockedDates();
    final settings = await db.loadSettings();

    return {
      'format': 'anacoo-tailor-backup',
      'version': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'customers': [
        for (final c in customers)
          {
            'id': c.id,
            'name': c.name,
            'phone': c.phone,
            'whatsappNumber': c.whatsappNumber,
            'notes': c.notes,
            'createdAt': c.createdAt.toUtc().toIso8601String(),
          },
      ],
      'jobs': [
        for (final j in jobs)
          {
            'id': j.id,
            'customerId': j.customerId,
            'service': j.service.name,
            'serviceFreeText': j.serviceFreeText,
            'itemDescription': j.itemDescription,
            'quantity': j.quantity,
            'quotedPrice': j.quotedPrice,
            'depositPaid': j.depositPaid,
            'status': j.status.name,
            'isRush': j.isRush,
            'notes': j.notes,
            'rawMessage': j.rawMessage,
            'createdAt': j.createdAt.toUtc().toIso8601String(),
            'readyAt': j.readyAt?.toUtc().toIso8601String(),
          },
      ],
      'appointments': [
        for (final a in appointments)
          {
            'id': a.id,
            'jobId': a.jobId,
            'type': a.type.name,
            'scheduledAt': a.scheduledAt.toUtc().toIso8601String(),
            'durationMinutes': a.durationMinutes,
            'status': a.status.name,
            'reminderRules': a.reminderRules,
            'notes': a.notes,
          },
      ],
      'blockedDates': [
        for (final b in blocked) {'day': b.day, 'reason': b.reason},
      ],
      'settings': {
        'defaultReminderRules': settings.defaultReminderRules,
        'workingHours': settings.workingHours,
        'slotMinutes': settings.slotMinutes,
        'defaultTurnaroundDays': settings.defaultTurnaroundDays,
        'dailyAgendaMinutes': settings.dailyAgendaMinutes,
        'dailyAgendaEnabled': settings.dailyAgendaEnabled,
        'languageCode': settings.languageCode,
        'readyNudgeDays': settings.readyNudgeDays,
        'overdueNudgesEnabled': settings.overdueNudgesEnabled,
        'templates': settings.templates,
      },
    };
  }

  Future<File> writeJsonBackup() async {
    final backup = await buildBackup();
    final dir = await getTemporaryDirectory();
    final stamp = dayKey(shopNow());
    final file = File(p.join(dir.path, 'anacoo-backup-$stamp.json'));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(backup),
      flush: true,
    );
    return file;
  }

  Future<File> writeJobsCsv() async {
    final csv = await buildJobsCsv();
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'anacoo-jobs-${dayKey(shopNow())}.csv'));
    await file.writeAsString(csv, flush: true);
    return file;
  }

  /// One row per job, with both appointment times in shop time.
  Future<String> buildJobsCsv() async {
    final rows = await db.allAppointmentEntries();
    final byJob = <int, List<AppointmentEntry>>{};
    for (final entry in rows) {
      byJob.putIfAbsent(entry.job.id, () => []).add(entry);
    }

    final buffer = StringBuffer()
      ..writeln(
        'job_id,customer,phone,service,item,quantity,quoted_price,deposit,'
        'status,rush,drop_off,collection,notes',
      );
    for (final entries in byJob.values) {
      final job = entries.first.job;
      final customer = entries.first.customer;
      final dropOff = entries
          .where((e) => e.appointment.type == AppointmentType.dropOff)
          .firstOrNull;
      final collection = entries
          .where((e) => e.appointment.type == AppointmentType.collection)
          .firstOrNull;
      buffer.writeln([
        job.id,
        customer.name,
        customer.phone ?? '',
        job.service.name,
        job.itemDescription ?? '',
        job.quantity,
        job.quotedPrice?.toStringAsFixed(2) ?? '',
        job.depositPaid?.toStringAsFixed(2) ?? '',
        job.status.name,
        job.isRush ? 'yes' : 'no',
        dropOff == null ? '' : toShop(dropOff.appointment.scheduledAt).toString(),
        collection == null
            ? ''
            : toShop(collection.appointment.scheduledAt).toString(),
        job.notes ?? '',
      ].map(_csvCell).join(','));
    }
    return buffer.toString();
  }

  static String _csvCell(Object? value) {
    final text = value?.toString() ?? '';
    if (!text.contains(RegExp('[",\n]'))) return text;
    return '"${text.replaceAll('"', '""')}"';
  }

  Future<void> share(File file, {required String subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  /// Replaces the entire database with the contents of [json].
  ///
  /// Destructive on purpose — a backup is a snapshot, and merging two diverged
  /// snapshots without a sync protocol would silently duplicate jobs. The UI
  /// asks for confirmation before calling this.
  Future<ImportResult> restore(String json) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (e) {
      throw BackupFormatException('Not valid JSON: ${e.message}');
    }
    if (decoded is! Map || decoded['format'] != 'anacoo-tailor-backup') {
      throw const BackupFormatException('Not an AnaCoo Tailor backup file.');
    }

    final customers = _list(decoded['customers']);
    final jobs = _list(decoded['jobs']);
    final appointments = _list(decoded['appointments']);
    final blocked = _list(decoded['blockedDates']);
    final settings = decoded['settings'];

    await db.transaction(() async {
      await db.delete(db.appointments).go();
      await db.delete(db.jobs).go();
      await db.delete(db.customers).go();
      await db.delete(db.blockedDates).go();
      await db.clearPending();

      for (final raw in customers) {
        await db.into(db.customers).insert(
              CustomersCompanion.insert(
                id: Value(_int(raw['id'])),
                name: _string(raw['name']) ?? 'Unnamed',
                phone: Value(_string(raw['phone'])),
                whatsappNumber: Value(_string(raw['whatsappNumber'])),
                notes: Value(_string(raw['notes'])),
                createdAt: _date(raw['createdAt']) ?? DateTime.now().toUtc(),
              ),
            );
      }
      for (final raw in jobs) {
        await db.into(db.jobs).insert(
              JobsCompanion.insert(
                id: Value(_int(raw['id'])),
                customerId: _int(raw['customerId']),
                service: _enum(ServiceType.values, raw['service']) ??
                    ServiceType.other,
                serviceFreeText: Value(_string(raw['serviceFreeText'])),
                itemDescription: Value(_string(raw['itemDescription'])),
                quantity: Value(_int(raw['quantity'], fallback: 1)),
                quotedPrice: Value(_double(raw['quotedPrice'])),
                depositPaid: Value(_double(raw['depositPaid'])),
                status: _enum(JobStatus.values, raw['status']) ??
                    JobStatus.requested,
                isRush: Value(raw['isRush'] == true),
                notes: Value(_string(raw['notes'])),
                rawMessage: Value(_string(raw['rawMessage'])),
                createdAt: _date(raw['createdAt']) ?? DateTime.now().toUtc(),
                readyAt: Value(_date(raw['readyAt'])),
              ),
            );
      }
      for (final raw in appointments) {
        final at = _date(raw['scheduledAt']);
        if (at == null) continue;
        await db.into(db.appointments).insert(
              AppointmentsCompanion.insert(
                id: Value(_int(raw['id'])),
                jobId: _int(raw['jobId']),
                type: _enum(AppointmentType.values, raw['type']) ??
                    AppointmentType.dropOff,
                scheduledAt: at,
                durationMinutes: Value(_int(raw['durationMinutes'], fallback: 15)),
                status: _enum(AppointmentStatus.values, raw['status']) ??
                    AppointmentStatus.pending,
                reminderRules: Value(_string(raw['reminderRules'])),
                notes: Value(_string(raw['notes'])),
              ),
            );
      }
      for (final raw in blocked) {
        final day = _string(raw['day']);
        if (day == null) continue;
        await db.blockDay(day, _string(raw['reason']));
      }
      if (settings is Map) {
        await db.saveSettings(
          AppSettingsCompanion(
            defaultReminderRules: _valueOf(_string(settings['defaultReminderRules'])),
            workingHours: _valueOf(_string(settings['workingHours'])),
            slotMinutes: _valueOfInt(settings['slotMinutes']),
            defaultTurnaroundDays: _valueOfInt(settings['defaultTurnaroundDays']),
            dailyAgendaMinutes: _valueOfInt(settings['dailyAgendaMinutes']),
            dailyAgendaEnabled: settings['dailyAgendaEnabled'] is bool
                ? Value(settings['dailyAgendaEnabled']! as bool)
                : const Value.absent(),
            languageCode: _valueOf(_string(settings['languageCode'])),
            readyNudgeDays: _valueOfInt(settings['readyNudgeDays']),
            overdueNudgesEnabled: settings['overdueNudgesEnabled'] is bool
                ? Value(settings['overdueNudgesEnabled']! as bool)
                : const Value.absent(),
            templates: _valueOf(_string(settings['templates'])),
          ),
        );
      }
    });

    return ImportResult(jobs: jobs.length, customers: customers.length);
  }

  static List<Map<String, Object?>> _list(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => e.cast<String, Object?>()).toList();
  }

  static String? _string(Object? raw) {
    if (raw is! String) return null;
    return raw.isEmpty ? null : raw;
  }

  static int _int(Object? raw, {int fallback = 0}) =>
      raw is int ? raw : (raw is num ? raw.toInt() : fallback);

  static double? _double(Object? raw) => raw is num ? raw.toDouble() : null;

  static DateTime? _date(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static T? _enum<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  static Value<String> _valueOf(String? raw) =>
      raw == null ? const Value.absent() : Value(raw);

  static Value<int> _valueOfInt(Object? raw) =>
      raw is num ? Value(raw.toInt()) : const Value.absent();
}
