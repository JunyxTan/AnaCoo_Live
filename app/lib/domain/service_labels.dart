import '../data/enums.dart';

/// Display names for the service enum, matching the wording on anacoo.live so
/// the app and the website never disagree about what a service is called.
///
/// These live in plain Dart rather than the ARB bundles because they are also
/// needed off the widget tree — when composing notification text, and when the
/// parser reports what it matched.
const Map<ServiceType, Map<String, String>> serviceLabels = {
  ServiceType.basicAlterations: {
    'en': 'Basic alterations',
    'zh': '日常服装修改',
    'ms': 'Ubah suai asas',
  },
  ServiceType.pantsJeansShortening: {
    'en': 'Pants / jeans shortening',
    'zh': '裤子 / 牛仔裤缩短',
    'ms': 'Pendekkan seluar / jeans',
  },
  ServiceType.waistSizeAdjustment: {
    'en': 'Waist / size adjustment',
    'zh': '腰围 / 尺寸调整',
    'ms': 'Pelarasan pinggang / saiz',
  },
  ServiceType.repairZipButton: {
    'en': 'Repair / zip / button',
    'zh': '修补 / 拉链 / 纽扣',
    'ms': 'Baiki / zip / butang',
  },
  ServiceType.curtainsBedsheets: {
    'en': 'Curtains / bedsheets',
    'zh': '窗帘 / 床单',
    'ms': 'Langsir / cadar',
  },
  ServiceType.other: {
    'en': 'Other',
    'zh': '其他',
    'ms': 'Lain-lain',
  },
};

String serviceLabel(ServiceType service, String languageCode, {String? freeText}) {
  final label = serviceLabels[service]?[languageCode] ??
      serviceLabels[service]?['en'] ??
      service.name;
  if (service == ServiceType.other && freeText != null && freeText.trim().isNotEmpty) {
    return '$label — ${freeText.trim()}';
  }
  return label;
}

const Map<JobStatus, Map<String, String>> jobStatusLabels = {
  JobStatus.booked: {'en': 'Booked', 'zh': '已约', 'ms': 'Tempah'},
  JobStatus.sewing: {'en': 'Sewing', 'zh': '制作', 'ms': 'Jahit'},
  JobStatus.ready: {'en': 'Ready', 'zh': '待取', 'ms': 'Siap'},
  JobStatus.done: {'en': 'Done', 'zh': '完成', 'ms': 'Selesai'},
  JobStatus.cancelled: {'en': 'Cancel', 'zh': '取消', 'ms': 'Batal'},
};

String jobStatusLabel(JobStatus status, String languageCode) =>
    jobStatusLabels[status]?[languageCode] ??
    jobStatusLabels[status]?['en'] ??
    status.name;

const Map<AppointmentType, Map<String, String>> appointmentTypeLabels = {
  AppointmentType.dropOff: {'en': 'Drop-off', 'zh': '送件', 'ms': 'Hantar'},
  AppointmentType.collection: {'en': 'Collection', 'zh': '取件', 'ms': 'Ambil'},
};

String appointmentTypeLabel(AppointmentType type, String languageCode) =>
    appointmentTypeLabels[type]?[languageCode] ??
    appointmentTypeLabels[type]?['en'] ??
    type.name;

const Map<AppointmentStatus, Map<String, String>> appointmentStatusLabels = {
  AppointmentStatus.pending: {'en': 'Pending', 'zh': '待定', 'ms': 'Tunggu'},
  AppointmentStatus.confirmed: {'en': 'OK', 'zh': '确认', 'ms': 'OK'},
  AppointmentStatus.done: {'en': 'Done', 'zh': '完成', 'ms': 'Selesai'},
  AppointmentStatus.noShow: {'en': 'No-show', 'zh': '未到', 'ms': 'Tiada'},
  AppointmentStatus.cancelled: {'en': 'Cancel', 'zh': '取消', 'ms': 'Batal'},
};

String appointmentStatusLabel(AppointmentStatus status, String languageCode) =>
    appointmentStatusLabels[status]?[languageCode] ??
    appointmentStatusLabels[status]?['en'] ??
    status.name;
