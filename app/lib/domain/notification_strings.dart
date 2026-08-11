import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/enums.dart';
import 'service_labels.dart';

/// Copy for scheduled notifications, in every UI language.
///
/// Kept out of the ARB bundles on purpose: notification bodies are composed
/// while planning a schedule, which happens off the widget tree (including at
/// app start before any `BuildContext` exists) and must not depend on one.
class NotificationStrings {
  const NotificationStrings(this.languageCode);

  final String languageCode;

  String get _lang =>
      const {'en', 'zh', 'ms', 'vi'}.contains(languageCode) ? languageCode : 'en';

  String _pick(String en, String zh, String ms, String vi) =>
      switch (_lang) { 'zh' => zh, 'ms' => ms, 'vi' => vi, _ => en };

  String timeLabel(tz.TZDateTime at) => DateFormat.jm(_intlLocale).format(at);

  String dateLabel(tz.TZDateTime at) => DateFormat.yMMMEd(_intlLocale).format(at);

  String shortDateLabel(tz.TZDateTime at) => DateFormat.MMMd(_intlLocale).format(at);

  String get _intlLocale =>
      switch (_lang) { 'zh' => 'zh', 'ms' => 'ms', 'vi' => 'vi', _ => 'en' };

  // -------------------------------------------------------------- reminders

  String reminderTitle(AppointmentType type) => switch (type) {
        AppointmentType.dropOff => _pick(
            'Drop-off coming up',
            '即将送件',
            'Penghantaran akan tiba',
            'Sắp tới giờ gửi đồ',
          ),
        AppointmentType.collection => _pick(
            'Collection coming up',
            '即将取件',
            'Pengambilan akan tiba',
            'Sắp tới giờ lấy đồ',
          ),
      };

  String reminderBody({
    required String customerName,
    required ServiceType service,
    required String? serviceFreeText,
    required tz.TZDateTime at,
    required bool isRush,
  }) {
    final service0 = serviceLabel(service, _lang, freeText: serviceFreeText);
    final when = '${shortDateLabel(at)}, ${timeLabel(at)}';
    final rush = isRush ? _pick(' (rush)', '（加急）', ' (segera)', ' (gấp)') : '';
    return _pick(
      '$customerName · $service0$rush\n$when',
      '$customerName · $service0$rush\n$when',
      '$customerName · $service0$rush\n$when',
      '$customerName · $service0$rush\n$when',
    );
  }

  // ----------------------------------------------------------- daily agenda

  String get agendaTitle => _pick(
        "Today's schedule",
        '今日安排',
        'Jadual hari ini',
        'Lịch hôm nay',
      );

  /// "Today: 3 drop-offs, 2 collections."
  String agendaBody(int dropOffs, int collections) {
    final en = StringBuffer('Today: ');
    en.write('$dropOffs ${dropOffs == 1 ? 'drop-off' : 'drop-offs'}');
    en.write(', $collections ${collections == 1 ? 'collection' : 'collections'}.');
    return _pick(
      en.toString(),
      '今天：$dropOffs 件送件，$collections 件取件。',
      'Hari ini: $dropOffs penghantaran, $collections pengambilan.',
      'Hôm nay: $dropOffs lượt gửi, $collections lượt lấy.',
    );
  }

  String get agendaEmpty => _pick(
        'Today: nothing booked.',
        '今天：没有预约。',
        'Hari ini: tiada tempahan.',
        'Hôm nay: không có lịch hẹn.',
      );

  // --------------------------------------------------------------- overdue

  String get overdueTitle => _pick(
        'Collection overdue',
        '取件逾期',
        'Pengambilan tertunggak',
        'Quá hạn lấy đồ',
      );

  String overdueBody({
    required String customerName,
    required tz.TZDateTime dueAt,
    required int daysLate,
  }) =>
      _pick(
        '$customerName was due ${shortDateLabel(dueAt)} — '
            '$daysLate ${daysLate == 1 ? 'day' : 'days'} ago.',
        '$customerName 原定 ${shortDateLabel(dueAt)} 取件，已逾期 $daysLate 天。',
        '$customerName sepatutnya ambil pada ${shortDateLabel(dueAt)} — '
            '$daysLate hari lalu.',
        '$customerName hẹn lấy ngày ${shortDateLabel(dueAt)} — '
            'đã quá $daysLate ngày.',
      );

  // ----------------------------------------------------------- ready nudge

  String get readyNudgeTitle => _pick(
        'Still waiting for pickup',
        '仍未取件',
        'Masih menunggu diambil',
        'Vẫn chưa có ai đến lấy',
      );

  String readyNudgeBody({required String customerName, required int days}) => _pick(
        "$customerName's order has been ready for "
            '$days ${days == 1 ? 'day' : 'days'}.',
        '$customerName 的订单已完成 $days 天，尚未取件。',
        'Pesanan $customerName telah siap selama $days hari.',
        'Đơn của $customerName đã xong được $days ngày.',
      );
}
