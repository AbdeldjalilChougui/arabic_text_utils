/// A decimal digit system.
enum DigitSystem {
  /// 0123456789.
  western,

  /// Arabic-Indic digits ٠١٢٣٤٥٦٧٨٩ (U+0660-U+0669), used in the Mashriq.
  arabicIndic,

  /// Extended Arabic-Indic (Eastern / Persian) digits ۰۱۲۳۴۵۶۷۸۹
  /// (U+06F0-U+06F9), used for Persian and Urdu.
  persian,
}

/// ARABIC DECIMAL SEPARATOR, U+066B.
const String arabicDecimalSeparator = '٫';

/// ARABIC THOUSANDS SEPARATOR, U+066C.
const String arabicThousandsSeparator = '٬';

const int _western0 = 0x30;
const int _arabicIndic0 = 0x0660;
const int _persian0 = 0x06F0;

int _base(DigitSystem system) => switch (system) {
      DigitSystem.western => _western0,
      DigitSystem.arabicIndic => _arabicIndic0,
      DigitSystem.persian => _persian0,
    };

/// Returns the value 0-9 of [codeUnit] in any supported digit system, or -1.
int _digitValue(int codeUnit) {
  for (final zero in const [_western0, _arabicIndic0, _persian0]) {
    if (codeUnit >= zero && codeUnit <= zero + 9) return codeUnit - zero;
  }
  return -1;
}

/// Converts every digit in [text], whatever its system, to [target].
///
/// With [convertSeparators] (the default), the Arabic decimal and thousands
/// separators (٫ ٬) become `.` and `,` when converting to Western digits.
/// When converting to Arabic-Indic or Persian digits, `.` and `,` become
/// ٫ and ٬ only when they sit between two digits, so sentence punctuation is
/// left alone.
String convertDigits(
  String text,
  DigitSystem target, {
  bool convertSeparators = true,
}) {
  final zero = _base(target);
  final units = text.codeUnits;
  final out = StringBuffer();
  for (var i = 0; i < units.length; i++) {
    final c = units[i];
    final value = _digitValue(c);
    if (value >= 0) {
      out.writeCharCode(zero + value);
      continue;
    }
    if (convertSeparators) {
      if (target == DigitSystem.western) {
        if (c == 0x066B) {
          out.write('.');
          continue;
        }
        if (c == 0x066C) {
          out.write(',');
          continue;
        }
      } else if ((c == 0x2E || c == 0x2C) &&
          i > 0 &&
          i + 1 < units.length &&
          _digitValue(units[i - 1]) >= 0 &&
          _digitValue(units[i + 1]) >= 0) {
        out.write(
            c == 0x2E ? arabicDecimalSeparator : arabicThousandsSeparator);
        continue;
      }
    }
    out.writeCharCode(c);
  }
  return out.toString();
}

/// Converts Arabic-Indic and Persian digits in [text] to Western digits.
/// See [convertDigits] for [convertSeparators].
String toWesternDigits(String text, {bool convertSeparators = true}) =>
    convertDigits(text, DigitSystem.western,
        convertSeparators: convertSeparators);

/// Converts Western and Persian digits in [text] to Arabic-Indic digits.
/// See [convertDigits] for [convertSeparators].
String toArabicIndicDigits(String text, {bool convertSeparators = true}) =>
    convertDigits(text, DigitSystem.arabicIndic,
        convertSeparators: convertSeparators);

/// Converts Western and Arabic-Indic digits in [text] to Persian digits.
/// See [convertDigits] for [convertSeparators].
String toPersianDigits(String text, {bool convertSeparators = true}) =>
    convertDigits(text, DigitSystem.persian,
        convertSeparators: convertSeparators);

final RegExp _ignorable = RegExp('[\\s\u200E\u200F\u061C\u2066-\u2069]');
final RegExp _numberShape = RegExp(r'^[+-]?\d+(\.\d+)?$');

/// Parses a number written with any mix of Western, Arabic-Indic and Persian
/// digits.
///
/// Accepts `.` or ٫ as decimal separator, `,` or ٬ as thousands separator
/// (removed), a leading `+`, `-` or U+2212 MINUS SIGN, and ignores
/// whitespace and bidi marks. Returns an [int] when there is no fractional
/// part, a [double] otherwise. Throws a [FormatException] for invalid input.
num parseArabicNumber(String text) {
  final result = tryParseArabicNumber(text);
  if (result == null) {
    throw FormatException('Not a number', text);
  }
  return result;
}

/// Like [parseArabicNumber] but returns null instead of throwing.
num? tryParseArabicNumber(String text) {
  final normalized = toWesternDigits(text.replaceAll(_ignorable, ''))
      .replaceAll(',', '')
      .replaceAll('−', '-');
  if (!_numberShape.hasMatch(normalized)) return null;
  if (normalized.contains('.')) return double.tryParse(normalized);
  return int.tryParse(normalized);
}
