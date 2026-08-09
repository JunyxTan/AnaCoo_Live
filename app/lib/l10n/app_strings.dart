import 'package:flutter/widgets.dart';

/// UI copy in the three languages the website offers.
///
/// Deliberately a plain Dart class rather than generated ARB bundles: every
/// string's three translations sit on one line, which is the only reliable way
/// to keep them in step by hand, and it matches how `NotificationStrings` and
/// `serviceLabels` already work.
///
/// Keep labels short — the UI leans on icons and buttons for actions.
class AppStrings {
  const AppStrings(this.languageCode);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ms'),
  ];

  final String languageCode;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode);

  String _p(String en, String zh, String ms) => switch (languageCode) {
        'zh' => zh,
        'ms' => ms,
        _ => en,
      };

  // ------------------------------------------------------------ app chrome

  String get appTitle => _p('AnaCoo Tailor', 'AnaCoo 裁缝', 'AnaCoo Tailor');
  String get tabToday => _p('Today', '今天', 'Hari ini');
  String get tabCalendar => _p('Calendar', '日历', 'Kalendar');
  String get tabCustomers => _p('Customers', '客户', 'Pelanggan');
  String get tabSettings => _p('Settings', '设置', 'Tetapan');

  String get save => _p('Save', '保存', 'Simpan');
  String get cancel => _p('Cancel', '取消', 'Batal');
  String get delete => _p('Delete', '删除', 'Padam');
  String get edit => _p('Edit', '编辑', 'Sunting');
  String get add => _p('Add', '添加', 'Tambah');
  String get close => _p('Close', '关闭', 'Tutup');
  String get done => _p('Done', '完成', 'Selesai');
  String get undo => _p('Undo', '撤销', 'Buat asal');
  String get search => _p('Search', '搜索', 'Cari');
  String get none => _p('None', '无', 'Tiada');
  String get optional => _p('optional', '可选', 'pilihan');
  String get today => _p('Today', '今天', 'Hari ini');
  String get tomorrow => _p('Tomorrow', '明天', 'Esok');
  String get yes => _p('Yes', '是', 'Ya');
  String get no => _p('No', '否', 'Tidak');

  // ---------------------------------------------------------------- today

  String get pasteAppointment => _p('Paste', '粘贴', 'Tampal');
  String get newJob => _p('New', '新建', 'Baharu');
  String get nextAction => _p('Next', '下一步', 'Seterusnya');
  String get jobBooked => _p('Booked', '已预约', 'Ditempah');
  String get dropOffsToday => _p('Drop-off', '送件', 'Hantar');
  String get collectionsDueToday => _p('Collection', '取件', 'Ambil');
  String get overdue => _p('Overdue', '逾期', 'Lewat');
  String get readyForPickup => _p('Ready', '待取', 'Siap');
  String get nothingToday => _p('Nothing today', '今天没有', 'Tiada hari ini');
  String get quietDay => _p('Nothing today', '今天没有', 'Tiada hari ini');

  String get importDetectedTitle => _p('Import?', '导入？', 'Import?');
  String get importDetectedBody => _p(
        'Clipboard has a booking.',
        '剪贴板有预约。',
        'Papan keratan ada tempahan.',
      );
  String get importAction => _p('Import', '导入', 'Import');
  String get dismiss => _p('Dismiss', '忽略', 'Abaikan');

  String get clipboardEmpty => _p('Clipboard empty', '剪贴板为空', 'Papan keratan kosong');
  String get couldNotParse =>
      _p("Couldn't parse — in notes", '无法识别 — 已放入备注', 'Tidak dibaca — dalam nota');

  // ------------------------------------------------------------------ job

  String get jobDetail => _p('Job', '工作', 'Kerja');
  String get customer => _p('Customer', '客户', 'Pelanggan');
  String get newCustomer => _p('New customer', '新客户', 'Pelanggan baharu');
  String get pickFromContacts => _p('Contacts', '通讯录', 'Kenalan');
  String get name => _p('Name', '姓名', 'Nama');
  String get phone => _p('Phone', '电话', 'Telefon');
  String get whatsappNumber => _p('WhatsApp', 'WhatsApp', 'WhatsApp');
  String get service => _p('Service', '服务', 'Perkhidmatan');
  String get itemDescription => _p('Item', '物品', 'Barang');
  String get quantity => _p('Qty', '数量', 'Kuantiti');
  String get quotedPrice => _p('Price', '报价', 'Harga');
  String get depositPaid => _p('Deposit', '订金', 'Deposit');
  String get rushJob => _p('Rush', '加急', 'Segera');
  String get notes => _p('Notes', '备注', 'Nota');
  String get rawMessage => _p('Message', '原文', 'Mesej');
  String get status => _p('Status', '状态', 'Status');
  String get dropOff => _p('Drop-off', '送件', 'Hantar');
  String get collection => _p('Collection', '取件', 'Ambil');
  String get setLater => _p('Later', '稍后', 'Nanti');
  String get collectionNotSet => _p('No collection', '未安排取件', 'Tiada pengambilan');
  String get addCollection => _p('Add', '安排', 'Tambah');
  String get scheduleCollectionTitle => _p('Collect?', '取件？', 'Ambil?');
  String scheduleCollectionBody(String when) => when;
  String get scheduleSuggested => _p('Suggested', '按建议', 'Cadangan');
  String get pickCollectionTime => _p('Pick', '选择', 'Pilih');
  String get notNow => _p('Skip', '跳过', 'Langkau');
  String get duration => _p('Duration', '时长', 'Tempoh');
  String minutesShort(int n) => _p('$n min', '$n 分钟', '$n min');
  String get reminders => _p('Reminders', '提醒', 'Peringatan');
  String get useDefaultReminders => _p('Defaults', '默认', 'Lalai');
  String get markCollected => _p('Collected', '已取件', 'Diambil');
  String get deleteJobConfirm => _p('Delete job?', '删除工作？', 'Padam kerja?');

  String get customerRequired =>
      _p('Name or phone required', '需要姓名或电话', 'Nama atau telefon diperlukan');
  String get serviceCouldNotMatch =>
      _p("Couldn't match", '无法匹配', 'Tidak sepadan');
  String get serviceCouldNotMatchHelp =>
      _p('Pick the service', '请选择服务', 'Pilih perkhidmatan');
  String get notUnderstood => _p('Unmatched', '未识别', 'Tidak difahami');

  // -------------------------------------------------------------- warnings

  String get warningClosedDay => _p('Shop closed', '店铺休息', 'Kedai tutup');
  String get warningOutsideHours =>
      _p('Outside hours', '不在营业时间', 'Luar waktu kerja');
  String warningBlocked(String? reason) => reason == null || reason.isEmpty
      ? _p('Day blocked', '日期已封锁', 'Hari disekat')
      : _p('Blocked: $reason', '封锁：$reason', 'Disekat: $reason');
  String warningClash(int count, bool isDropOff) {
    final enThing = isDropOff ? 'drop-off' : 'collection';
    return _p(
      '$count $enThing clash',
      isDropOff ? '$count 件送件冲突' : '$count 件取件冲突',
      isDropOff ? '$count penghantaran bertindih' : '$count pengambilan bertindih',
    );
  }

  String get warningInThePast => _p('In the past', '已过时', 'Sudah berlalu');
  String get saveAnyway => _p('Save anyway', '仍然保存', 'Simpan juga');

  // -------------------------------------------------------------- calendar

  String get blockedDay => _p('Blocked', '封锁', 'Disekat');
  String get blockDay => _p('Block', '封锁', 'Sekat');
  String get unblockDay => _p('Unblock', '解除', 'Buka');
  String get blockReason => _p('Reason', '原因', 'Sebab');
  String get noAppointmentsThisDay => _p('Empty day', '这天没有', 'Tiada pada hari ini');

  // ------------------------------------------------------------- customers

  String get searchCustomers => _p('Search', '搜索', 'Cari');
  String get repeatCustomer => _p('Repeat', '常客', 'Ulang');
  String jobCount(int n) => _p(
        n == 1 ? '1 job' : '$n jobs',
        '$n 项',
        n == 1 ? '1 kerja' : '$n kerja',
      );
  String get noCustomers => _p('No customers', '还没有客户', 'Tiada pelanggan');
  String get newJobForCustomer => _p('New job', '新建工作', 'Kerja baharu');

  // -------------------------------------------------------------- settings

  String get workingHours => _p('Hours', '营业时间', 'Waktu');
  String get closed => _p('Closed', '休息', 'Tutup');
  String get slotLength => _p('Slot', '时段', 'Slot');
  String get turnaroundDays => _p('Turnaround', '完成天数', 'Tempoh siap');
  String days(int n) => _p(n == 1 ? '1 day' : '$n days', '$n 天', '$n hari');
  String get blockedDates => _p('Blocked days', '封锁日期', 'Tarikh disekat');
  String get reminderDefaults => _p('Reminders', '提醒', 'Peringatan');
  String get dailyAgenda => _p('Daily agenda', '每日概览', 'Jadual harian');
  String get dailyAgendaTime => _p('Agenda time', '概览时间', 'Masa jadual');
  String get overdueNudges => _p('Overdue nudges', '逾期提醒', 'Peringatan lewat');
  String get readyNudgeAfter => _p('Ready nudge', '待取提醒', 'Ingat siap');
  String get messageTemplates => _p('Templates', '模板', 'Templat');
  String get language => _p('Language', '语言', 'Bahasa');
  String get systemLanguage => _p('System', '系统', 'Sistem');
  String get exportBackup => _p('Export backup', '导出备份', 'Eksport');
  String get importBackup => _p('Import backup', '导入备份', 'Import');
  String get exportCsv => _p('Export CSV', '导出 CSV', 'Eksport CSV');
  String get notificationsSection => _p('Notifications', '通知', 'Pemberitahuan');
  String get notificationsBlocked =>
      _p('Notifications off', '通知已关闭', 'Pemberitahuan dimatikan');
  String get enableNotifications => _p('Enable', '开启', 'Hidupkan');
  String get exactAlarmsOn => _p('Exact alarms on', '精确闹钟开', 'Penggera tepat hidup');
  String get exactAlarmsOff =>
      _p('Exact alarms off', '精确闹钟关', 'Penggera tepat mati');
  String get grantExactAlarms => _p('Allow', '允许', 'Benarkan');
  String get batteryExplainerTitle => _p('Battery tip', '电池提示', 'Tip bateri');
  String get batteryExplainerBody => _p(
        'On Xiaomi, Oppo, Vivo and Huawei: set AnaCoo Tailor battery to '
            'Unrestricted (and Autostart if available), or reminders may not fire.',
        '小米、Oppo、Vivo、华为：将 AnaCoo Tailor 电池设为「无限制」（并开启自启动），否则提醒可能不出现。',
        'Xiaomi, Oppo, Vivo, Huawei: tetapkan bateri AnaCoo Tailor kepada '
            'Tanpa Had (dan Autostart jika ada), atau peringatan mungkin tidak tiba.',
      );
  String get gotIt => _p('OK', '好的', 'OK');
  String pendingReminders(int n) =>
      _p('$n scheduled', '已安排 $n', '$n dijadualkan');
  String deferredReminders(int n) => _p('+$n queued', '+$n 排队', '+$n menunggu');

  // -------------------------------------------------------------- whatsapp

  String get whatsappConfirm => _p('Confirm', '确认', 'Sahkan');
  String get whatsappReady => _p('Ready', '可取', 'Siap');
  String get whatsappReschedule => _p('Reschedule', '改期', 'Tukar');
  String get noWhatsappNumber => _p('No phone', '没有电话', 'Tiada telefon');
  String get couldNotOpenWhatsapp =>
      _p("Couldn't open WhatsApp", '无法打开 WhatsApp', 'Tidak dapat buka WhatsApp');
  String get resetToDefault => _p('Reset', '重置', 'Set semula');
  String get placeholders => _p('Placeholders', '占位符', 'Pemegang tempat');

  // ---------------------------------------------------------------- backup

  String get backupExported => _p('Exported', '已导出', 'Dieksport');
  String backupImported(int jobs, int customers) => _p(
        'Imported $jobs · $customers',
        '已导入 $jobs · $customers',
        'Diimport $jobs · $customers',
      );
  String get backupImportFailed => _p('Invalid backup', '无效备份', 'Sandaran tidak sah');
  String get importReplacesWarning =>
      _p('Replace all data?', '替换全部数据？', 'Ganti semua data?');
}
