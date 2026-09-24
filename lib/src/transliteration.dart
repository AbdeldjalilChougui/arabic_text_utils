import 'diacritics.dart';
import 'digits.dart';
import 'direction.dart';

/// Output style of [transliterate].
enum TransliterationMode {
  /// Lowercase ASCII words joined by hyphens, safe for URLs (see [slugify]).
  slug,

  /// Approximate, human-readable Latin text that keeps spaces, punctuation
  /// and non-Arabic text, and uses short vowels when diacritics are present.
  readable,
}

// Base consonant map shared by both modes.
const Map<String, String> _letters = {
  'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'h', 'خ': 'kh', 'د': 'd', //
  'ذ': 'dh', 'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh', 'ص': 's', 'ض': 'd',
  'ط': 't', 'ظ': 'z', 'غ': 'gh', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l',
  'م': 'm', 'ن': 'n', 'ه': 'h', 'و': 'w', 'ي': 'y',
  // Letters used in Persian, Urdu and Maghrebi writing.
  'پ': 'p', 'چ': 'ch', 'ژ': 'zh', 'گ': 'g', 'ڤ': 'v', 'ڥ': 'v', 'ڨ': 'g',
  'ک': 'k', 'ی': 'y',
};

// Letters that behave as vowels or hamza carriers rather than consonants.
const Map<String, String> _slugVowels = {
  'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'a', 'ٱ': 'a', 'ى': 'a', 'ة': 'a', //
  'ء': 'a', 'ؤ': 'u', 'ئ': 'i', 'ع': 'a',
};

const String _sunLetters = 'تثدذرزسشصضطظلن';

const Map<String, String> _latinFold = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ç': 'c', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i', 'î': 'i',
  'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe',
  'æ': 'ae', 'ß': 'ss',
};

const Map<String, String> _punctuation = {
  '،': ',', '؛': ';', '؟': '?', '٪': '%', '۔': '.', //
};

final RegExp _arabicWord = RegExp('[ء-يٮ-ۓە-ۿ]+');

bool _isArabicLetter(String ch) =>
    _letters.containsKey(ch) || _slugVowels.containsKey(ch);

bool _isConsonant(String? ch) => ch != null && _letters.containsKey(ch);

