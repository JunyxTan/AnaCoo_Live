import 'package:url_launcher/url_launcher.dart';

/// Phone normalisation and `wa.me` link building.
///
/// Malaysian and Singaporean numbers get written half a dozen different ways in
/// practice (`012-360 8968`, `+60 12 360 8968`, `0123608968`); `wa.me` accepts
/// exactly one of them, so everything is normalised to bare E.164 digits.
class WhatsAppLauncher {
  const WhatsAppLauncher();

  /// Returns E.164 digits without the leading `+`, or null when [raw] has no
  /// plausible number in it.
  static String? normalisePhone(String? raw, {String defaultCountry = 'MY'}) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final hadPlus = trimmed.startsWith('+') || trimmed.startsWith('00');
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (trimmed.startsWith('00')) digits = digits.substring(2);

    if (hadPlus) return digits.length >= 8 ? digits : null;

    // Already carries a country code.
    if (digits.startsWith('60') && digits.length >= 11) return digits;
    if (digits.startsWith('65') && digits.length == 10) return digits;

    if (digits.startsWith('0')) {
      final national = digits.substring(1);
      if (national.length < 8) return null;
      return defaultCountry == 'SG' ? '65$national' : '60$national';
    }

    // Bare Singapore mobile: eight digits starting 8 or 9.
    if (digits.length == 8 && (digits.startsWith('8') || digits.startsWith('9'))) {
      return '65$digits';
    }
    // Bare Malaysian mobile without its trunk zero.
    if (digits.startsWith('1') && digits.length >= 9 && digits.length <= 10) {
      return '60$digits';
    }
    return digits.length >= 8 ? digits : null;
  }

  /// Formats a number for display, keeping the `+`.
  static String? formatForDisplay(String? raw) {
    final digits = normalisePhone(raw);
    if (digits == null) return raw;
    return '+$digits';
  }

  /// Builds a `wa.me` deep link.
  ///
  /// `Uri.encodeComponent` is the right encoder here: it turns newlines into
  /// `%0A` and percent-encodes emoji as UTF-8, which is exactly what WhatsApp
  /// expects. Building the query with `Uri(queryParameters:)` would encode
  /// spaces as `+` and mangle the message.
  static Uri? buildLink({required String? phone, required String message}) {
    final digits = normalisePhone(phone);
    if (digits == null) return null;
    return Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
  }

  /// Opens WhatsApp. Returns false when there is no number or nothing on the
  /// device can handle the link.
  Future<bool> send({required String? phone, required String message}) async {
    final uri = buildLink(phone: phone, message: message);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
