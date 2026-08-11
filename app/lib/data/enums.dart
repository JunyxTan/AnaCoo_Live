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

/// Five-step shop pipeline: `booked → received → sewing → ready → done`,
/// with `cancelled` reachable from anywhere.
///
/// `received` records the garment being handed over, which happens on its own
/// day and is worth knowing about separately from the work having started.
///
/// Older names (`requested`, `confirmed`, `inProgress`, `collected`) are
/// remapped in schema v2 and on backup import.
enum JobStatus {
  booked,
  received,
  sewing,
  ready,
  done,
  cancelled;

  /// The happy-path pipeline, in order, for the status stepper / Next button.
  static const List<JobStatus> pipeline = [
    JobStatus.booked,
    JobStatus.received,
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

/// Remaps status strings from schema v1 / old backups onto the current enum
/// names.
///
/// The v1 pipeline also had a `received` step, and it meant what this one does,
/// so those rows land back on it rather than jumping ahead to sewing.
JobStatus jobStatusFromStorage(String? raw) {
  switch (raw) {
    case 'requested':
    case 'confirmed':
    case 'booked':
      return JobStatus.booked;
    case 'received':
      return JobStatus.received;
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
