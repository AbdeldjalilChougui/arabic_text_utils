import 'package:arabic_text_utils/arabic_text_utils.dart';
import 'package:test/test.dart';

void main() {
  group('removeDiacritics', () {
    test('harakat', () {
      expect(removeDiacritics('كَتَبَ'), 'كتب');
    });
    test('shadda and sukun', () {
      expect(removeDiacritics('مُحَمَّدٌ قَلْبٌ'), 'محمد قلب');
    });
    test('tanween', () {
      expect(removeDiacritics('كِتَابًا وَبَيْتٍ'), 'كتابا وبيت');
    });
    test('superscript alef', () {
      expect(removeDiacritics('هٰذَا'), 'هذا');
    });
    test('Quranic annotation marks U+0610-U+061A', () {
      expect(removeDiacritics('محمد\u0610\u0611\u061A'), 'محمد');
    });
    test('Quranic annotation marks U+06D6-U+06ED', () {
      expect(removeDiacritics('الرَّحِيمِ\u06D6 \u06DA\u06ED'), 'الرحيم ');
    });
    test('keepShadda', () {
      expect(removeDiacritics('مُحَمَّد', keepShadda: true), 'محمّد');
    });
    test('keepQuranicMarks', () {
      expect(
          removeDiacritics('قَالَ\u06D6', keepQuranicMarks: true), 'قال\u06D6');
    });
    test('tatweel is kept by default', () {
      expect(removeDiacritics('مـــحَمد'), 'مـــحمد');
    });
    test('tatweel option', () {
      expect(removeDiacritics('مـــحَمد', removeTatweel: true), 'محمد');
    });
    test('hamza letters are not touched', () {
      expect(removeDiacritics('أَإِآؤئء'), 'أإآؤئء');
    });
    test('text without diacritics is unchanged', () {
      expect(removeDiacritics('Hello مرحبا 123'), 'Hello مرحبا 123');
    });
  });

  group('removeTatweel', () {
    test('removes kashida', () {
      expect(removeTatweel('الســـلام'), 'السلام');
    });
    test('keeps other text', () {
      expect(removeTatweel('abc_def'), 'abc_def');
    });
  });

  group('hasDiacritics', () {
    test('true for harakat', () => expect(hasDiacritics('كَتب'), isTrue));
    test('true for shadda', () => expect(hasDiacritics('محمّد'), isTrue));
    test('false for plain text', () => expect(hasDiacritics('كتب'), isFalse));
    test('false for empty', () => expect(hasDiacritics(''), isFalse));
    test('Quranic marks count by default', () {
      expect(hasDiacritics('قال\u06D6'), isTrue);
    });
    test('Quranic marks can be ignored', () {
      expect(hasDiacritics('قال\u06D6', includeQuranicMarks: false), isFalse);
    });
    test('tatweel is not a diacritic', () {
      expect(hasDiacritics('مـحمد'), isFalse);
    });
  });
}
