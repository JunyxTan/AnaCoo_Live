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

/// Four-step shop pipeline: `booked → sewing → ready → done`,
/// with `cancelled` reachable from anywhere.
///
/// Older names (`requested`, `confirmed`, `received`, `inProgress`,
/// `collected`) are remapped in schema v2 and on backup import.
enum JobStatus {
  booked,
  sewing,
  ready,
  done,
  cancelled;

  /// The happy-path pipeline, in order, for the status stepper / Next button.
  static const List<JobStatus> pipeline = [
    JobStatus.booked,
    JobStatus.sewing,
    JobStatus.ready,
    JobStatus.done,
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
  bool get isClosed => this == JobStatus.done || isCancelled;
}

enum AppointmentType { dropOff, collection }

enum AppointmentStatus {
  pending,
  confirmed,
  done,
  noShow,
  cancelled;

  /// Cancelled and already-happened appointments carry no future reminders.
  bool get isLive =>
      this == AppointmentStatus.pending || this == AppointmentStatus.confirmed;
}

/// Remaps status strings from schema v1 / old backups onto the v2 enum names.
JobStatus jobStatusFromStorage(String? raw) {
  switch (raw) {
    case 'requested':
    case 'confirmed':
    case 'booked':
      return JobStatus.booked;
    case 'received':
    case 'inProgress':
    case 'sewing':
      return JobStatus.sewing;
    case 'ready':
      return JobStatus.ready;
    case 'collected':
    case 'done':
      return JobStatus.done;
    case 'cancelled':
      return JobStatus.cancelled;
    default:
      return JobStatus.booked;
  }
}
