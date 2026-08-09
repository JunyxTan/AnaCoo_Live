import '../data/enums.dart';
import 'message_templates.dart';

/// Status the job should move to after the tailor sends a WhatsApp template.
JobStatus? statusAfterWhatsAppAction(JobStatus current, TemplateKind kind) {
  if (current.isClosed) return null;
  return switch (kind) {
    // Confirm keeps the job booked — messaging the customer is not a pipeline
    // step anymore. Ready still jumps ahead to ready.
    TemplateKind.ready when current.step < JobStatus.ready.step =>
      JobStatus.ready,
    TemplateKind.confirm ||
    TemplateKind.ready ||
    TemplateKind.reschedule =>
      null,
  };
}

/// Label key for the single primary action on a Today tile.
enum TodayAction {
  next,
  none,
}

/// The one button on a tile: advance to the next pipeline status.
JobStatus? nextStatusFor(JobStatus current) => current.next;
