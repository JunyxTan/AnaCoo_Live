import '../data/enums.dart';
import 'message_templates.dart';

/// Status the job should move to after the tailor sends a WhatsApp template.
///
/// Only advances along the happy path — never rewinds, and never touches a
/// closed job. Reschedule leaves status alone; the tailor picks a new time in
/// the editor.
JobStatus? statusAfterWhatsAppAction(JobStatus current, TemplateKind kind) {
  if (current.isClosed) return null;
  return switch (kind) {
    TemplateKind.confirm
        when current.step < JobStatus.confirmed.step =>
      JobStatus.confirmed,
    TemplateKind.ready when current.step < JobStatus.ready.step =>
      JobStatus.ready,
    TemplateKind.confirm ||
    TemplateKind.ready ||
    TemplateKind.reschedule =>
      null,
  };
}

/// Whether marking a job [ready] should prompt for a still-missing collection.
bool shouldPromptForCollection({
  required JobStatus status,
  required bool collectionSet,
}) =>
    status == JobStatus.ready && !collectionSet;
