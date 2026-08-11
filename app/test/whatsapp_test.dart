import 'package:anacoo_tailor/domain/message_templates.dart';
import 'package:anacoo_tailor/services/whatsapp_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone normalisation', () {
    test('reads the shop\'s own number in every form it gets written', () {
      const expected = '60123608968';
      for (final raw in [
        '+60123608968',
        '60123608968',
        '0123608968',
        '012-360 8968',
        '+60 12 360 8968',
        '(012) 3608968',
        '0060123608968',
      ]) {
        expect(WhatsAppLauncher.normalisePhone(raw), expected, reason: raw);
      }
    });

    test('keeps Singapore numbers on +65', () {
      expect(WhatsAppLauncher.normalisePhone('+6591234567'), '6591234567');
      expect(WhatsAppLauncher.normalisePhone('91234567'), '6591234567');
      expect(
        WhatsAppLauncher.normalisePhone('91234567', defaultCountry: 'SG'),
        '6591234567',
      );
    });

    test('rejects text with no usable number', () {
      expect(WhatsAppLauncher.normalisePhone(null), isNull);
      expect(WhatsAppLauncher.normalisePhone(''), isNull);
      expect(WhatsAppLauncher.normalisePhone('call me maybe'), isNull);
      expect(WhatsAppLauncher.normalisePhone('123'), isNull);
    });
  });

  group('wa.me links', () {
    test('encode newlines as %0A and leave emoji intact', () {
      final uri = WhatsAppLauncher.buildLink(
        phone: '0123608968',
        message: 'Hi Siti 🙂\nSee you at 12:00 PM',
      );

      expect(uri, isNotNull);
      expect(uri!.toString(), startsWith('https://wa.me/60123608968?text='));
      expect(uri.toString(), contains('%0A'));
      // Spaces must be percent-encoded, never turned into '+'.
      expect(uri.toString(), isNot(contains('+')));
      expect(Uri.decodeComponent(uri.query.substring('text='.length)),
          'Hi Siti 🙂\nSee you at 12:00 PM');
    });

    test('return null rather than a broken link when there is no number', () {
      expect(
        WhatsAppLauncher.buildLink(phone: null, message: 'hello'),
        isNull,
      );
    });
  });

  group('message templates', () {
    test('ship a full set for every language', () {
      for (final language in MessageTemplates.languages) {
        for (final kind in TemplateKind.values) {
          expect(
            MessageTemplates.defaults.bodyFor(kind, language),
            isNotEmpty,
            reason: '$language/$kind',
          );
        }
      }
    });

    test('fill every placeholder they use', () {
      final filled = MessageTemplates.fill(
        MessageTemplates.defaults.bodyFor(TemplateKind.ready, 'en'),
        {
          'name': 'Siti',
          'service': 'Pants / jeans shortening',
          'price': 'RM 25.00',
          'collectDate': 'Sun, 9 Aug 2026',
          'date': null,
          'time': null,
        },
      );
      expect(filled, contains('Siti'));
      expect(filled, contains('RM 25.00'));
      expect(filled, isNot(contains('{')));
    });

    test('collapse missing values to an em dash, never a raw placeholder', () {
      final filled = MessageTemplates.fill('Total: {price}', {'price': null});
      expect(filled, 'Total: —');
    });

    test('survive an encode/decode round trip with an edit', () {
      final edited = MessageTemplates.defaults
          .withBody(TemplateKind.confirm, 'ms', 'Hai {name}, ok!');
      final decoded = MessageTemplates.decode(edited.encode());

      expect(decoded.bodyFor(TemplateKind.confirm, 'ms'), 'Hai {name}, ok!');
      // Untouched entries keep their defaults.
      expect(
        decoded.bodyFor(TemplateKind.ready, 'ms'),
        MessageTemplates.defaults.bodyFor(TemplateKind.ready, 'ms'),
      );
    });

    test('fall back to defaults on corrupt stored data', () {
      expect(
        MessageTemplates.decode('{not json').bodyFor(TemplateKind.confirm, 'en'),
        MessageTemplates.defaults.bodyFor(TemplateKind.confirm, 'en'),
      );
    });

    test('reset one template without disturbing the others', () {
      final edited = MessageTemplates.defaults
          .withBody(TemplateKind.confirm, 'en', 'custom')
          .withBody(TemplateKind.ready, 'en', 'also custom');
      final reset = edited.resetToDefault(TemplateKind.confirm, 'en');

      expect(
        reset.bodyFor(TemplateKind.confirm, 'en'),
        MessageTemplates.defaults.bodyFor(TemplateKind.confirm, 'en'),
      );
      expect(reset.bodyFor(TemplateKind.ready, 'en'), 'also custom');
    });
  });
}
