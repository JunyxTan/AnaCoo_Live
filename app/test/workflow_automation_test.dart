import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/message_templates.dart';
import 'package:anacoo_tailor/domain/workflow_automation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statusAfterWhatsAppAction', () {
    test('confirm no longer advances the pipeline', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.booked, TemplateKind.confirm),
        isNull,
      );
    });

    test('ready advances earlier statuses to ready', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.booked, TemplateKind.ready),
        JobStatus.ready,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.received, TemplateKind.ready),
        JobStatus.ready,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.sewing, TemplateKind.ready),
        JobStatus.ready,
      );
    });

    test('ready is a no-op when already ready or closed', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.ready, TemplateKind.ready),
        isNull,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.done, TemplateKind.ready),
        isNull,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.cancelled, TemplateKind.confirm),
        isNull,
      );
    });

    test('reschedule never changes status', () {
      for (final status in JobStatus.values) {
        expect(
          statusAfterWhatsAppAction(status, TemplateKind.reschedule),
          isNull,
        );
      }
    });
  });

  group('nextStatusFor', () {
    test('walks the five-step pipeline', () {
      expect(nextStatusFor(JobStatus.booked), JobStatus.received);
      expect(nextStatusFor(JobStatus.received), JobStatus.sewing);
      expect(nextStatusFor(JobStatus.sewing), JobStatus.ready);
      expect(nextStatusFor(JobStatus.ready), JobStatus.done);
      expect(nextStatusFor(JobStatus.done), isNull);
      expect(nextStatusFor(JobStatus.cancelled), isNull);
    });
  });

  group('jobStatusFromStorage', () {
    test('remaps legacy names', () {
      expect(jobStatusFromStorage('requested'), JobStatus.booked);
      expect(jobStatusFromStorage('confirmed'), JobStatus.booked);
      // The v1 pipeline had this step too, and it meant the same thing.
      expect(jobStatusFromStorage('received'), JobStatus.received);
      expect(jobStatusFromStorage('inProgress'), JobStatus.sewing);
      expect(jobStatusFromStorage('collected'), JobStatus.done);
      expect(jobStatusFromStorage('done'), JobStatus.done);
    });
  });
}
