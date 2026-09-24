import 'package:arabic_text_utils/arabic_text_utils.dart';
import 'package:test/test.dart';

void main() {
  group('containsArabic', () {
    test('Arabic word', () => expect(containsArabic('مرحبا'), isTrue));
    test('mixed', () => expect(containsArabic('Hello مرحبا'), isTrue));
    test('Latin only', () => expect(containsArabic('Hello'), isFalse));
    test('Arabic-Indic digits alone are not letters', () {
      expect(containsArabic('١٢٣'), isFalse);
    });
    test('Persian letters are Arabic script', () {
      expect(containsArabic('پ'), isTrue);
    });
    test('presentation forms count', () {
      expect(containsArabic('ﻻ'), isTrue); // lam-alef ligature
    });
    test('empty', () => expect(containsArabic(''), isFalse));
  });

  group('isArabic', () {
    test('pure Arabic', () => expect(isArabic('مرحبا بكم'), isTrue));
    test('Arabic with digits and punctuation', () {
      expect(isArabic('السعر: ١٢٣ دج، شكرا!'), isTrue);
    });
    test('Arabic with diacritics', () => expect(isArabic('كَتَبَ'), isTrue));
    test('mixed with Latin', () => expect(isArabic('مرحبا Hello'), isFalse));
    test('no letters at all', () => expect(isArabic('١٢٣ !'), isFalse));
    test('empty', () => expect(isArabic(''), isFalse));
  });

  group('arabicRatio', () {
    test('all Arabic', () => expect(arabicRatio('مرحبا'), 1.0));
    test('no letters', () => expect(arabicRatio('123 !'), 0.0));
    test('half and half', () => expect(arabicRatio('ab سل'), 0.5));
    test('ignores digits, spaces and marks', () {
      expect(arabicRatio('كَتَبَ abc ١٢٣'), 0.5);
    });
  });

  group('detectDirection', () {
    test('Arabic first', () {
      expect(detectDirection('مرحبا Hello'), BidiDirection.rtl);
    });
    test('Latin first', () {
      expect(detectDirection('Hello مرحبا'), BidiDirection.ltr);
    });
    test('skips digits and punctuation', () {
      expect(detectDirection('123 - !مرحبا'), BidiDirection.rtl);
    });
    test('Hebrew is rtl', () {
      expect(detectDirection('שלום'), BidiDirection.rtl);
    });
    test('fallback when there is no strong character', () {
      expect(detectDirection('123'), BidiDirection.ltr);
      expect(detectDirection('١٢٣', fallback: BidiDirection.rtl),
          BidiDirection.rtl);
    });
    test('RLM counts as strong rtl', () {
      expect(detectDirection('\u200F123 abc'), BidiDirection.rtl);
    });
    test('LRM counts as strong ltr', () {
      expect(detectDirection('\u200Eمرحبا'), BidiDirection.ltr);
    });
    test('content inside isolates is skipped', () {
      expect(detectDirection('\u2068Hello\u2069 مرحبا'), BidiDirection.rtl);
    });
  });

  group('bidi helpers', () {
    test('isolate uses FSI and PDI', () {
      expect(isolate('abc'), '\u2068abc\u2069');
    });
    test('isolate with explicit direction uses RLI/LRI', () {
      expect(isolate('abc', direction: BidiDirection.rtl), '\u2067abc\u2069');
      expect(isolate('abc', direction: BidiDirection.ltr), '\u2066abc\u2069');
    });
    test('embedWithMarks surrounds text with RLM', () {
      expect(embedWithMarks('abc', BidiDirection.rtl), '\u200Fabc\u200F');
    });
    test('embedWithMarks surrounds text with LRM', () {
      expect(embedWithMarks('abc', BidiDirection.ltr), '\u200Eabc\u200E');
    });
    test('stripBidiControls removes marks and isolates', () {
      expect(
          stripBidiControls('\u200F\u2068abc\u2069\u200E\u202B\u202C'), 'abc');
    });
    test('constants', () {
      expect(BidiChars.rlm, '\u200F');
      expect(BidiChars.lrm, '\u200E');
      expect(BidiChars.alm, '\u061C');
      expect(BidiChars.fsi, '\u2068');
      expect(BidiChars.pdi, '\u2069');
    });
  });
}
