import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/message_templates.dart';
import 'package:anacoo_tailor/domain/workflow_automation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statusAfterWhatsAppAction', () {
    test('confirm advances requested to confirmed', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.requested, TemplateKind.confirm),
        JobStatus.confirmed,
      );
    });

    test('confirm does not rewind a later status', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.inProgress, TemplateKind.confirm),
        isNull,
      );
    });

    test('ready advances earlier statuses to ready', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.confirmed, TemplateKind.ready),
        JobStatus.ready,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.inProgress, TemplateKind.ready),
        JobStatus.ready,
      );
    });

    test('ready is a no-op when already ready or closed', () {
      expect(
        statusAfterWhatsAppAction(JobStatus.ready, TemplateKind.ready),
        isNull,
      );
      expect(
        statusAfterWhatsAppAction(JobStatus.collected, TemplateKind.ready),
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

  group('shouldPromptForCollection', () {
    test('only when ready and collection is missing', () {
      expect(
        shouldPromptForCollection(
          status: JobStatus.ready,
          collectionSet: false,
        ),
        isTrue,
      );
      expect(
        shouldPromptForCollection(
          status: JobStatus.ready,
          collectionSet: true,
        ),
        isFalse,
      );
      expect(
        shouldPromptForCollection(
          status: JobStatus.inProgress,
          collectionSet: false,
        ),
        isFalse,
      );
    });
  });
}
