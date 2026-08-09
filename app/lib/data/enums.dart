/// Domain enums. Persisted by *name* (Drift `textEnum`) so that a JSON export
/// stays readable and a reordered enum never silently rewrites history.
library;

enum ServiceType {
  basicAlterations,
  pantsJeansShortening,
  waistSizeAdjustment,
  repairZipButton,
  curtainsBedsheets,
  other,
}

/// `requested → confirmed → received → inProgress → ready → collected`,
/// with `cancelled` reachable from anywhere.
enum JobStatus {
  requested,
  confirmed,
  received,
  inProgress,
  ready,
  collected,
  cancelled;

  /// The happy-path pipeline, in order, for the status stepper.
  static const List<JobStatus> pipeline = [
    JobStatus.requested,
    JobStatus.confirmed,
    JobStatus.received,
    JobStatus.inProgress,
    JobStatus.ready,
    JobStatus.collected,
  ];

  bool get isCancelled => this == JobStatus.cancelled;

  /// Position in [pipeline], or `-1` for [cancelled].
  int get step => pipeline.indexOf(this);

  JobStatus? get next {
    final i = step;
    if (i < 0 || i >= pipeline.length - 1) return null;
    return pipeline[i + 1];
  }

  /// Work is finished and off the board.
  bool get isClosed => this == JobStatus.collected || isCancelled;
}

enum AppointmentType { dropOff, collection }

enum AppointmentStatus {
  pending,
  confirmed,
  done,
  noShow,
  cancelled;

  /// Cancelled and already-happened appointments carry no future reminders.
  bool get isLive => this == AppointmentStatus.pending || this == AppointmentStatus.confirmed;
}
