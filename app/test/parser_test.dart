import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/parser/appointment_request_parser.dart';
import 'package:anacoo_tailor/domain/parser/date_time_parser.dart';
import 'package:anacoo_tailor/domain/parser/service_matcher.dart';
import 'package:anacoo_tailor/domain/parser/text_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';

/// The message the website's WhatsApp button generates, verbatim.
const String sampleMessage = '''
✨ *AnaCoo Tailor — Appointment Request* ✨
───────────────────
Hi AnaCoo Tailor, I'd like to book an appointment 🙂

📅 *Date:* 2026-08-06
⏰ *Time:* 12:00 PM
🧵 *Service:* Pants / jeans shortening
📝 *Notes:* —
👤 *Name:* Siti Aminah
📞 *Phone:* +60123456789
───────────────────
Thank you! 🙏''';

/// A fixed "now" so relative dates are deterministic.
final DateTime today = DateTime(2026, 8, 1);

void main() {
  group('the exact sample message', () {
    test('yields date, time, service, name and phone', () {
      final result = parseAppointmentRequest(sampleMessage, today: today);

      expect(result, isNotNull);
      expect(result!.date, const ParsedDate(2026, 8, 6));
      expect(result.time, const ParsedTime(12, 0));
      expect(result.service?.service, ServiceType.pantsJeansShortening);
      expect(result.notes, isNull);
      expect(result.customerName, 'Siti Aminah');
      expect(result.phone, '+60123456789');
    });

    test('keeps the original text in rawMessage', () {
      final result = parseAppointmentRequest(sampleMessage, today: today);
      expect(result!.rawMessage, sampleMessage);
    });

    test('surfaces the boilerplate it did not understand', () {
      final result = parseAppointmentRequest(sampleMessage, today: today);
      expect(
        result!.unmatchedLines,
        contains(startsWith('AnaCoo Tailor')),
      );
      expect(result.unmatchedLines, contains(startsWith('Thank you')));
    });
  });

  test('parses the same message with all bold markers stripped', () {
    final plain = sampleMessage.replaceAll('*', '');
    final result = parseAppointmentRequest(plain, today: today);

    expect(result, isNotNull);
    expect(result!.date, const ParsedDate(2026, 8, 6));
    expect(result.time, const ParsedTime(12, 0));
    expect(result.service?.service, ServiceType.pantsJeansShortening);
    expect(result.notes, isNull);
  });

  test('parses a message wrapped in italic and strikethrough markers', () {
    final decorated = sampleMessage
        .replaceAll('*Date:*', '_Date:_')
        .replaceAll('*Time:*', '~Time:~');
    final result = parseAppointmentRequest(decorated, today: today);

    expect(result!.date, const ParsedDate(2026, 8, 6));
    expect(result.time, const ParsedTime(12, 0));
  });

  group('times', () {
    test('12.00pm, 1200 and 12:00 PM all read as 12:00', () {
      for (final raw in ['12.00pm', '1200', '12:00 PM']) {
        expect(parseTime(raw), const ParsedTime(12, 0), reason: raw);
      }
    });

    test('accepts 12pm and 14:00', () {
      expect(parseTime('12pm'), const ParsedTime(12, 0));
      expect(parseTime('14:00'), const ParsedTime(14, 0));
    });

    test('midnight and noon do not collide', () {
      expect(parseTime('12:00 AM'), const ParsedTime(0, 0));
      expect(parseTime('12:00 PM'), const ParsedTime(12, 0));
    });

    test('reads Malay and Chinese meridiems', () {
      expect(parseTime('8 malam'), const ParsedTime(20, 0));
      expect(parseTime('11 pagi'), const ParsedTime(11, 0));
      expect(parseTime('下午 3:30'), const ParsedTime(15, 30));
    });

    test('refuses bare digit runs when scanning loose prose', () {
      expect(parseTime('see you in 2026', allowBareDigits: false), isNull);
    });
  });

  group('dates', () {
    test('6/8/2026 is 6 August, never 8 June', () {
      expect(parseDate('6/8/2026', today: today), const ParsedDate(2026, 8, 6));
    });

    test('day-first holds for dashes and dots too', () {
      expect(parseDate('06-08-2026', today: today), const ParsedDate(2026, 8, 6));
      expect(parseDate('6.8.2026', today: today), const ParsedDate(2026, 8, 6));
    });

    test('reads YYYY-MM-DD unambiguously', () {
      expect(parseDate('2026-08-06', today: today), const ParsedDate(2026, 8, 6));
    });

    test('reads D MMM YYYY in English and Malay', () {
      expect(parseDate('6 Aug 2026', today: today), const ParsedDate(2026, 8, 6));
      expect(parseDate('6 August 2026', today: today), const ParsedDate(2026, 8, 6));
      expect(parseDate('6 Ogos 2026', today: today), const ParsedDate(2026, 8, 6));
      expect(parseDate('6 Mac 2026', today: today), const ParsedDate(2026, 3, 6));
    });

    test('reads the Chinese form', () {
      expect(parseDate('2026年8月6日', today: today), const ParsedDate(2026, 8, 6));
    });

    test('reads today, tomorrow and esok', () {
      expect(parseDate('today', today: today), const ParsedDate(2026, 8, 1));
      expect(parseDate('tomorrow', today: today), const ParsedDate(2026, 8, 2));
      expect(parseDate('esok', today: today), const ParsedDate(2026, 8, 2));
      expect(parseDate('明天', today: today), const ParsedDate(2026, 8, 2));
    });

    test('falls back to the current year when none is given', () {
      expect(parseDate('6/8', today: today), const ParsedDate(2026, 8, 6));
    });

    test('rejects impossible dates rather than rolling them over', () {
      expect(parseDate('31/2/2026', today: today), isNull);
    });
  });

  group('notes', () {
    test('placeholder values collapse to null', () {
      for (final raw in ['—', '-', '–', 'n/a', 'nil', '  ', 'tiada', '无']) {
        final message = sampleMessage.replaceAll('📝 *Notes:* —', '📝 *Notes:* $raw');
        final result = parseAppointmentRequest(message, today: today);
        expect(result!.notes, isNull, reason: raw);
      }
    });

    test('multi-line notes keep their line breaks and emoji', () {
      const message = '''
✨ *AnaCoo Tailor — Appointment Request* ✨
───────────────────
📅 *Date:* 2026-08-06
⏰ *Time:* 12:00 PM
🧵 *Service:* Pants / jeans shortening
📝 *Notes:* Please hem to 30 inches 🙏
Same as last time 👖
Rush if possible 🔥
───────────────────
Thank you! 🙏''';

      final result = parseAppointmentRequest(message, today: today);

      expect(
        result!.notes,
        'Please hem to 30 inches 🙏\nSame as last time 👖\nRush if possible 🔥',
      );
      expect(result.date, const ParsedDate(2026, 8, 6));
      expect(result.service?.service, ServiceType.pantsJeansShortening);
    });
  });

  group('garbage', () {
    test('unparseable text returns null so the manual form opens', () {
      const junk = 'asdkjh qwe zxcv ;;; ????';
      expect(parseAppointmentRequest(junk, today: today), isNull);
    });

    test('ordinary chatter is not mistaken for a request', () {
      expect(
        parseAppointmentRequest('Hi, are you open today? Thanks!', today: today),
        isNull,
      );
    });

    test('empty and whitespace input return null', () {
      expect(parseAppointmentRequest('', today: today), isNull);
      expect(parseAppointmentRequest('   \n  \n ', today: today), isNull);
    });
  });

  group('the other two languages', () {
    test('reads Bahasa Melayu labels', () {
      const message = '''
✨ AnaCoo Tailor — Permintaan Temu Janji ✨
───────────────────
📅 Tarikh: 6/8/2026
⏰ Masa: 12:00 PM
🧵 Perkhidmatan: Pendekkan seluar / jeans
📝 Nota: —
───────────────────''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.date, const ParsedDate(2026, 8, 6));
      expect(result.time, const ParsedTime(12, 0));
      expect(result.service?.service, ServiceType.pantsJeansShortening);
      expect(result.notes, isNull);
    });

    test('reads Chinese labels', () {
      const message = '''
✨ AnaCoo Tailor — 预约请求 ✨
───────────────────
📅 日期：2026-08-06
⏰ 时间：12:00 PM
🧵 服务：裤子 / 牛仔裤缩短
📝 备注：—
───────────────────''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.date, const ParsedDate(2026, 8, 6));
      expect(result.time, const ParsedTime(12, 0));
      expect(result.service?.service, ServiceType.pantsJeansShortening);
      expect(result.notes, isNull);
    });
  });

  group('service matching', () {
    test('maps every website option label in all three languages', () {
      const expectations = <String, ServiceType>{
        'Basic alterations': ServiceType.basicAlterations,
        '日常服装修改': ServiceType.basicAlterations,
        'Ubah suai asas': ServiceType.basicAlterations,
        'Pants / jeans shortening': ServiceType.pantsJeansShortening,
        '裤子 / 牛仔裤缩短': ServiceType.pantsJeansShortening,
        'Pendekkan seluar / jeans': ServiceType.pantsJeansShortening,
        'Waist / size adjustment': ServiceType.waistSizeAdjustment,
        '腰围 / 尺寸调整': ServiceType.waistSizeAdjustment,
        'Pelarasan pinggang / saiz': ServiceType.waistSizeAdjustment,
        'Repair / zip / button': ServiceType.repairZipButton,
        '修补 / 拉链 / 纽扣': ServiceType.repairZipButton,
        'Baiki / zip / butang': ServiceType.repairZipButton,
        'Curtains / bedsheets': ServiceType.curtainsBedsheets,
        '窗帘 / 床单': ServiceType.curtainsBedsheets,
        'Langsir / cadar': ServiceType.curtainsBedsheets,
        'Other (tell us in notes)': ServiceType.other,
      };
      expectations.forEach((raw, expected) {
        expect(matchService(raw).service, expected, reason: raw);
      });
    });

    test('maps loose free text when the evidence is strong', () {
      expect(matchService('shorten my jeans please').service,
          ServiceType.pantsJeansShortening);
      expect(matchService('broken zip').service, ServiceType.repairZipButton);
      expect(matchService('curtain too long').service,
          ServiceType.curtainsBedsheets);
    });

    test('leaves the field empty rather than guessing wrong', () {
      final match = matchService('wedding gown beading');
      expect(match.matched, isFalse);
      expect(match.rawText, 'wedding gown beading');
    });

    test('an unmatched service still parses, flagged for the chip', () {
      final message =
          sampleMessage.replaceAll('Pants / jeans shortening', 'wedding gown beading');
      final result = parseAppointmentRequest(message, today: today);

      expect(result, isNotNull);
      expect(result!.service!.matched, isFalse);
      expect(result.hasUnmatchedService, isTrue);
      expect(result.service!.rawText, 'wedding gown beading');
      expect(result.date, const ParsedDate(2026, 8, 6));
    });
  });

  group('name and phone', () {
    test('are read when a forwarded message happens to carry them', () {
      const message = '''
📅 Date: 6/8/2026
⏰ Time: 12:00 PM
🧵 Service: Basic alterations
👤 Name: Siti Aminah
📞 Phone: +60123456789''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.customerName, 'Siti Aminah');
      expect(result.phone, '+60123456789');
    });
  });

  group('resilience', () {
    test('labels work without colons or emoji', () {
      const message = '''
Date 6/8/2026
Time 12:00 PM
Service Basic alterations''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.date, const ParsedDate(2026, 8, 6));
      expect(result.time, const ParsedTime(12, 0));
      expect(result.service?.service, ServiceType.basicAlterations);
    });

    test('a value on the line below its label is still captured', () {
      const message = '''
Date:
6/8/2026
Time:
12:00 PM''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.date, const ParsedDate(2026, 8, 6));
      expect(result.time, const ParsedTime(12, 0));
    });

    test('an unreadable labelled value is surfaced, not swallowed', () {
      const message = '''
📅 Date: sometime next week lah
⏰ Time: 12:00 PM
🧵 Service: Basic alterations''';

      final result = parseAppointmentRequest(message, today: today);
      expect(result!.date, isNull);
      expect(result.unmatchedLines, contains('sometime next week lah'));
      expect(result.time, const ParsedTime(12, 0));
    });

    test('a bare "tomorrow 3pm" is enough to count as a request', () {
      final result = parseAppointmentRequest('tomorrow 3pm', today: today);
      expect(result, isNotNull);
      expect(result!.date, const ParsedDate(2026, 8, 2));
      expect(result.time, const ParsedTime(15, 0));
    });

    test('fingerprints are stable and ignore formatting noise', () {
      final a = fingerprintOf(sampleMessage);
      final b = fingerprintOf(sampleMessage.replaceAll('*', ''));
      expect(a, b);
      expect(a, isNot(fingerprintOf('something else entirely')));
    });
  });
}
