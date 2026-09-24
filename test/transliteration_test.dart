import 'package:arabic_text_utils/arabic_text_utils.dart';
import 'package:test/test.dart';

void main() {
  group('slugify', () {
    const cases = <String, String>{
      'مطعم الأصالة': 'mtaam-al-asala',
      'Hello World': 'hello-world',
      '  متجر   Sidi  ': 'mtjr-sidi',
      'Café Élite': 'cafe-elite',
      '٢٠٢٤ سنة': '2024-sna',
      'مُحَمَّد': 'mhmd',
      'مـــطعم': 'mtaam',
      'عمر': 'amr',
      'الجزائر': 'al-jzair',
      'ذهب': 'dhhb',
      'شاي، قهوة؟': 'shay-qhwa',
      'ڨالمة': 'galma',
      'a--b__c': 'a-b-c',
      '!!!': '',
      '': '',
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(slugify(input), expected));
    });

    test('output is always lowercase ASCII with hyphens', () {
      final slug = slugify('Ça va? مرحبا بكم في الجزائر 2024 !');
      expect(slug, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
    });

    test('transliterate with slug mode matches slugify', () {
      expect(
        transliterate('مطعم الأصالة', mode: TransliterationMode.slug),
        'mtaam-al-asala',
      );
    });
  });

  group('transliterate (readable, approximate)', () {
    const cases = <String, String>{
      'مُحَمَّد': 'muhammad',
      'كِتَابٌ': 'kitabun',
      'الشَّمْس': 'ash-shams',
      'القَمَر': 'al-qamar',
      'مَدْرَسَة': 'madrasa',
      'مُوسَى': 'musa',
      'عُمَر': 'umar',
      'سَأَلَ': "sa'ala",
      'نور': 'nur',
      'مرحبا بكم': 'mrhba bkm',
      'Hello، مرحبا؟': 'Hello, mrhba?',
      '٢٠٢٤': '2024',
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(transliterate(input), expected));
    });

    test('Latin text passes through unchanged', () {
      expect(transliterate('Algiers 16000'), 'Algiers 16000');
    });
  });
}
