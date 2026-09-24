/// A base text direction.
enum BidiDirection {
  /// Left to right.
  ltr,

  /// Right to left.
  rtl,
}

/// Unicode bidirectional formatting characters.
abstract final class BidiChars {
  /// LEFT-TO-RIGHT MARK, U+200E.
  static const String lrm = '\u200E';

  /// RIGHT-TO-LEFT MARK, U+200F.
  static const String rlm = '\u200F';

  /// ARABIC LETTER MARK, U+061C.
  static const String alm = '\u061C';

  /// LEFT-TO-RIGHT ISOLATE, U+2066.
  static const String lri = '\u2066';

  /// RIGHT-TO-LEFT ISOLATE, U+2067.
  static const String rli = '\u2067';

  /// FIRST STRONG ISOLATE, U+2068.
  static const String fsi = '\u2068';

  /// POP DIRECTIONAL ISOLATE, U+2069.
  static const String pdi = '\u2069';

  /// LEFT-TO-RIGHT EMBEDDING, U+202A (legacy; prefer [lri]).
  static const String lre = '\u202A';

  /// RIGHT-TO-LEFT EMBEDDING, U+202B (legacy; prefer [rli]).
  static const String rle = '\u202B';

  /// POP DIRECTIONAL FORMATTING, U+202C.
  static const String pdf = '\u202C';

  /// LEFT-TO-RIGHT OVERRIDE, U+202D.
  static const String lro = '\u202D';

  /// RIGHT-TO-LEFT OVERRIDE, U+202E.
  static const String rlo = '\u202E';
}

final RegExp _arabicLetter =
    RegExp(r'(?=\p{Script=Arabic})\p{L}', unicode: true);
final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _rtlLetter = RegExp(
  r'(?=[\p{Script=Arabic}\p{Script=Hebrew}\p{Script=Syriac}'
  r'\p{Script=Thaana}\p{Script=Nko}\p{Script=Samaritan}'
  r'\p{Script=Mandaic}\p{Script=Adlam}\p{Script=Hanifi_Rohingya}'
  r'\p{Script=Yezidi}])\p{L}',
  unicode: true,
);
final RegExp _bidiControls = RegExp('[\u200E\u200F\u061C\u202A-\u202E\u2066-\u2069]');

/// Whether [text] contains at least one Arabic-script letter (including
/// Persian/Urdu letters and presentation forms). Digits do not count.
bool containsArabic(String text) => _arabicLetter.hasMatch(text);

/// Whether [text] has at least one letter and every letter is Arabic script.
/// Digits, whitespace, punctuation and diacritics are ignored.
bool isArabic(String text) {
  var arabic = 0;
  for (final m in _letter.allMatches(text)) {
    if (!_arabicLetter.hasMatch(m[0]!)) return false;
    arabic++;
  }
  return arabic > 0;
}

/// The share (0.0-1.0) of letters in [text] that are Arabic script. Returns
/// 0.0 when there are no letters. Digits, spaces and marks are not letters.
double arabicRatio(String text) {
  var letters = 0;
  var arabic = 0;
  for (final m in _letter.allMatches(text)) {
    letters++;
    if (_arabicLetter.hasMatch(m[0]!)) arabic++;
  }
  return letters == 0 ? 0.0 : arabic / letters;
}

/// Detects the base direction of [text] from its first strong character,
/// as in rules P2-P3 of the Unicode Bidirectional Algorithm (UAX #9).
///
/// Letters of right-to-left scripts (Arabic, Hebrew, Syriac, Thaana, ...)
/// and RLM/ALM give [BidiDirection.rtl]; other letters and LRM give
/// [BidiDirection.ltr]. Digits and punctuation are skipped, as is text
/// inside isolates (LRI/RLI/FSI ... PDI). Returns [fallback] when there is
/// no strong character.
BidiDirection detectDirection(
  String text, {
  BidiDirection fallback = BidiDirection.ltr,
}) {
  var isolateDepth = 0;
  for (final rune in text.runes) {
    if (rune >= 0x2066 && rune <= 0x2068) {
      isolateDepth++;
      continue;
    }
    if (rune == 0x2069) {
      if (isolateDepth > 0) isolateDepth--;
      continue;
    }
    if (isolateDepth > 0) continue;
    if (rune == 0x200F || rune == 0x061C) return BidiDirection.rtl;
    if (rune == 0x200E) return BidiDirection.ltr;
    final char = String.fromCharCode(rune);
    if (_rtlLetter.hasMatch(char)) return BidiDirection.rtl;
    if (_letter.hasMatch(char)) return BidiDirection.ltr;
  }
  return fallback;
}

/// Wraps [text] in a bidi isolate so it cannot reorder the text around it.
///
/// Without [direction], uses FIRST STRONG ISOLATE (FSI ... PDI), which lets
/// the text pick its own direction; with one, uses RLI or LRI. Useful when
/// inserting user names or numbers into a sentence of the other direction.
String isolate(String text, {BidiDirection? direction}) {
  final open = switch (direction) {
    null => BidiChars.fsi,
    BidiDirection.rtl => BidiChars.rli,
    BidiDirection.ltr => BidiChars.lri,
  };
  return '$open$text${BidiChars.pdi}';
}

/// Surrounds [text] with RLM (for [BidiDirection.rtl]) or LRM marks, which
/// anchors neutral characters at its edges (punctuation, digits) to that
/// direction. Use it where isolates are not supported.
String embedWithMarks(String text, BidiDirection direction) {
  final mark = direction == BidiDirection.rtl ? BidiChars.rlm : BidiChars.lrm;
  return '$mark$text$mark';
}

/// Removes all bidi marks, embeddings, overrides and isolates from [text].
String stripBidiControls(String text) => text.replaceAll(_bidiControls, '');
