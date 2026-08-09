import 'package:flutter/widgets.dart';

/// UI copy in the three languages the website offers.
///
/// Deliberately a plain Dart class rather than generated ARB bundles: every
/// string's three translations sit on one line, which is the only reliable way
/// to keep them in step by hand, and it matches how `NotificationStrings` and
/// `serviceLabels` already work.
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

  String get pasteAppointment =>
      _p('Paste appointment', '粘贴预约', 'Tampal temu janji');
  String get newJob => _p('New job', '新工作', 'Kerja baharu');
  String get dropOffsToday => _p('Drop-offs today', '今日送件', 'Penghantaran hari ini');
  String get collectionsDueToday =>
      _p('Collections due today', '今日取件', 'Pengambilan hari ini');
  String get overdue => _p('Overdue', '逾期', 'Tertunggak');
  String get readyForPickup =>
      _p('Ready for pickup', '待取件', 'Sedia untuk diambil');
  String get nothingToday =>
      _p('Nothing booked today.', '今天没有预约。', 'Tiada tempahan hari ini.');
  String get quietDay => _p(
        'A quiet day. Paste a request or add a job to fill it.',
        '今天很清闲。粘贴请求或新增工作。',
        'Hari yang lapang. Tampal permintaan atau tambah kerja.',
      );

  String get importDetectedTitle =>
      _p('Appointment request detected', '检测到预约请求', 'Permintaan temu janji dikesan');
  String get importDetectedBody => _p(
        'A booking message is on your clipboard. Import it?',
        '剪贴板中有一条预约信息。要导入吗？',
        'Mesej tempahan ada dalam papan keratan. Import?',
      );
  String get importAction => _p('Import', '导入', 'Import');
  String get dismiss => _p('Dismiss', '忽略', 'Abaikan');

  String get clipboardEmpty =>
      _p('Clipboard is empty.', '剪贴板是空的。', 'Papan keratan kosong.');
  String get couldNotParse => _p(
        "Couldn't read that as an appointment — opening a blank job with the "
            'text in notes.',
        '无法识别为预约信息 — 已打开空白工作，原文放入备注。',
        'Tidak dapat dibaca sebagai temu janji — membuka kerja kosong dengan '
            'teks dalam nota.',
      );

  // ------------------------------------------------------------------ job

  String get jobDetail => _p('Job', '工作', 'Kerja');
  String get customer => _p('Customer', '客户', 'Pelanggan');
  String get newCustomer => _p('New customer', '新客户', 'Pelanggan baharu');
  String get pickFromContacts =>
      _p('Pick from contacts', '从通讯录选择', 'Pilih dari kenalan');
  String get name => _p('Name', '姓名', 'Nama');
  String get phone => _p('Phone', '电话', 'Telefon');
  String get whatsappNumber => _p('WhatsApp number', 'WhatsApp 号码', 'Nombor WhatsApp');
  String get service => _p('Service', '服务', 'Perkhidmatan');
  String get itemDescription => _p('Item', '物品', 'Barang');
  String get quantity => _p('Quantity', '数量', 'Kuantiti');
  String get quotedPrice => _p('Quoted price (MYR)', '报价（MYR）', 'Harga (MYR)');
  String get depositPaid => _p('Deposit paid (MYR)', '已付订金（MYR）', 'Deposit (MYR)');
  String get rushJob => _p('Rush job', '加急', 'Kerja segera');
  String get notes => _p('Notes', '备注', 'Nota');
  String get rawMessage => _p('Original message', '原始信息', 'Mesej asal');
  String get status => _p('Status', '状态', 'Status');
  String get dropOff => _p('Drop-off', '送件', 'Hantar');
  String get collection => _p('Collection', '取件', 'Ambil');
  String get setLater => _p('Set later', '稍后设定', 'Tetapkan kemudian');
  String get collectionNotSet =>
      _p('Collection not set yet', '尚未安排取件', 'Pengambilan belum ditetapkan');
  String get addCollection => _p('Add collection', '安排取件', 'Tambah pengambilan');
  String get scheduleCollectionTitle =>
      _p('Schedule collection?', '安排取件？', 'Jadualkan pengambilan?');
  String scheduleCollectionBody(String when) => _p(
        'Suggested: $when. You can change it later.',
        '建议：$when。之后仍可修改。',
        'Cadangan: $when. Anda boleh ubah kemudian.',
      );
  String get scheduleSuggested =>
      _p('Schedule suggested', '按建议安排', 'Jadualkan cadangan');
  String get pickCollectionTime =>
      _p('Pick a time', '选择时间', 'Pilih masa');
  String get notNow => _p('Not now', '暂不', 'Nanti');
  String get duration => _p('Duration', '时长', 'Tempoh');
  String minutesShort(int n) => _p('$n min', '$n 分钟', '$n min');
  String get reminders => _p('Reminders', '提醒', 'Peringatan');
  String get useDefaultReminders =>
      _p('Use default reminders', '使用默认提醒', 'Guna peringatan lalai');
  String get markCollected => _p('Mark collected', '标记已取件', 'Tanda telah diambil');
  String get deleteJobConfirm => _p(
        'Delete this job and both its appointments?',
        '删除此工作及其两个预约？',
        'Padam kerja ini dan kedua-dua temu janjinya?',
      );

  String get customerRequired => _p(
        'A job needs at least a name or a phone number.',
        '工作至少需要姓名或电话号码。',
        'Kerja memerlukan sekurang-kurangnya nama atau nombor telefon.',
      );
  String get serviceCouldNotMatch =>
      _p("Couldn't match", '无法匹配', 'Tidak dapat dipadankan');
  String get serviceCouldNotMatchHelp => _p(
        'Pick the service yourself — the app will not guess.',
        '请自行选择服务 — 应用不会猜测。',
        'Pilih perkhidmatan sendiri — aplikasi tidak akan meneka.',
      );
  String get notUnderstood =>
      _p("Not understood", '未识别内容', 'Tidak difahami');

  // -------------------------------------------------------------- warnings

  String get warningClosedDay => _p(
        'The shop is closed that day.',
        '当天店铺休息。',
        'Kedai tutup pada hari itu.',
      );
  String get warningOutsideHours => _p(
        'That is outside your working hours.',
        '该时间在营业时间之外。',
        'Waktu itu di luar waktu kerja anda.',
      );
  String warningBlocked(String? reason) => reason == null || reason.isEmpty
      ? _p('That day is blocked.', '该日期已封锁。', 'Hari itu disekat.')
      : _p(
          'That day is blocked: $reason',
          '该日期已封锁：$reason',
          'Hari itu disekat: $reason',
        );
  String warningClash(int count, bool isDropOff) {
    final enThing = isDropOff
        ? (count == 1 ? 'drop-off' : 'drop-offs')
        : (count == 1 ? 'collection' : 'collections');
    return _p(
      'You already have $count $enThing at this time.',
      isDropOff ? '此时段已有 $count 件送件。' : '此时段已有 $count 件取件。',
      isDropOff
          ? 'Anda sudah ada $count penghantaran pada masa ini.'
          : 'Anda sudah ada $count pengambilan pada masa ini.',
    );
  }

  String get warningInThePast =>
      _p('That time has already passed.', '该时间已过。', 'Masa itu telah berlalu.');
  String get saveAnyway => _p('Save anyway', '仍然保存', 'Simpan juga');

  // -------------------------------------------------------------- calendar

  String get blockedDay => _p('Blocked', '封锁', 'Disekat');
  String get blockDay => _p('Block this day', '封锁此日', 'Sekat hari ini');
  String get unblockDay => _p('Unblock this day', '解除封锁', 'Buka semula hari ini');
  String get blockReason => _p('Reason', '原因', 'Sebab');
  String get noAppointmentsThisDay =>
      _p('Nothing on this day.', '这天没有安排。', 'Tiada apa-apa pada hari ini.');

  // ------------------------------------------------------------- customers

  String get searchCustomers =>
      _p('Search name or phone', '搜索姓名或电话', 'Cari nama atau telefon');
  String get repeatCustomer => _p('Repeat', '常客', 'Berulang');
  String jobCount(int n) => _p(
        n == 1 ? '1 job' : '$n jobs',
        '$n 项工作',
        n == 1 ? '1 kerja' : '$n kerja',
      );
  String get noCustomers =>
      _p('No customers yet.', '还没有客户。', 'Tiada pelanggan lagi.');
  String get newJobForCustomer =>
      _p('New job for this customer', '为此客户新增工作', 'Kerja baharu untuk pelanggan ini');

  // -------------------------------------------------------------- settings

  String get workingHours => _p('Working hours', '营业时间', 'Waktu kerja');
  String get closed => _p('Closed', '休息', 'Tutup');
  String get slotLength => _p('Slot length', '时段长度', 'Panjang slot');
  String get turnaroundDays =>
      _p('Default turnaround', '默认完成天数', 'Tempoh siap lalai');
  String days(int n) => _p(n == 1 ? '1 day' : '$n days', '$n 天', '$n hari');
  String get blockedDates => _p('Blocked dates', '封锁日期', 'Tarikh disekat');
  String get reminderDefaults =>
      _p('Default reminders', '默认提醒', 'Peringatan lalai');
  String get dailyAgenda => _p('Daily agenda', '每日概览', 'Jadual harian');
  String get dailyAgendaTime =>
      _p('Daily agenda time', '每日概览时间', 'Masa jadual harian');
  String get overdueNudges => _p('Overdue nudges', '逾期提醒', 'Peringatan tertunggak');
  String get readyNudgeAfter =>
      _p('Nudge when ready for', '待取件提醒于', 'Ingatkan bila siap selama');
  String get messageTemplates =>
      _p('Message templates', '消息模板', 'Templat mesej');
  String get language => _p('Language', '语言', 'Bahasa');
  String get systemLanguage => _p('System', '跟随系统', 'Sistem');
  String get exportBackup => _p('Export backup', '导出备份', 'Eksport sandaran');
  String get importBackup => _p('Import backup', '导入备份', 'Import sandaran');
  String get exportCsv => _p('Export jobs as CSV', '导出 CSV', 'Eksport CSV');
  String get notificationsSection =>
      _p('Notifications', '通知', 'Pemberitahuan');
  String get notificationsBlocked => _p(
        'Notifications are turned off for this app. Reminders will not appear.',
        '此应用的通知已关闭，提醒将不会出现。',
        'Pemberitahuan dimatikan untuk aplikasi ini. Peringatan tidak akan muncul.',
      );
  String get enableNotifications =>
      _p('Turn on notifications', '开启通知', 'Hidupkan pemberitahuan');
  String get exactAlarmsOn => _p(
        'Exact alarms are on — reminders fire at the minute.',
        '精确闹钟已开启 — 提醒将准时触发。',
        'Penggera tepat dihidupkan — peringatan tiba tepat pada masanya.',
      );
  String get exactAlarmsOff => _p(
        'Exact alarms are off. Reminders still fire, but Android may delay them '
            'by several minutes.',
        '精确闹钟已关闭。提醒仍会发出，但 Android 可能延迟数分钟。',
        'Penggera tepat dimatikan. Peringatan masih tiba, tetapi Android mungkin '
            'melewatkannya beberapa minit.',
      );
  String get grantExactAlarms =>
      _p('Allow exact alarms', '允许精确闹钟', 'Benarkan penggera tepat');
  String get batteryExplainerTitle =>
      _p('Keep reminders working', '让提醒保持有效', 'Pastikan peringatan berfungsi');
  String get batteryExplainerBody => _p(
        'Xiaomi, Oppo, Vivo and Huawei phones shut down background alarms '
            'aggressively. Open your phone settings, find AnaCoo Tailor, and set '
            'battery usage to Unrestricted (and enable Autostart if your phone '
            'offers it). Otherwise reminders may never arrive.',
        '小米、Oppo、Vivo 和华为手机会强制关闭后台闹钟。请在手机设置中找到 AnaCoo Tailor，'
            '将电池用量设为「无限制」（如有「自启动」也请开启），否则提醒可能不会出现。',
        'Telefon Xiaomi, Oppo, Vivo dan Huawei mematikan penggera latar dengan '
            'agresif. Buka tetapan telefon, cari AnaCoo Tailor, dan tetapkan '
            'penggunaan bateri kepada Tanpa Had (serta hidupkan Autostart jika ada). '
            'Jika tidak, peringatan mungkin tidak akan tiba.',
      );
  String get gotIt => _p('Got it', '知道了', 'Faham');
  String pendingReminders(int n) =>
      _p('$n reminders scheduled', '已安排 $n 条提醒', '$n peringatan dijadualkan');
  String deferredReminders(int n) => _p(
        '$n more are queued and will be scheduled as earlier ones fire.',
        '另有 $n 条排队中，将在先前提醒触发后安排。',
        '$n lagi menunggu giliran dan akan dijadualkan kemudian.',
      );

  // -------------------------------------------------------------- whatsapp

  String get whatsappConfirm => _p('Confirm', '确认', 'Sahkan');
  String get whatsappReady =>
      _p('Ready for collection', '可取件', 'Sedia diambil');
  String get whatsappReschedule => _p('Reschedule', '改期', 'Tukar masa');
  String get noWhatsappNumber => _p(
        'This customer has no phone number saved.',
        '此客户没有保存电话号码。',
        'Pelanggan ini tiada nombor telefon disimpan.',
      );
  String get couldNotOpenWhatsapp => _p(
        'Could not open WhatsApp.',
        '无法打开 WhatsApp。',
        'Tidak dapat membuka WhatsApp.',
      );
  String get resetToDefault =>
      _p('Reset to default', '恢复默认', 'Set semula kepada lalai');
  String get placeholders => _p('Placeholders', '占位符', 'Pemegang tempat');

  // ---------------------------------------------------------------- backup

  String get backupExported => _p('Backup exported.', '备份已导出。', 'Sandaran dieksport.');
  String backupImported(int jobs, int customers) => _p(
        'Imported $jobs jobs and $customers customers.',
        '已导入 $jobs 项工作和 $customers 位客户。',
        '$jobs kerja dan $customers pelanggan diimport.',
      );
  String get backupImportFailed => _p(
        'That file could not be read as an AnaCoo backup.',
        '无法将该文件读取为 AnaCoo 备份。',
        'Fail itu tidak dapat dibaca sebagai sandaran AnaCoo.',
      );
  String get importReplacesWarning => _p(
        'Importing replaces everything currently in the app. Continue?',
        '导入将替换应用中的所有现有数据。要继续吗？',
        'Import akan menggantikan semua data semasa. Teruskan?',
      );
}
