import 'dart:convert';
import 'dart:io';

import 'package:anacoo_tailor/data/database.dart';
import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/data/job_repository.dart';
import 'package:anacoo_tailor/domain/notification_plan.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/services/backup_service.dart';
import 'package:anacoo_tailor/services/cloth_photo_store.dart';
import 'package:anacoo_tailor/services/notification_scheduler.dart';
import 'package:anacoo_tailor/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _SilentSink implements NotificationSink {
  @override
  Future<NotificationCapabilities> capabilities() async =>
      const NotificationCapabilities(
        notificationsAllowed: true,
        exactAlarmsAllowed: true,
        maxPending: 64,
      );

  @override
  Future<void> schedule({
    required int id,
    required PlannedNotification notification,
    required bool useExactAlarms,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  initShopTime();

  late AppDatabase db;
  late JobRepository repository;

  setUp(() async {
    db = AppDatabase.memory();
    await db.loadSettings();
    repository = JobRepository(
      db: db,
      scheduler: NotificationScheduler(db: db, sink: _SilentSink()),
      photos: ClothPhotoStore(root: Directory.systemTemp.createTempSync('photos')),
    );
  });

  tearDown(() async => db.close());

  JobDraft draft() => JobDraft(
        customerName: 'Siti',
        phone: '0123608968',
        service: ServiceType.pantsJeansShortening,
        itemDescription: 'Blue jeans',
        dropOff: AppointmentDraft(at: shopDateTime(2026, 8, 6, 12, 0)),
      );

  group('saving', () {
    test('creates the customer, the job and the drop-off in one go', () async {
      final jobId = await repository.save(draft());

      final job = await db.getJob(jobId);
      final customer = await db.getCustomer(job.customerId);
      final dropOff = await db.appointmentOf(jobId, AppointmentType.dropOff);

      expect(customer.name, 'Siti');
      expect(job.service, ServiceType.pantsJeansShortening);
      expect(dropOff, isNotNull);
      expect(toShop(dropOff!.scheduledAt), shopDateTime(2026, 8, 6, 12, 0));
      // A collection that was never set stays unset.
      expect(await db.appointmentOf(jobId, AppointmentType.collection), isNull);
    });

    test('a job never ends up with two drop-offs', () async {
      final jobId = await repository.save(draft());
      final edit = draft()
        ..jobId = jobId
        ..dropOff = AppointmentDraft(at: shopDateTime(2026, 8, 7, 15, 0));
      await repository.save(edit);

      final all = await db.select(db.appointments).get();
      expect(all.where((a) => a.jobId == jobId).length, 1);
      expect(
        toShop(all.single.scheduledAt),
        shopDateTime(2026, 8, 7, 15, 0),
      );
    });

    test('clearing the collection removes its row', () async {
      final withCollection = draft()
        ..collection = AppointmentDraft(at: shopDateTime(2026, 8, 9, 15, 0));
      final jobId = await repository.save(withCollection);
      expect(
        await db.appointmentOf(jobId, AppointmentType.collection),
        isNotNull,
      );

      await repository.save(draft()..jobId = jobId);

      expect(await db.appointmentOf(jobId, AppointmentType.collection), isNull);
    });

    test('an unmatched service is stored as other with the raw wording kept',
        () async {
      final jobId = await repository.save(
        draft()
          ..service = null
          ..serviceFreeText = 'wedding gown beading',
      );
      final job = await db.getJob(jobId);

      expect(job.service, ServiceType.other);
      expect(job.serviceFreeText, 'wedding gown beading');
    });
  });

  group('status', () {
    test('entering ready stamps readyAt, leaving it clears it', () async {
      final jobId = await repository.save(draft());

      await repository.setStatus(jobId, JobStatus.ready);
      expect((await db.getJob(jobId)).readyAt, isNotNull);

      await repository.setStatus(jobId, JobStatus.sewing);
      expect((await db.getJob(jobId)).readyAt, isNull);
    });

    test('received closes the drop-off, and so does skipping past it', () async {
      final jobId = await repository.save(draft());

      await repository.setStatus(jobId, JobStatus.received);
      expect(
        (await db.appointmentOf(jobId, AppointmentType.dropOff))!.status,
        AppointmentStatus.done,
      );

      final skipped = await repository.save(draft());
      await repository.setStatus(skipped, JobStatus.ready);
      expect(
        (await db.appointmentOf(skipped, AppointmentType.dropOff))!.status,
        AppointmentStatus.done,
      );
    });

    test('done closes both appointments', () async {
      final jobId = await repository.save(
        draft()..collection = AppointmentDraft(at: shopDateTime(2026, 8, 9, 15, 0)),
      );

      await repository.setStatus(jobId, JobStatus.done);

      for (final type in AppointmentType.values) {
        final appointment = await db.appointmentOf(jobId, type);
        expect(appointment!.status, AppointmentStatus.done, reason: type.name);
      }
    });

    test('an edit does not reset readyAt on an already-ready job', () async {
      final jobId = await repository.save(draft());
      await repository.setStatus(jobId, JobStatus.ready);
      final stamped = (await db.getJob(jobId)).readyAt;

      await repository.save(
        draft()
          ..jobId = jobId
          ..status = JobStatus.ready
          ..itemDescription = 'Black jeans',
      );

      expect((await db.getJob(jobId)).readyAt, stamped);
    });
  });

  group('deleting', () {
    test('takes both appointments with it', () async {
      final jobId = await repository.save(
        draft()..collection = AppointmentDraft(at: shopDateTime(2026, 8, 9, 15, 0)),
      );

      await repository.deleteJob(jobId);

      expect(await db.select(db.appointments).get(), isEmpty);
      expect(await db.select(db.jobs).get(), isEmpty);
      // The customer survives — their history should outlive one job.
      expect(await db.select(db.customers).get(), hasLength(1));
    });
  });

  group('operational helpers', () {
    test('confirmDropOffIfPending only moves pending → confirmed', () async {
      final jobId = await repository.save(draft());
      final before = await db.appointmentOf(jobId, AppointmentType.dropOff);
      expect(before!.status, AppointmentStatus.pending);

      await repository.confirmDropOffIfPending(jobId);
      expect(
        (await db.appointmentOf(jobId, AppointmentType.dropOff))!.status,
        AppointmentStatus.confirmed,
      );

      await repository.setAppointmentStatus(
        jobId,
        AppointmentType.dropOff,
        AppointmentStatus.done,
      );
      await repository.confirmDropOffIfPending(jobId);
      expect(
        (await db.appointmentOf(jobId, AppointmentType.dropOff))!.status,
        AppointmentStatus.done,
      );
    });

    test(
        'advance walks booked → received → sewing → ready → done without auto '
        'collection', () async {
      final jobId = await repository.save(draft());

      expect(await repository.advance(jobId), JobStatus.received);
      expect((await db.getJob(jobId)).status, JobStatus.received);

      expect(await repository.advance(jobId), JobStatus.sewing);
      expect((await db.getJob(jobId)).status, JobStatus.sewing);

      expect(await repository.advance(jobId), JobStatus.ready);
      expect((await db.getJob(jobId)).status, JobStatus.ready);
      expect(await db.appointmentOf(jobId, AppointmentType.collection), isNull);

      expect(await repository.advance(jobId), JobStatus.done);
      expect((await db.getJob(jobId)).status, JobStatus.done);
      expect(await repository.advance(jobId), isNull);
    });
  });

  group('archiving a customer', () {
    test('takes the name out of the directory and puts it back', () async {
      final jobId = await repository.save(draft());
      final customerId = (await db.getJob(jobId)).customerId;

      expect(await db.watchCustomers().first, hasLength(1));
      expect(await db.watchCustomers(archived: true).first, isEmpty);

      await db.setCustomerArchived(customerId, true);
      expect(await db.watchCustomers().first, isEmpty);
      expect(
        (await db.watchCustomers(archived: true).first).single.name,
        'Siti',
      );

      await db.setCustomerArchived(customerId, false);
      expect((await db.watchCustomers().first).single.name, 'Siti');
      expect(await db.watchCustomers(archived: true).first, isEmpty);
      expect((await db.getCustomer(customerId)).archivedAt, isNull);
    });

    test('leaves their work alone — the shop still has the clothes', () async {
      final jobId = await repository.save(draft());
      final customerId = (await db.getJob(jobId)).customerId;

      await db.setCustomerArchived(customerId, true);

      expect(await db.getJob(jobId), isNotNull);
      expect(await db.appointmentOf(jobId, AppointmentType.dropOff), isNotNull);
      expect(await db.allAppointmentEntries(), hasLength(1));
    });

    test('still matches a search of the archive', () async {
      final jobId = await repository.save(draft());
      await db.setCustomerArchived((await db.getJob(jobId)).customerId, true);

      expect(
        await db.watchCustomers(query: 'sit', archived: true).first,
        hasLength(1),
      );
      expect(
        await db.watchCustomers(query: 'nobody', archived: true).first,
        isEmpty,
      );
    });
  });

  group('backup', () {
    test('round trips a full database', () async {
      final jobId = await repository.save(
        draft()
          ..quotedPrice = 25
          ..isRush = true
          ..rawMessage = 'original whatsapp text'
          ..collection = AppointmentDraft(at: shopDateTime(2026, 8, 9, 15, 0)),
      );
      await db.blockDay('2026-12-25', 'Christmas');

      final service = BackupService(db);
      final json = await service.buildBackup();
      final encoded = jsonEncode(json);

      final fresh = AppDatabase.memory();
      addTearDown(fresh.close);
      final result = await BackupService(fresh).restore(encoded);

      expect(result.jobs, 1);
      expect(result.customers, 1);
      final restored = await fresh.getJob(jobId);
      expect(restored.quotedPrice, 25);
      expect(restored.isRush, isTrue);
      expect(restored.rawMessage, 'original whatsapp text');
      expect(
        toShop((await fresh.appointmentOf(jobId, AppointmentType.collection))!
            .scheduledAt),
        shopDateTime(2026, 8, 9, 15, 0),
      );
      expect((await fresh.allBlockedDates()).single.reason, 'Christmas');
    });

    test('remembers which customers were archived', () async {
      final jobId = await repository.save(draft());
      await db.setCustomerArchived((await db.getJob(jobId)).customerId, true);

      final encoded = jsonEncode(await BackupService(db).buildBackup());
      final fresh = AppDatabase.memory();
      addTearDown(fresh.close);
      await BackupService(fresh).restore(encoded);

      expect(await fresh.watchCustomers().first, isEmpty);
      expect(await fresh.watchCustomers(archived: true).first, hasLength(1));
    });

    test('rejects a file that is not an AnaCoo backup', () async {
      final fresh = AppDatabase.memory();
      addTearDown(fresh.close);
      final service = BackupService(fresh);

      expect(
        () => service.restore('{"format":"something-else"}'),
        throwsA(isA<BackupFormatException>()),
      );
      expect(
        () => service.restore('not json at all'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('CSV export has a header and one row per job', () async {
      await repository.save(draft());
      final lines = (await BackupService(db).buildJobsCsv()).trim().split('\n');

      expect(lines.first, startsWith('job_id,customer,phone,service'));
      expect(lines, hasLength(2));
      expect(lines[1], contains('Siti'));
    });
  });

  group('cloth photos', () {
    test('saves and deletes a photo file for a job', () async {
      final jobId = await repository.save(draft());
      final source = File(
        '${Directory.systemTemp.createTempSync('src').path}/cloth.jpg',
      )..writeAsBytesSync(List<int>.filled(64, 7));

      final photo = await repository.addClothPhoto(jobId, source);
      final stored = await repository.photos.absoluteFile(photo.relativePath);

      expect(await db.photosForJob(jobId), hasLength(1));
      expect(await stored.exists(), isTrue);

      await repository.deleteClothPhoto(photo);
      expect(await db.photosForJob(jobId), isEmpty);
      expect(await stored.exists(), isFalse);
    });

    test('deleting a job removes its photo files', () async {
      final jobId = await repository.save(draft());
      final source = File(
        '${Directory.systemTemp.createTempSync('src').path}/cloth.jpg',
      )..writeAsBytesSync(List<int>.filled(32, 3));
      final photo = await repository.addClothPhoto(jobId, source);
      final stored = await repository.photos.absoluteFile(photo.relativePath);

      await repository.deleteJob(jobId);

      expect(await db.photosForJob(jobId), isEmpty);
      expect(await stored.exists(), isFalse);
    });
  });
}
