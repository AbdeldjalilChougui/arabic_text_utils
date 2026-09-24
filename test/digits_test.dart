import 'package:arabic_text_utils/arabic_text_utils.dart';
import 'package:test/test.dart';

void main() {
  group('convertDigits', () {
    test('Arabic-Indic to Western', () {
      expect(toWesternDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    });
    test('Persian to Western', () {
      expect(toWesternDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    });
    test('Western to Arabic-Indic', () {
      expect(toArabicIndicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
    });
    test('Western to Persian', () {
      expect(toPersianDigits('0123456789'), '۰۱۲۳۴۵۶۷۸۹');
    });
    test('Persian to Arabic-Indic', () {
      expect(toArabicIndicDigits('۴۵۶'), '٤٥٦');
    });
    test('Arabic-Indic to Persian', () {
      expect(toPersianDigits('٤٥٦'), '۴۵۶');
    });
    test('mixed input to Western keeps other text', () {
      expect(toWesternDigits('رقم ١2۳ هنا'), 'رقم 123 هنا');
    });
    test('Arabic separators become Western', () {
      expect(toWesternDigits('١٬٢٣٤٫٥'), '1,234.5');
    });
    test('separators can be kept', () {
      expect(toWesternDigits('١٬٢٣٤٫٥', convertSeparators: false), '1٬234٫5');
    });
    test('Western separators between digits become Arabic', () {
      expect(toArabicIndicDigits('1,234.5 kg.'), '١٬٢٣٤٫٥ kg.');
    });
    test('punctuation that is not between digits is untouched', () {
      expect(toArabicIndicDigits('End. Next, 3'), 'End. Next, ٣');
    });
    test('convertDigits with explicit target', () {
      expect(convertDigits('12', DigitSystem.arabicIndic), '١٢');
      expect(convertDigits('١٢', DigitSystem.western), '12');
      expect(convertDigits('١٢', DigitSystem.persian), '۱۲');
    });
  });

  group('parseArabicNumber', () {
    test('Arabic-Indic integer', () {
      expect(parseArabicNumber('١٢٣'), 123);
    });
    test('mixed digit systems', () {
      expect(parseArabicNumber('١2۳'), 123);
    });
    test('Arabic decimal and thousands separators', () {
      expect(parseArabicNumber('١٬٢٣٤٫٥'), 1234.5);
    });
    test('Western separators', () {
      expect(parseArabicNumber('1,234.25'), 1234.25);
    });
    test('negative with ASCII minus', () {
      expect(parseArabicNumber('-٤٢'), -42);
    });
    test('negative with Unicode minus sign', () {
      expect(parseArabicNumber('−٤٢'), -42);
    });
    test('surrounding whitespace and bidi marks are ignored', () {
      expect(parseArabicNumber(' \u200F٤٢\u200E '), 42);
    });
    test('integers are returned as int', () {
      expect(parseArabicNumber('٤٢'), isA<int>());
    });
    test('decimals are returned as double', () {
      expect(parseArabicNumber('٤٫٠'), isA<double>());
    });
    test('invalid input throws FormatException', () {
      expect(() => parseArabicNumber('١٢أ'), throwsFormatException);
      expect(() => parseArabicNumber(''), throwsFormatException);
      expect(() => parseArabicNumber('١٫٢٫٣'), throwsFormatException);
    });
    test('tryParseArabicNumber returns null on invalid input', () {
      expect(tryParseArabicNumber('abc'), isNull);
      expect(tryParseArabicNumber('۱۲'), 12);
    });
  });
}
