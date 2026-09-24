# arabic_text_utils

Everyday Arabic text utilities in pure Dart: grammatically correct number-to-words (تفقيط) with
currencies for cheques and invoices, digit conversion and parsing, diacritics removal, script and
direction detection, and URL slugs.

[![pub package](https://img.shields.io/pub/v/arabic_text_utils.svg)](https://pub.dev/packages/arabic_text_utils)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- **Tafqit (تفقيط)**: integers from 0 to 10^21 − 1 (all `int` values and `BigInt`), negatives
  (سالب), gender of the counted noun (with the reversed gender of 3–10), nominative or
  accusative/genitive case (اثنان/اثنين, عشرون/عشرين, مئتان/مئتين), duals (ألفان, مليونان),
  plurals (آلاف, ملايين), and the correct تمييز: plural after 3–10, singular accusative after
  11–99, singular genitive after مئة/ألف/مليون with the dual in إضافة (مئتا دينار, ألفا دينار).
- **Currencies**: DZD (دينار جزائري / سنتيم) by default, plus MAD, TND (1000 millimes), SAR,
  EGP, USD, or your own. Fractions are rounded to the minor unit. Optional "فقط … لا غير".
- **Hundreds** spelled مئة (modern, default) or مائة.
- **Digits**: convert between Western, Arabic-Indic (٠-٩) and Persian (۰-۹) digits in any
  direction, including the Arabic decimal (٫) and thousands (٬) separators; parse numbers that mix
  digit systems.
- **Diacritics**: remove tashkeel (harakat, tanween, shadda, sukun, superscript alef, Quranic
  marks U+0610–U+061A and U+06D6–U+06ED) with options; remove tatweel; detect diacritics.
- **Detection and direction**: `isArabic`, `containsArabic`, `arabicRatio`, `detectDirection`
  (first strong character, as in UAX #9), bidi isolates (FSI/RLI/LRI … PDI) and RLM/LRM marks.
- **Transliteration**: URL-safe slugs (`مطعم الأصالة` → `mtaam-al-asala`) and an approximate
  readable Latin form.

This package does not do search or fuzzy matching.

## Install

```yaml
dependencies:
  arabic_text_utils: ^0.1.0
```

```dart
import 'package:arabic_text_utils/arabic_text_utils.dart';
```

## Usage

### Numbers to words

```dart
tafqit(1250); // ألف ومئتان وخمسون
tafqit(11000); // أحد عشر ألفا
tafqit(200000); // مئتا ألف
tafqit(3, gender: ArabicGender.feminine); // ثلاث
tafqit(12, grammaticalCase: ArabicCase.accusative); // اثني عشر
tafqit(300, hundredSpelling: HundredSpelling.classical); // ثلاثمائة
tafqit(-5); // سالب خمسة
```

### Counted nouns and currencies

```dart
final dinar = ArabicCurrency.dzd.major;
tafqitCounted(1, dinar); // دينار جزائري واحد
tafqitCounted(3, dinar); // ثلاثة دنانير جزائرية
tafqitCounted(11, dinar); // أحد عشر دينارا جزائريا
tafqitCounted(2000, dinar); // ألفا دينار جزائري
tafqitCounted(101, dinar); // مئة دينار جزائري ودينار

tafqitCurrency(1250.50);
// ألف ومئتان وخمسون دينارا جزائريا وخمسون سنتيما
tafqitCurrency(1000, only: true); // فقط ألف دينار جزائري لا غير
tafqitCurrency(5.25, currency: ArabicCurrency.sar);
// خمسة ريالات سعودية وخمس وعشرون هللة
tafqitCurrencyMinor(125050); // exact, in centimes
```

Define your own noun or currency with `ArabicNoun`, `ArabicAdjective` and `ArabicCurrency`
(see the `custom currency` test for a full example).

#### Numbers ending in 1 or 2

A number such as 101 or 1002 ends in a part that takes no تمييز. By default the noun is repeated,
the model being "ألف ليلة وليلة": `مئة دينار جزائري ودينار`, `ألف دينار جزائري وديناران`. Cheques
often use the numeral instead (`مئة وواحد دينار جزائري`); pass
`oneTwoStyle: OneTwoStyle.numeral` for that. The same rule gives `مئة ألف وألف` for 101000.

### Digits

```dart
toWesternDigits('١٬٢٣٤٫٥'); // 1,234.5
toArabicIndicDigits('1,234.5 kg.'); // ١٬٢٣٤٫٥ kg.
toPersianDigits('123'); // ۱۲۳
parseArabicNumber('١2۳'); // 123
tryParseArabicNumber('abc'); // null
```

### Diacritics

```dart
removeDiacritics('مُحَمَّدٌ'); // محمد
removeDiacritics('مُحَمَّد', keepShadda: true); // محمّد
removeDiacritics('مـحَمد', removeTatweel: true); // محمد
removeTatweel('الســلام'); // السلام
hasDiacritics('كَتَبَ'); // true
```

### Detection and direction

```dart
isArabic('السعر: ١٢٣ دج'); // true
containsArabic('Hello مرحبا'); // true
arabicRatio('ab سل'); // 0.5
detectDirection('123 مرحبا'); // BidiDirection.rtl
isolate(userName); // FSI + userName + PDI
embedWithMarks('(123)', BidiDirection.rtl); // RLM + (123) + RLM
stripBidiControls(text);
```

### Transliteration

```dart
slugify('مطعم الأصالة'); // mtaam-al-asala
slugify('Café Élite'); // cafe-elite
transliterate('مُحَمَّد'); // muhammad
transliterate('الشَّمْس'); // ash-shams
transliterate('مرحبا'); // mrhba (no diacritics, so no short vowels)
```

## Limitations

- **Transliteration is approximate.** Arabic script does not write short vowels, so text without
  diacritics is transliterated without them. It is not ALA-LC, ISO 233 or any other standard, and
  slugs cannot be converted back to Arabic.
- Tafqit writes numbers without tashkeel, and uses the tanween alef spelling (دينارا, ألفا).
- The feminine 8 is written ثماني in all positions, as in modern usage.
- Scale words above a billion (تريليون, كوادريليون, كوينتليون) follow the short scale; usage
  varies between countries.
- The built-in currencies cover DZD, MAD, TND, SAR, EGP and USD. Other currencies need an
  `ArabicCurrency` definition.
- `tafqitCurrency` takes a `num`: very large amounts lose precision as `double`. Use
  `tafqitCurrencyMinor` with an exact `int` of minor units.

## Grammar references

The tafqit rules and test cases follow standard descriptions of العدد والمعدود:

- Al Jazeera Learning Arabic, [أحكام العدد والمعدود](https://learning.aljazeera.net/en/generallanguage/%D8%A7%D9%84%D8%B9%D8%AF%D8%AF-%D9%88%D8%A7%D9%84%D9%85%D8%B9%D8%AF%D9%88%D8%AF)
  and [تمييز العدد](https://learning.aljazeera.net/en/AskTheTeacher/%D8%AA%D9%85%D9%8A%D9%8A%D8%B2-%D8%A7%D9%84%D8%B9%D8%AF%D8%AF)
  (gender of 1–19, tamyiz after مئة/ألف/مليون/مليار).
- Virtual Arabic Language Academy, [decision 29 on reading compound numbers](https://almajma3.blogspot.com/2018/04/blog-post_20.html)
  (largest part first; last part governs the tamyiz, e.g. مئةٌ وثلاثةٌ وستونَ رجلًا).
- Kalimah Center, [Arabic Numbers Grammar](https://kalimah-center.com/arabic-numbers-grammar/)
  (dual مئتا/ألفا in construct).

## License

MIT. See [LICENSE](LICENSE).

Made by [Abdeldjalil Chougui](https://abdeldjalilchougui.biz/).
