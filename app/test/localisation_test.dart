import 'package:anacoo_tailor/data/enums.dart';
import 'package:anacoo_tailor/domain/message_templates.dart';
import 'package:anacoo_tailor/domain/notification_strings.dart';
import 'package:anacoo_tailor/domain/service_labels.dart';
import 'package:anacoo_tailor/domain/shop_time.dart';
import 'package:anacoo_tailor/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// The label tables are plain maps, so a language missing from one of them
/// falls back to English silently — the user just sees the wrong words. These
/// tests are the only thing standing between that and a release, and they walk
/// [AppStrings.supportedLocales] so adding a language cannot skip a table.
void main() {
  final languages =
      AppStrings.supportedLocales.map((locale) => locale.languageCode).toList();

  setUpAll(initShopTime);

  test('Vietnamese is offered alongside the website three', () {
    expect(languages, containsAll(['en', 'zh', 'ms', 'vi']));
    // The language picker and the template editor both key off this list.
    expect(MessageTemplates.languages, languages);
  });

  group('every language has', () {
    test('a label for every service', () {
      for (final language in languages) {
        for (final service in ServiceType.values) {
          expect(
            serviceLabels[service]?[language],
            isNotNull,
            reason: '$language/${service.name}',
          );
        }
      }
    });

    test('a label for every job and appointment status', () {
      for (final language in languages) {
        for (final status in JobStatus.values) {
          expect(jobStatusLabels[status]?[language], isNotNull,
              reason: '$language/${status.name}');
        }
        for (final type in AppointmentType.values) {
          expect(appointmentTypeLabels[type]?[language], isNotNull,
              reason: '$language/${type.name}');
        }
        for (final status in AppointmentStatus.values) {
          expect(appointmentStatusLabels[status]?[language], isNotNull,
              reason: '$language/${status.name}');
        }
      }
    });

    test('notification copy that is filled in and not left in English', () {
      final english = NotificationStrings('en');
      for (final language in languages) {
        final strings = NotificationStrings(language);
        expect(strings.agendaTitle, isNotEmpty, reason: language);
        expect(strings.agendaEmpty, isNotEmpty, reason: language);
        expect(strings.overdueTitle, isNotEmpty, reason: language);
        expect(strings.readyNudgeTitle, isNotEmpty, reason: language);
        expect(strings.agendaBody(2, 1), isNotEmpty, reason: language);
        if (language == 'en') continue;
        expect(strings.agendaTitle, isNot(english.agendaTitle), reason: language);
        expect(strings.overdueTitle, isNot(english.overdueTitle), reason: language);
      }
    });
  });

  group('Vietnamese', () {
    const vi = AppStrings('vi');

    test('translates the tabs and the common actions', () {
      expect(vi.tabToday, 'Hôm nay');
      expect(vi.tabCalendar, 'Lịch');
      expect(vi.tabSettings, 'Cài đặt');
      expect(vi.save, 'Lưu');
      expect(vi.cancel, 'Huỷ');
    });

    test('counts in Vietnamese, which has no plural form', () {
      expect(vi.days(1), '1 ngày');
      expect(vi.days(3), '3 ngày');
      expect(vi.jobCount(1), '1 đơn');
      expect(vi.minutesShort(45), '45 phút');
    });

    test('keeps the interpolated values inside the warnings', () {
      expect(vi.warningBlocked('Tết'), contains('Tết'));
      expect(vi.warningBlocked(null), isNot(contains('null')));
      expect(vi.warningClash(2, true), startsWith('2 '));
      expect(vi.warningClash(2, true), isNot(vi.warningClash(2, false)));
    });

    test('falls back to English for a language nobody speaks here', () {
      const unknown = AppStrings('fr');
      expect(unknown.tabToday, const AppStrings('en').tabToday);
    });

    test('ships WhatsApp templates that still carry their placeholders', () {
      for (final kind in TemplateKind.values) {
        final body = MessageTemplates.defaults.bodyFor(kind, 'vi');
        expect(body, contains('{name}'), reason: kind.name);
        expect(body, isNot(MessageTemplates.defaults.bodyFor(kind, 'en')));
      }
    });
  });
}
