import 'date_time_parser.dart';
import 'service_matcher.dart';
import 'text_cleaner.dart';

enum RequestField { date, time, service, notes, name, phone }

/// What the parser managed to pull out of a pasted WhatsApp message.
///
/// Nothing is thrown away: [rawMessage] always holds the original text, and
/// [unmatchedLines] lists the lines that did not map to a field, so the import
/// screen can show them instead of pretending they never existed.
class ParsedRequest {
  const ParsedRequest({
    required this.rawMessage,
    required this.recognisedLabels,
    required this.unmatchedLines,
    this.date,
    this.time,
    this.service,
    this.notes,
    this.customerName,
    this.phone,
  });

  final String rawMessage;
  final Set<RequestField> recognisedLabels;
  final List<String> unmatchedLines;

  final ParsedDate? date;
  final ParsedTime? time;

  /// Always present when a Service line was found, even when it did not match —
  /// [ServiceMatch.rawText] then drives the "couldn't match" chip.
  final ServiceMatch? service;
  final String? notes;
  final String? customerName;
  final String? phone;

  String get fingerprint => fingerprintOf(rawMessage);

  /// The message named a service but the matcher would have had to guess.
  bool get hasUnmatchedService =>
      service != null && !service!.matched && service!.rawText.isNotEmpty;

  int get filledFieldCount => [
        date,
        time,
        service?.service,
        notes,
        customerName,
        phone,
      ].where((v) => v != null).length;
}

const Map<RequestField, List<String>> _labelWords = {
  RequestField.date: ['date', 'tarikh', '日期', 'ngày', 'ngay'],
  RequestField.time: [
    'time', 'masa', 'jam', 'pukul', '时间', '時間',
    'giờ', 'gio', 'lúc', 'thời gian', 'thoi gian',
  ],
  RequestField.service: [
    'service', 'servis', 'perkhidmatan', '服务', '服務', 'dịch vụ', 'dich vu',
  ],
  RequestField.notes: [
    'notes', 'note', 'nota', 'catatan', 'remark', 'remarks', '备注', '備註',
    'ghi chú', 'ghi chu', 'lưu ý', 'luu y',
  ],
  RequestField.name: ['name', 'nama', '姓名', '名字', 'tên', 'họ tên', 'ho ten'],
  RequestField.phone: [
    'phone', 'phone no', 'phone number', 'tel', 'telephone', 'telefon',
    'no telefon', 'mobile', 'hp', 'contact', 'whatsapp', '电话', '電話',
    'điện thoại', 'dien thoai', 'số điện thoại', 'so dien thoai', 'sđt', 'sdt',
  ],
};

final Map<RequestField, RegExp> _labelPatterns = {
  for (final entry in _labelWords.entries)
    entry.key: _buildLabelPattern(entry.value),
};

RegExp _buildLabelPattern(List<String> words) {
  final sorted = [...words]..sort((a, b) => b.length.compareTo(a.length));
  final alternation = sorted.map(RegExp.escape).join('|');
  return RegExp(
    r'^(?:' + alternation + r')(?![\p{L}\p{N}])\s*[:：\-–—]?\s*(.*)$',
    caseSensitive: false,
    unicode: true,
  );
}

/// Parses a pasted appointment request.
///
/// Returns null when the text carries no appointment shape at all — the caller
/// then opens the manual New Job form with the raw text dropped into notes,
/// which is the one behaviour the spec insists on for unparseable input.
ParsedRequest? parseAppointmentRequest(String raw, {DateTime? today}) {
  if (raw.trim().isEmpty) return null;
  final now = today ?? DateTime.now();

  final cleaned = cleanMessage(raw);
  final lines = cleaned.split('\n');

  final captured = <RequestField, StringBuffer>{};
  final unmatched = <String>[];
  RequestField? current;

  for (final line in lines) {
    if (line.trim().isEmpty) {
      current = null;
      continue;
    }
    final probe = stripLeadingOrnament(line).trim();
    if (probe.isEmpty) {
      current = null;
      continue;
    }

    final label = _matchLabel(probe);
    if (label != null) {
      current = label.field;
      final buffer = captured.putIfAbsent(label.field, StringBuffer.new);
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(label.value);
      continue;
    }

    if (current != null) {
      final buffer = captured[current]!;
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(probe);
      continue;
    }

    unmatched.add(probe);
  }

  final recognised = captured.keys.toSet();

  final dateRaw = valueOrNull(captured[RequestField.date]?.toString());
  final timeRaw = valueOrNull(captured[RequestField.time]?.toString());
  final serviceRaw = valueOrNull(captured[RequestField.service]?.toString());
  final notes = valueOrNull(captured[RequestField.notes]?.toString());
  final name = valueOrNull(captured[RequestField.name]?.toString());
  final phone = valueOrNull(captured[RequestField.phone]?.toString());

  var date = dateRaw == null ? null : parseDate(dateRaw, today: now);
  var time = timeRaw == null ? null : parseTime(timeRaw);

  // A labelled value we could not read is itself information — keep it visible.
  if (dateRaw != null && date == null) unmatched.add(dateRaw);
  if (timeRaw != null && time == null) unmatched.add(timeRaw);

  // Nothing labelled? Try the whole message. Bare four-digit runs are refused
  // here: in loose prose "2026" is a year far more often than 20:26.
  if (date == null && !recognised.contains(RequestField.date)) {
    date = parseDate(cleaned, today: now);
  }
  if (time == null && !recognised.contains(RequestField.time)) {
    time = parseTime(cleaned, allowBareDigits: false);
  }

  final service = serviceRaw == null ? null : matchService(serviceRaw);

  final result = ParsedRequest(
    rawMessage: raw,
    recognisedLabels: recognised,
    unmatchedLines: unmatched,
    date: date,
    time: time,
    service: service,
    notes: notes,
    customerName: name,
    phone: phone,
  );

  if (!_isUsable(result)) return null;
  return result;
}

/// Enough signal to call this an appointment request rather than chatter.
bool _isUsable(ParsedRequest r) {
  if (r.date != null && r.time != null) return true;
  if (r.recognisedLabels.length >= 2) return true;
  if (r.recognisedLabels.isNotEmpty && r.filledFieldCount >= 1) return true;
  return false;
}

class _LabelHit {
  const _LabelHit(this.field, this.value);

  final RequestField field;
  final String value;
}

_LabelHit? _matchLabel(String line) {
  for (final entry in _labelPatterns.entries) {
    final match = entry.value.firstMatch(line);
    if (match != null) {
      return _LabelHit(entry.key, match.group(1)?.trim() ?? '');
    }
  }
  return null;
}
