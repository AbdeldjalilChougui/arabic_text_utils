import 'package:arabic_text_utils/arabic_text_utils.dart';

void main() {
  // Numbers to words (تفقيط).
  print(tafqit(1250)); // ألف ومئتان وخمسون
  print(tafqit(3, gender: ArabicGender.feminine)); // ثلاث
  print(tafqit(22, grammaticalCase: ArabicCase.accusative)); // اثنين وعشرين

  // Counted nouns and currencies.
  print(tafqitCounted(2000, ArabicCurrency.dzd.major)); // ألفا دينار جزائري
  print(tafqitCurrency(1250.50));
  // ألف ومئتان وخمسون دينارا جزائريا وخمسون سنتيما
  print(tafqitCurrency(1000, only: true)); // فقط ألف دينار جزائري لا غير

  // Digits.
  print(toArabicIndicDigits('1,234.5')); // ١٬٢٣٤٫٥
  print(parseArabicNumber('١٬٢٣٤٫٥')); // 1234.5

  // Diacritics.
  print(removeDiacritics('مُحَمَّدٌ')); // محمد
  print(hasDiacritics('كَتَبَ')); // true

  // Detection and direction.
  print(containsArabic('Hello مرحبا')); // true
  print(arabicRatio('ab سل')); // 0.5
  print(detectDirection('مرحبا Hello')); // BidiDirection.rtl
  final name = isolate('Djalil');
  print('مرحبا $name!');

  // Transliteration (approximate).
  print(slugify('مطعم الأصالة')); // mtaam-al-asala
  print(transliterate('مُحَمَّد')); // muhammad
}
