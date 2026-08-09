/// Text tidying shared by every stage of the WhatsApp parser.
///
/// The rule throughout: clean aggressively for *matching*, conservatively for
/// *values*. Emoji are stripped when deciding whether a line is a label, but
/// left alone inside the text the tailor will read back later.
library;

final RegExp _bold = RegExp(r'\*([^*\n]+)\*');
final RegExp _italic = RegExp(r'_([^_\n]+)_');
final RegExp _strike = RegExp(r'~([^~\n]+)~');
final RegExp _monoBlock = RegExp('```');

/// Zero-width joiners/marks, BOM, bidi controls and variation selectors.
final RegExp _invisible = RegExp('[\u200b-\u200f\u202a-\u202e\ufeff\ufe0e\ufe0f]');
/// NBSP, the fixed-width spaces and the CJK ideographic space.
final RegExp _oddSpace = RegExp('[\u00a0\u2000-\u200a\u202f\u205f\u3000]');
/// Characters used for the `───────────────────` rules WhatsApp templates like.
const String _decorativeChars = '-–—―_=*~·•.≡ \t'
    '─━│┃┄┅┈┉╌╍═║╔╗╚╝╠╣╦╩╬┌┐└┘├┤┬┴┼▬▭▮▯';

/// Strips WhatsApp emphasis markers and invisible characters, and blanks out
/// pure decoration lines. Decoration becomes an *empty line* rather than
/// disappearing, because it is what ends a multi-line Notes block.
String cleanMessage(String input) {
  var text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  text = text.replaceAll(_monoBlock, '');
  text = text.replaceAll(_invisible, '');
  text = text.replaceAll(_oddSpace, ' ');

  // Paired emphasis first so `*Date:*` keeps its colon, then any stray marker.
  for (var pass = 0; pass < 2; pass++) {
    text = text.replaceAllMapped(_bold, (m) => m.group(1)!);
    text = text.replaceAllMapped(_italic, (m) => m.group(1)!);
    text = text.replaceAllMapped(_strike, (m) => m.group(1)!);
  }
  text = text.replaceAll('*', '');

  final lines = text.split('\n').map((line) {
    final trimmed = line.trim();
    if (isDecorative(trimmed)) return '';
    return trimmed;
  });
  return lines.join('\n');
}

/// True for separator rules like `───────────────────` or `-----`.
bool isDecorative(String line) {
  if (line.length < 3) return false;
  for (final rune in line.runes) {
    if (!_decorativeChars.contains(String.fromCharCode(rune))) return false;
  }
  return true;
}

final RegExp _leadingNonWord = RegExp(r'^[^\p{L}\p{N}]+', unicode: true);
final RegExp _allEmojiOrSymbols = RegExp(r'^[^\p{L}\p{N}]*$', unicode: true);

/// Drops leading emoji, bullets and whitespace so a label can be matched.
String stripLeadingOrnament(String line) => line.replaceFirst(_leadingNonWord, '');

/// True when a line carries no letters or digits at all.
bool isOrnamentOnly(String line) => _allEmojiOrSymbols.hasMatch(line.trim());

final RegExp _emoji = RegExp(
  r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{1F1E6}-\u{1F1FF}]',
  unicode: true,
);

/// Removes emoji entirely — used for fuzzy matching, never for stored values.
String stripEmoji(String input) => input.replaceAll(_emoji, ' ');

/// Lowercase, emoji-free, punctuation-collapsed form used for fuzzy comparison.
String normaliseForMatching(String input) {
  final noEmoji = stripEmoji(input).toLowerCase();
  final collapsed = noEmoji.replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ');
  return collapsed.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Values that mean "the customer left this blank".
const Set<String> _emptyValueSentinels = {
  '-', '–', '—', '―', '_', '.', '/',
  'n a', 'na', 'nil', 'none', 'null', 'nothing',
  'tiada', 'takde', 'kosong',
  '无', '沒有', '没有', '无备注', '沒有備註',
};

/// Normalises a captured field value, collapsing placeholder dashes to null.
String? valueOrNull(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final probe = normaliseForMatching(trimmed);
  if (probe.isEmpty) return null;
  if (_emptyValueSentinels.contains(probe)) return null;
  return trimmed;
}

/// Stable 64-bit FNV-1a hash. `String.hashCode` is not guaranteed stable across
/// runs, and this value is persisted to recognise already-imported messages.
String fingerprintOf(String input) {
  const int offsetBasis = 0xcbf29ce484222325;
  const int prime = 0x100000001b3;
  var hash = offsetBasis;
  for (final unit in normaliseForMatching(input).codeUnits) {
    hash ^= unit;
    hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
