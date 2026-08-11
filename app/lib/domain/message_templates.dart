import 'dart:convert';

/// The three WhatsApp reply shortcuts on job detail.
enum TemplateKind {
  confirm,
  ready,
  reschedule;

  String get key => name;
}

/// Placeholders a template may use. Anything else is left untouched, so a stray
/// brace in the tailor's own wording survives round-tripping.
const List<String> templatePlaceholders = [
  '{name}',
  '{date}',
  '{time}',
  '{service}',
  '{price}',
  '{collectDate}',
];

/// Editable reply templates, one set per UI language.
class MessageTemplates {
  const MessageTemplates(this._byLanguage);

  final Map<String, Map<String, String>> _byLanguage;

  static const Map<String, Map<String, String>> _defaults = {
    'en': {
      'confirm':
          'Hi {name}, your appointment with AnaCoo Tailor is confirmed 🙂\n\n'
          '📅 {date}\n⏰ {time}\n🧵 {service}\n\n'
          'R&F Princess Cove, Block A7-1. See you then!',
      'ready':
          'Hi {name}, your {service} is ready for collection ✨\n\n'
          'Total: {price}\n'
          'Pickup: {collectDate}\n\n'
          'We are open daily 11am–10pm. Thank you! 🙏',
      'reschedule':
          'Hi {name}, sorry — I need to move your appointment on {date} at {time}.\n\n'
          'Which other time suits you? We are open daily 11am–10pm.',
    },
    'zh': {
      'confirm':
          '你好 {name}，你在 AnaCoo Tailor 的预约已确认 🙂\n\n'
          '📅 {date}\n⏰ {time}\n🧵 {service}\n\n'
          'R&F Princess Cove，A7-1 座。到时见！',
      'ready':
          '你好 {name}，你的「{service}」已完成，可以来取件了 ✨\n\n'
          '总额：{price}\n'
          '取件日期：{collectDate}\n\n'
          '我们每天 11am–10pm 营业。谢谢！🙏',
      'reschedule':
          '你好 {name}，不好意思，{date} {time} 的预约需要改期。\n\n'
          '请问你哪个时间方便？我们每天 11am–10pm 营业。',
    },
    'ms': {
      'confirm':
          'Hai {name}, temu janji anda dengan AnaCoo Tailor telah disahkan 🙂\n\n'
          '📅 {date}\n⏰ {time}\n🧵 {service}\n\n'
          'R&F Princess Cove, Blok A7-1. Jumpa nanti!',
      'ready':
          'Hai {name}, {service} anda sudah siap untuk diambil ✨\n\n'
          'Jumlah: {price}\n'
          'Tarikh ambil: {collectDate}\n\n'
          'Kami buka setiap hari 11pagi–10malam. Terima kasih! 🙏',
      'reschedule':
          'Hai {name}, maaf — temu janji pada {date} jam {time} perlu ditukar.\n\n'
          'Masa lain yang sesuai untuk anda? Kami buka setiap hari 11pagi–10malam.',
    },
    'vi': {
      'confirm':
          'Chào {name}, lịch hẹn của bạn tại AnaCoo Tailor đã được xác nhận 🙂\n\n'
          '📅 {date}\n⏰ {time}\n🧵 {service}\n\n'
          'R&F Princess Cove, Block A7-1. Hẹn gặp bạn!',
      'ready':
          'Chào {name}, {service} của bạn đã xong, mời bạn đến lấy ✨\n\n'
          'Tổng cộng: {price}\n'
          'Ngày lấy: {collectDate}\n\n'
          'Chúng tôi mở cửa hằng ngày 11 giờ sáng–10 giờ tối. Cảm ơn bạn! 🙏',
      'reschedule':
          'Chào {name}, xin lỗi — tôi cần dời lịch hẹn ngày {date} lúc {time}.\n\n'
          'Bạn rảnh giờ nào khác? Chúng tôi mở cửa hằng ngày 11 giờ sáng–10 giờ tối.',
    },
  };

  static const MessageTemplates defaults = MessageTemplates(_defaults);

  static const List<String> languages = ['en', 'zh', 'ms', 'vi'];

  String bodyFor(TemplateKind kind, String languageCode) {
    final lang = languages.contains(languageCode) ? languageCode : 'en';
    return _byLanguage[lang]?[kind.key] ??
        _defaults[lang]?[kind.key] ??
        _defaults['en']![kind.key]!;
  }

  MessageTemplates withBody(TemplateKind kind, String languageCode, String body) {
    final next = {
      for (final entry in _byLanguage.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    (next[languageCode] ??= <String, String>{})[kind.key] = body;
    return MessageTemplates(next);
  }

  MessageTemplates resetToDefault(TemplateKind kind, String languageCode) =>
      withBody(kind, languageCode, _defaults[languageCode]?[kind.key] ?? '');

  String encode() => jsonEncode(_byLanguage);

  static MessageTemplates decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return defaults;
      final out = <String, Map<String, String>>{};
      for (final lang in languages) {
        final section = decoded[lang];
        final base = Map<String, String>.from(_defaults[lang]!);
        if (section is Map) {
          for (final kind in TemplateKind.values) {
            final body = section[kind.key];
            if (body is String) base[kind.key] = body;
          }
        }
        out[lang] = base;
      }
      return MessageTemplates(out);
    } on FormatException {
      return defaults;
    }
  }

  /// Substitutes placeholders. Missing values collapse to an em dash rather
  /// than leaving a literal `{price}` in a message to a customer.
  static String fill(String template, Map<String, String?> values) {
    var out = template;
    values.forEach((key, value) {
      final text = (value == null || value.trim().isEmpty) ? '—' : value.trim();
      out = out.replaceAll('{$key}', text);
    });
    return out;
  }
}
