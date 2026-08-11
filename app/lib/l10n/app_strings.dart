import 'package:flutter/widgets.dart';

import '../domain/list_query.dart';

/// UI copy in the languages the shop serves.
///
/// Deliberately a plain Dart class rather than generated ARB bundles: every
/// string's translations sit on one line, which is the only reliable way to
/// keep them in step by hand, and it matches how `NotificationStrings` and
/// `serviceLabels` already work.
///
/// Vietnamese is app-only: the website still offers English, 中文 and Bahasa
/// Melayu, so a pasted request never arrives in Vietnamese, but the tailor can
/// run the app in it.
///
/// Keep labels short — the UI leans on icons and buttons for actions.
class AppStrings {
  const AppStrings(this.languageCode);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ms'),
    Locale('vi'),
  ];

  final String languageCode;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode);

  String _p(String en, String zh, String ms, String vi) => switch (languageCode) {
        'zh' => zh,
        'ms' => ms,
        'vi' => vi,
        _ => en,
      };

  // ------------------------------------------------------------ app chrome

  String get appTitle =>
      _p('AnaCoo Tailor', 'AnaCoo 裁缝', 'AnaCoo Tailor', 'AnaCoo Tailor');
  String get tabToday => _p('Today', '今天', 'Hari ini', 'Hôm nay');
  String get tabAppointments => _p('Appointments', '预约', 'Temujanji', 'Lịch hẹn');
  String get tabCalendar => _p('Calendar', '日历', 'Kalendar', 'Lịch');
  String get tabCustomers => _p('Customers', '客户', 'Pelanggan', 'Khách hàng');
  String get tabSettings => _p('Settings', '设置', 'Tetapan', 'Cài đặt');

  String get save => _p('Save', '保存', 'Simpan', 'Lưu');
  String get cancel => _p('Cancel', '取消', 'Batal', 'Huỷ');
  String get delete => _p('Delete', '删除', 'Padam', 'Xoá');
  String get edit => _p('Edit', '编辑', 'Sunting', 'Sửa');
  String get add => _p('Add', '添加', 'Tambah', 'Thêm');
  String get close => _p('Close', '关闭', 'Tutup', 'Đóng');
  String get done => _p('Done', '完成', 'Selesai', 'Xong');
  String get undo => _p('Undo', '撤销', 'Buat asal', 'Hoàn tác');
  String get search => _p('Search', '搜索', 'Cari', 'Tìm');
  String get none => _p('None', '无', 'Tiada', 'Không có');
  String get optional => _p('optional', '可选', 'pilihan', 'tuỳ chọn');
  String get today => _p('Today', '今天', 'Hari ini', 'Hôm nay');
  String get tomorrow => _p('Tomorrow', '明天', 'Esok', 'Ngày mai');
  String get yes => _p('Yes', '是', 'Ya', 'Có');
  String get no => _p('No', '否', 'Tidak', 'Không');

  // ---------------------------------------------------------------- today

  String get pasteAppointment => _p('Paste', '粘贴', 'Tampal', 'Dán');
  String get newJob => _p('New', '新建', 'Baharu', 'Mới');
  String get nextAction => _p('Next', '下一步', 'Seterusnya', 'Tiếp');
  String get jobBooked => _p('Booked', '已预约', 'Ditempah', 'Đã đặt');
  String get dropOffsToday => _p('Drop-off', '送件', 'Hantar', 'Gửi đồ');
  String get collectionsDueToday => _p('Collection', '取件', 'Ambil', 'Lấy đồ');
  String get overdue => _p('Overdue', '逾期', 'Lewat', 'Quá hạn');
  String get readyForPickup => _p('Ready', '待取', 'Siap', 'Sẵn sàng');
  String get nothingToday =>
      _p('Nothing today', '今天没有', 'Tiada hari ini', 'Hôm nay trống');
  String get quietDay =>
      _p('Nothing today', '今天没有', 'Tiada hari ini', 'Hôm nay trống');
  String get noAppointments =>
      _p('No appointments', '没有预约', 'Tiada temujanji', 'Chưa có lịch hẹn');
  String get noMatchingAppointments =>
      _p('No matches', '没有匹配', 'Tiada padanan', 'Không khớp');
  String get appointments => _p('Appointments', '预约', 'Temujanji', 'Lịch hẹn');

  // ---------------------------------------------------- list filter / sort

  String get filter => _p('Filter', '筛选', 'Tapis', 'Lọc');
  String get sort => _p('Sort', '排序', 'Isih', 'Sắp xếp');
  String get filterAll => _p('All', '全部', 'Semua', 'Tất cả');
  String get filterDropOff => _p('Drop-off', '送件', 'Hantar', 'Gửi đồ');
  String get filterCollection => _p('Collection', '取件', 'Ambil', 'Lấy đồ');
  String get filterOverdue => _p('Overdue', '逾期', 'Lewat', 'Quá hạn');
  String get filterReady => _p('Ready', '待取', 'Siap', 'Sẵn sàng');
  String get filterRush => _p('Rush', '加急', 'Segera', 'Gấp');
  String get sortTimeAsc => _p('Time ↑', '时间 ↑', 'Masa ↑', 'Giờ ↑');
  String get sortTimeDesc => _p('Time ↓', '时间 ↓', 'Masa ↓', 'Giờ ↓');
  String get sortName => _p('Name', '姓名', 'Nama', 'Tên');
  String get sortRushFirst => _p('Rush first', '加急优先', 'Segera dulu', 'Gấp trước');

  String appointmentFilterLabel(AppointmentFilter filter) => switch (filter) {
        AppointmentFilter.all => filterAll,
        AppointmentFilter.dropOff => filterDropOff,
        AppointmentFilter.collection => filterCollection,
        AppointmentFilter.overdue => filterOverdue,
        AppointmentFilter.ready => filterReady,
        AppointmentFilter.rush => filterRush,
      };

  String appointmentSortLabel(AppointmentSort sort) => switch (sort) {
        AppointmentSort.timeAsc => sortTimeAsc,
        AppointmentSort.timeDesc => sortTimeDesc,
        AppointmentSort.name => sortName,
        AppointmentSort.rushFirst => sortRushFirst,
      };

  String get importDetectedTitle => _p('Import?', '导入？', 'Import?', 'Nhập?');
  String get importDetectedBody => _p(
        'Clipboard has a booking.',
        '剪贴板有预约。',
        'Papan keratan ada tempahan.',
        'Bộ nhớ tạm có lịch hẹn.',
      );
  String get importAction => _p('Import', '导入', 'Import', 'Nhập');
  String get dismiss => _p('Dismiss', '忽略', 'Abaikan', 'Bỏ qua');

  String get clipboardEmpty =>
      _p('Clipboard empty', '剪贴板为空', 'Papan keratan kosong', 'Bộ nhớ tạm trống');
  String get couldNotParse => _p(
        "Couldn't parse — in notes",
        '无法识别 — 已放入备注',
        'Tidak dibaca — dalam nota',
        'Không đọc được — vào ghi chú',
      );

  // ------------------------------------------------------------------ job

  String get jobDetail => _p('Job', '工作', 'Kerja', 'Đơn');
  String get customer => _p('Customer', '客户', 'Pelanggan', 'Khách');
  String get newCustomer =>
      _p('New customer', '新客户', 'Pelanggan baharu', 'Khách mới');
  String get pickFromContacts => _p('Contacts', '通讯录', 'Kenalan', 'Danh bạ');
  String get name => _p('Name', '姓名', 'Nama', 'Tên');
  String get phone => _p('Phone', '电话', 'Telefon', 'Điện thoại');
  String get whatsappNumber => _p('WhatsApp', 'WhatsApp', 'WhatsApp', 'WhatsApp');
  String get call => _p('Call', '拨打', 'Panggil', 'Gọi');
  String get couldNotCall =>
      _p("Couldn't call", '无法拨打', 'Tidak dapat panggil', 'Không gọi được');
  String get service => _p('Service', '服务', 'Perkhidmatan', 'Dịch vụ');
  String get itemDescription => _p('Item', '物品', 'Barang', 'Món đồ');
  String get quantity => _p('Qty', '数量', 'Kuantiti', 'Số lượng');
  String get quotedPrice => _p('Price', '报价', 'Harga', 'Giá');
  String get depositPaid => _p('Deposit', '订金', 'Deposit', 'Đặt cọc');
  String get balanceDue => _p('Balance', '余额', 'Baki', 'Còn lại');
  String get rushJob => _p('Rush', '加急', 'Segera', 'Gấp');
  String get notes => _p('Notes', '备注', 'Nota', 'Ghi chú');
  String get rawMessage => _p('Message', '原文', 'Mesej', 'Tin nhắn');
  String get status => _p('Status', '状态', 'Status', 'Trạng thái');
  String get clothPhotos => _p('Cloth photos', '布料照片', 'Foto kain', 'Ảnh vải');
  String get addPhoto => _p('Add photo', '添加照片', 'Tambah foto', 'Thêm ảnh');
  String get takePhoto => _p('Camera', '拍照', 'Kamera', 'Máy ảnh');
  String get choosePhoto => _p('Gallery', '相册', 'Galeri', 'Thư viện');
  String get deletePhotoConfirm =>
      _p('Delete photo?', '删除照片？', 'Padam foto?', 'Xoá ảnh?');
  String get noClothPhotos =>
      _p('No photos yet', '还没有照片', 'Belum ada foto', 'Chưa có ảnh');
  String get saveJobToAddPhotos => _p(
        'Save job to add photos',
        '保存后可加照片',
        'Simpan untuk tambah foto',
        'Lưu đơn để thêm ảnh',
      );
  String get dropOff => _p('Drop-off', '送件', 'Hantar', 'Gửi đồ');
  String get collection => _p('Collection', '取件', 'Ambil', 'Lấy đồ');
  String get setLater => _p('Later', '稍后', 'Nanti', 'Để sau');
  String get collectionNotSet =>
      _p('No collection', '未安排取件', 'Tiada pengambilan', 'Chưa hẹn lấy');
  String get notScheduled =>
      _p('Not set', '未安排', 'Belum ditetapkan', 'Chưa đặt');
  String get addCollection => _p('Add', '安排', 'Tambah', 'Thêm');
  String get scheduleCollectionTitle => _p('Collect?', '取件？', 'Ambil?', 'Lấy đồ?');
  String scheduleCollectionBody(String when) => when;
  String get scheduleSuggested => _p('Suggested', '按建议', 'Cadangan', 'Gợi ý');
  String get pickCollectionTime => _p('Pick', '选择', 'Pilih', 'Chọn');
  String get notNow => _p('Skip', '跳过', 'Langkau', 'Bỏ qua');
  String get duration => _p('Duration', '时长', 'Tempoh', 'Thời lượng');
  String minutesShort(int n) => _p('$n min', '$n 分钟', '$n min', '$n phút');
  String get reminders => _p('Reminders', '提醒', 'Peringatan', 'Nhắc nhở');
  String get useDefaultReminders => _p('Defaults', '默认', 'Lalai', 'Mặc định');
  String get markCollected => _p('Collected', '已取件', 'Diambil', 'Đã lấy');
  String get deleteJobConfirm =>
      _p('Delete job?', '删除工作？', 'Padam kerja?', 'Xoá đơn?');

  String get customerRequired => _p(
        'Name or phone required',
        '需要姓名或电话',
        'Nama atau telefon diperlukan',
        'Cần tên hoặc số điện thoại',
      );
  String get serviceCouldNotMatch =>
      _p("Couldn't match", '无法匹配', 'Tidak sepadan', 'Không khớp');
  String get serviceCouldNotMatchHelp =>
      _p('Pick the service', '请选择服务', 'Pilih perkhidmatan', 'Chọn dịch vụ');
  String get notUnderstood =>
      _p('Unmatched', '未识别', 'Tidak difahami', 'Chưa hiểu');

  // -------------------------------------------------------------- warnings

  String get warningClosedDay =>
      _p('Shop closed', '店铺休息', 'Kedai tutup', 'Tiệm đóng cửa');
  String get warningOutsideHours =>
      _p('Outside hours', '不在营业时间', 'Luar waktu kerja', 'Ngoài giờ làm');
  String warningBlocked(String? reason) => reason == null || reason.isEmpty
      ? _p('Day blocked', '日期已封锁', 'Hari disekat', 'Ngày bị chặn')
      : _p(
          'Blocked: $reason',
          '封锁：$reason',
          'Disekat: $reason',
          'Bị chặn: $reason',
        );
  String warningClash(int count, bool isDropOff) {
    final enThing = isDropOff ? 'drop-off' : 'collection';
    return _p(
      '$count $enThing clash',
      isDropOff ? '$count 件送件冲突' : '$count 件取件冲突',
      isDropOff ? '$count penghantaran bertindih' : '$count pengambilan bertindih',
      isDropOff ? '$count lượt gửi trùng giờ' : '$count lượt lấy trùng giờ',
    );
  }

  String get warningInThePast =>
      _p('In the past', '已过时', 'Sudah berlalu', 'Đã qua');
  String get saveAnyway => _p('Save anyway', '仍然保存', 'Simpan juga', 'Vẫn lưu');

  // -------------------------------------------------------------- calendar

  String get blockedDay => _p('Blocked', '封锁', 'Disekat', 'Bị chặn');
  String get blockDay => _p('Block', '封锁', 'Sekat', 'Chặn');
  String get unblockDay => _p('Unblock', '解除', 'Buka', 'Bỏ chặn');
  String get blockReason => _p('Reason', '原因', 'Sebab', 'Lý do');
  String get noAppointmentsThisDay =>
      _p('Empty day', '这天没有', 'Tiada pada hari ini', 'Ngày trống');

  // ------------------------------------------------------------- customers

  String get searchCustomers => _p('Search', '搜索', 'Cari', 'Tìm');
  String get repeatCustomer => _p('Repeat', '常客', 'Ulang', 'Khách quen');
  String jobCount(int n) => _p(
        n == 1 ? '1 job' : '$n jobs',
        '$n 项',
        n == 1 ? '1 kerja' : '$n kerja',
        '$n đơn',
      );
  String get noCustomers =>
      _p('No customers', '还没有客户', 'Tiada pelanggan', 'Chưa có khách');
  String get archive => _p('Archive', '归档', 'Arkib', 'Lưu trữ');
  String get restore => _p('Restore', '恢复', 'Pulih', 'Phục hồi');
  String get archived => _p('Archived', '已归档', 'Diarkib', 'Đã lưu trữ');
  String get noArchivedCustomers => _p(
        'Nothing archived',
        '没有归档',
        'Tiada arkib',
        'Chưa lưu trữ gì',
      );
  String get newJobForCustomer =>
      _p('New job', '新建工作', 'Kerja baharu', 'Đơn mới');

  // -------------------------------------------------------------- settings

  String get workingHours => _p('Hours', '营业时间', 'Waktu', 'Giờ mở cửa');
  String get opensAt => _p('Opens', '开门', 'Buka', 'Mở cửa');
  String get closesAt => _p('Closes', '关门', 'Tutup', 'Đóng cửa');
  String get closed => _p('Closed', '休息', 'Tutup', 'Đóng cửa');
  String get slotLength => _p('Slot', '时段', 'Slot', 'Khung giờ');
  String get turnaroundDays =>
      _p('Turnaround', '完成天数', 'Tempoh siap', 'Thời gian làm');
  String days(int n) =>
      _p(n == 1 ? '1 day' : '$n days', '$n 天', '$n hari', '$n ngày');
  String get blockedDates =>
      _p('Blocked days', '封锁日期', 'Tarikh disekat', 'Ngày bị chặn');
  String get reminderDefaults => _p('Reminders', '提醒', 'Peringatan', 'Nhắc nhở');
  String get dailyAgenda =>
      _p('Daily agenda', '每日概览', 'Jadual harian', 'Lịch hằng ngày');
  String get dailyAgendaTime =>
      _p('Agenda time', '概览时间', 'Masa jadual', 'Giờ gửi lịch');
  String get overdueNudges =>
      _p('Overdue nudges', '逾期提醒', 'Peringatan lewat', 'Nhắc quá hạn');
  String get readyNudgeAfter =>
      _p('Ready nudge', '待取提醒', 'Ingat siap', 'Nhắc đã xong');
  String get messageTemplates => _p('Templates', '模板', 'Templat', 'Mẫu tin');
  String get language => _p('Language', '语言', 'Bahasa', 'Ngôn ngữ');
  String get systemLanguage => _p('System', '系统', 'Sistem', 'Hệ thống');
  String get exportBackup => _p('Export backup', '导出备份', 'Eksport', 'Xuất sao lưu');
  String get importBackup => _p('Import backup', '导入备份', 'Import', 'Nhập sao lưu');
  String get exportCsv => _p('Export CSV', '导出 CSV', 'Eksport CSV', 'Xuất CSV');
  String get notificationsSection =>
      _p('Notifications', '通知', 'Pemberitahuan', 'Thông báo');
  String get notificationsBlocked => _p(
        'Notifications off',
        '通知已关闭',
        'Pemberitahuan dimatikan',
        'Đã tắt thông báo',
      );
  String get enableNotifications => _p('Enable', '开启', 'Hidupkan', 'Bật');
  String get exactAlarmsOn => _p(
        'Exact alarms on',
        '精确闹钟开',
        'Penggera tepat hidup',
        'Hẹn giờ chính xác: bật',
      );
  String get exactAlarmsOff => _p(
        'Exact alarms off',
        '精确闹钟关',
        'Penggera tepat mati',
        'Hẹn giờ chính xác: tắt',
      );
  String get grantExactAlarms => _p('Allow', '允许', 'Benarkan', 'Cho phép');
  String get batteryExplainerTitle =>
      _p('Battery tip', '电池提示', 'Tip bateri', 'Mẹo về pin');
  String get batteryExplainerBody => _p(
        'On Xiaomi, Oppo, Vivo and Huawei: set AnaCoo Tailor battery to '
            'Unrestricted (and Autostart if available), or reminders may not fire.',
        '小米、Oppo、Vivo、华为：将 AnaCoo Tailor 电池设为「无限制」（并开启自启动），否则提醒可能不出现。',
        'Xiaomi, Oppo, Vivo, Huawei: tetapkan bateri AnaCoo Tailor kepada '
            'Tanpa Had (dan Autostart jika ada), atau peringatan mungkin tidak tiba.',
        'Trên Xiaomi, Oppo, Vivo và Huawei: đặt pin của AnaCoo Tailor thành '
            'Không giới hạn (và bật Tự khởi động nếu có), nếu không lời nhắc có '
            'thể không hiện.',
      );
  String get gotIt => _p('OK', '好的', 'OK', 'OK');
  String pendingReminders(int n) =>
      _p('$n scheduled', '已安排 $n', '$n dijadualkan', 'Đã đặt $n');
  String deferredReminders(int n) =>
      _p('+$n queued', '+$n 排队', '+$n menunggu', '+$n đang chờ');

  // -------------------------------------------------------------- whatsapp

  String get whatsapp => _p('WhatsApp', 'WhatsApp', 'WhatsApp', 'WhatsApp');
  String get whatsappConfirm => _p('Confirm', '确认', 'Sahkan', 'Xác nhận');
  String get whatsappReady => _p('Ready', '可取', 'Siap', 'Đã xong');
  String get whatsappReschedule => _p('Reschedule', '改期', 'Tukar', 'Đổi giờ');
  String get noWhatsappNumber =>
      _p('No phone', '没有电话', 'Tiada telefon', 'Không có số');
  String get couldNotOpenWhatsapp => _p(
        "Couldn't open WhatsApp",
        '无法打开 WhatsApp',
        'Tidak dapat buka WhatsApp',
        'Không mở được WhatsApp',
      );
  String get resetToDefault => _p('Reset', '重置', 'Set semula', 'Đặt lại');
  String get placeholders =>
      _p('Placeholders', '占位符', 'Pemegang tempat', 'Chỗ điền');

  // ---------------------------------------------------------------- backup

  String get backupExported => _p('Exported', '已导出', 'Dieksport', 'Đã xuất');
  String backupImported(int jobs, int customers) => _p(
        'Imported $jobs · $customers',
        '已导入 $jobs · $customers',
        'Diimport $jobs · $customers',
        'Đã nhập $jobs · $customers',
      );
  String get backupImportFailed => _p(
        'Invalid backup',
        '无效备份',
        'Sandaran tidak sah',
        'Bản sao lưu không hợp lệ',
      );
  String get importReplacesWarning => _p(
        'Replace all data?',
        '替换全部数据？',
        'Ganti semua data?',
        'Thay toàn bộ dữ liệu?',
      );
}