/// Turns [input] into a URL-safe slug: lowercase ASCII letters and digits
/// joined by single hyphens.
///
/// Arabic is transliterated letter by letter (no vowels are guessed), the
/// article ال becomes `al-`, diacritics and tatweel are dropped, Arabic and
/// Persian digits become Western digits, and common accented Latin letters
/// are folded (é to e). Returns an empty string when nothing is left.
///
/// ```dart
/// slugify('مطعم الأصالة'); // mtaam-al-asala
/// ```
///
/// The result is an approximation meant for identifiers, not a standard
/// romanization, and it cannot be turned back into Arabic.
String slugify(String input) {
  var text = stripBidiControls(input);
  text = toWesternDigits(removeDiacritics(text, removeTatweel: true));
  text = text.toLowerCase();
  text = text.replaceAllMapped(_arabicWord, (m) => ' ${_slugWord(m[0]!)} ');
  final folded = StringBuffer();
  for (final ch in text.split('')) {
    folded.write(_latinFold[ch] ?? ch);
  }
  return folded
      .toString()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

String _slugWord(String word) {
  final chars = word.split('');
  final out = StringBuffer();
  var start = 0;
  if (chars.length > 3 &&
      (chars[0] == 'ا' || chars[0] == 'ٱ') &&
      chars[1] == 'ل') {
    out.write('al-');
    start = 2;
  }
  for (var i = start; i < chars.length; i++) {
    final ch = chars[i];
    if (ch == 'ع') {
      // Between two consonants ع carries a vowel on each side (مطعم).
      final prev = i > start ? chars[i - 1] : null;
      final next = i + 1 < chars.length ? chars[i + 1] : null;
      out.write(_isConsonant(prev) && _isConsonant(next) ? 'aa' : 'a');
      continue;
    }
    out.write(_letters[ch] ?? _slugVowels[ch] ?? '');
  }
  return out.toString();
}

/// Transliterates Arabic in [input] to Latin letters.
///
/// [TransliterationMode.slug] returns the same as [slugify].
/// [TransliterationMode.readable] (the default) keeps spacing, punctuation
/// and non-Arabic text; it uses the short vowels written as diacritics
/// (مُحَمَّد gives `muhammad`), doubles letters with a shadda, writes
/// ع and a medial hamza as an apostrophe and assimilates the article before
/// sun letters (الشَّمْس gives `ash-shams`).
///
/// Arabic script does not write short vowels, so text without diacritics
/// comes out without them (مرحبا gives `mrhba`). The output is an
/// approximation for display and search-engine friendliness, not a
/// standard romanization such as ALA-LC or ISO 233.
String transliterate(
  String input, {
  TransliterationMode mode = TransliterationMode.readable,
}) {
  if (mode == TransliterationMode.slug) return slugify(input);
  var text = removeTatweel(stripBidiControls(input));
  text = toWesternDigits(text);
  final out = StringBuffer();
  final wordPattern = RegExp('[ء-ٟٮ-ۓە-ۿٰ]+');
  var last = 0;
  for (final m in wordPattern.allMatches(text)) {
    out.write(_mapPunctuation(text.substring(last, m.start)));
    out.write(_readableWord(m[0]!));
    last = m.end;
  }
  out.write(_mapPunctuation(text.substring(last)));
  return out.toString();
}

String _mapPunctuation(String s) {
  final out = StringBuffer();
  for (final ch in s.split('')) {
    out.write(_punctuation[ch] ?? ch);
  }
  return out.toString();
}

class _Unit {
  _Unit(this.letter);

  final String letter;
  String vowel = '';
  bool shadda = false;
  bool hasMark = false;
}

String _readableWord(String word) {
  // Group each letter with the marks that follow it.
  final units = <_Unit>[];
  for (final ch in word.split('')) {
    final code = ch.codeUnitAt(0);
    if (code >= 0x064B && code <= 0x0652 || code == 0x0670) {
      if (units.isEmpty) continue;
      final u = units.last;
      u.hasMark = true;
      switch (code) {
        case 0x064B:
          u.vowel = 'an';
        case 0x064C:
          u.vowel = 'un';
        case 0x064D:
          u.vowel = 'in';
        case 0x064E:
        case 0x0670:
          u.vowel = 'a';
        case 0x064F:
          u.vowel = 'u';
        case 0x0650:
          u.vowel = 'i';
        case 0x0651:
          u.shadda = true;
      }
      continue;
    }
    if (_isArabicLetter(ch)) units.add(_Unit(ch));
  }
  if (units.isEmpty) return '';

  final out = StringBuffer();
  var i = 0;
  var prevVowel = '';
  if (units.length > 3 &&
      (units[0].letter == 'ا' || units[0].letter == 'ٱ') &&
      units[1].letter == 'ل') {
    final first = units[2].letter;
    if (_sunLetters.contains(first)) {
      out.write('a${_letters[first]}-');
      units[2].shadda = false; // the shadda is the assimilation itself
    } else {
      out.write('al-');
    }
    i = 2;
  }
  final wordStart = i;

  for (; i < units.length; i++) {
    final u = units[i];
    final atStart = i == wordStart;
    final String written;
    switch (u.letter) {
      case 'ا':
      case 'ٱ':
      case 'ى':
        written = (prevVowel == 'a' || prevVowel == 'an') ? '' : 'a';
      case 'ة':
        written = (prevVowel == 'a' ? '' : 'a') + (u.hasMark ? 't' : '');
      case 'آ':
        written = atStart ? 'a' : "'a";
      case 'أ':
      case 'إ':
        final hamzaVowel = u.letter == 'إ' ? 'i' : 'a';
        written = atStart ? (u.vowel.isEmpty ? hamzaVowel : '') : "'";
      case 'ء':
      case 'ؤ':
      case 'ئ':
        written = "'";
      case 'ع':
        written = atStart ? (u.vowel.isEmpty ? 'a' : '') : "'";
      case 'و':
      case 'ي':
        final long = u.letter == 'و' ? 'u' : 'i';
        final glide = u.letter == 'و' ? 'w' : 'y';
        if (u.hasMark || atStart || prevVowel == 'a') {
          written = u.shadda ? '$glide$glide' : glide;
        } else if (prevVowel == long) {
          written = '';
        } else {
          written = long;
        }
      default:
        final c = _letters[u.letter] ?? '';
        written = u.shadda ? '$c$c' : c;
    }
    out.write(written);
    out.write(u.vowel);
    prevVowel = u.vowel.isNotEmpty ? u.vowel : _trailingVowel(written);
  }
  return out.toString();
}

String _trailingVowel(String written) {
  if (written.endsWith('a')) return 'a';
  if (written.endsWith('u')) return 'u';
  if (written.endsWith('i')) return 'i';
  return '';
}
