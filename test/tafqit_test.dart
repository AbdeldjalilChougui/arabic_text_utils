import 'package:arabic_text_utils/arabic_text_utils.dart';
import 'package:test/test.dart';

/// Expected outputs follow the standard rules of العدد والمعدود:
/// - 1 and 2 agree with the counted noun; 3-10 take the opposite gender.
/// - 11-99 take a singular accusative tamyiz; 3-10 a plural genitive one.
/// - مئة / ألف / مليون / مليار take a singular genitive tamyiz (إضافة), and a
///   dual in إضافة drops its نون (مئتا دينار, ألفا دينار).
/// - In a number made of several parts, the last part governs the tamyiz
///   (Arabic Language Academy example: "مئةٌ وثلاثةٌ وستونَ رجلًا").
/// - A trailing 1 or 2 repeats the noun, as in "ألف ليلة وليلة".
void main() {
  group('tafqit: masculine nominative (default)', () {
    const cases = <int, String>{
      0: 'صفر',
      1: 'واحد',
      2: 'اثنان',
      3: 'ثلاثة',
      8: 'ثمانية',
      10: 'عشرة',
      11: 'أحد عشر',
      12: 'اثنا عشر',
      13: 'ثلاثة عشر',
      18: 'ثمانية عشر',
      19: 'تسعة عشر',
      20: 'عشرون',
      21: 'واحد وعشرون',
      22: 'اثنان وعشرون',
      25: 'خمسة وعشرون',
      99: 'تسعة وتسعون',
      100: 'مئة',
      101: 'مئة وواحد',
      102: 'مئة واثنان',
      110: 'مئة وعشرة',
      111: 'مئة وأحد عشر',
      163: 'مئة وثلاثة وستون',
      200: 'مئتان',
      300: 'ثلاثمئة',
      800: 'ثمانمئة',
      999: 'تسعمئة وتسعة وتسعون',
      1000: 'ألف',
      1001: 'ألف وواحد',
      1100: 'ألف ومئة',
      2000: 'ألفان',
      3000: 'ثلاثة آلاف',
      10000: 'عشرة آلاف',
      11000: 'أحد عشر ألفا',
      12000: 'اثنا عشر ألفا',
      21000: 'واحد وعشرون ألفا',
      100000: 'مئة ألف',
      101000: 'مئة ألف وألف',
      102000: 'مئة ألف وألفان',
      103000: 'مئة وثلاثة آلاف',
      200000: 'مئتا ألف',
      250000: 'مئتان وخمسون ألفا',
      1000000: 'مليون',
      2000000: 'مليونان',
      3000000: 'ثلاثة ملايين',
      11000000: 'أحد عشر مليونا',
      1000000000: 'مليار',
      2000000000: 'ملياران',
      5000000000: 'خمسة مليارات',
      1000000000000: 'تريليون',
      1000000000000000: 'كوادريليون',
      1234567: 'مليون ومئتان وأربعة وثلاثون ألفا وخمسمئة وسبعة وستون',
      2002002: 'مليونان وألفان واثنان',
    };
    cases.forEach((n, expected) {
      test('$n', () => expect(tafqit(n), expected));
    });
  });

  group('tafqit: feminine counted noun (reversed gender for 3-10)', () {
    const cases = <int, String>{
      1: 'واحدة',
      2: 'اثنتان',
      3: 'ثلاث',
      8: 'ثماني',
      10: 'عشر',
      11: 'إحدى عشرة',
      12: 'اثنتا عشرة',
      13: 'ثلاث عشرة',
      18: 'ثماني عشرة',
      21: 'إحدى وعشرون',
      22: 'اثنتان وعشرون',
      23: 'ثلاث وعشرون',
      // Hundreds and thousands do not change; only the last part does.
      300: 'ثلاثمئة',
      3003: 'ثلاثة آلاف وثلاث',
    };
    cases.forEach((n, expected) {
      test('$n', () {
        expect(tafqit(n, gender: ArabicGender.feminine), expected);
      });
    });
  });

  group('tafqit: accusative / genitive', () {
    test('1 accusative', () {
      expect(tafqit(1, grammaticalCase: ArabicCase.accusative), 'واحدا');
    });
    test('1 genitive', () {
      expect(tafqit(1, grammaticalCase: ArabicCase.genitive), 'واحد');
    });
    test('2 accusative', () {
      expect(tafqit(2, grammaticalCase: ArabicCase.accusative), 'اثنين');
    });
    test('2 feminine genitive', () {
      expect(
        tafqit(2,
            gender: ArabicGender.feminine,
            grammaticalCase: ArabicCase.genitive),
        'اثنتين',
      );
    });
    test('12 accusative', () {
      expect(tafqit(12, grammaticalCase: ArabicCase.accusative), 'اثني عشر');
    });
    test('12 feminine accusative', () {
      expect(
        tafqit(12,
            gender: ArabicGender.feminine,
            grammaticalCase: ArabicCase.accusative),
        'اثنتي عشرة',
      );
    });
    test('20 genitive', () {
      expect(tafqit(20, grammaticalCase: ArabicCase.genitive), 'عشرين');
    });
    test('21 accusative', () {
      expect(
          tafqit(21, grammaticalCase: ArabicCase.accusative), 'واحدا وعشرين');
    });
    test('21 feminine accusative', () {
      expect(
        tafqit(21,
            gender: ArabicGender.feminine,
            grammaticalCase: ArabicCase.accusative),
        'إحدى وعشرين',
      );
    });
    test('200 accusative', () {
      expect(tafqit(200, grammaticalCase: ArabicCase.accusative), 'مئتين');
    });
    test('1000 accusative', () {
      expect(tafqit(1000, grammaticalCase: ArabicCase.accusative), 'ألفا');
    });
    test('2000 accusative', () {
      expect(tafqit(2000, grammaticalCase: ArabicCase.accusative), 'ألفين');
    });
    test('22000 accusative', () {
      expect(tafqit(22000, grammaticalCase: ArabicCase.accusative),
          'اثنين وعشرين ألفا');
    });
    test('200000 genitive', () {
      expect(tafqit(200000, grammaticalCase: ArabicCase.genitive), 'مئتي ألف');
    });
    test('2000000 accusative', () {
      expect(
          tafqit(2000000, grammaticalCase: ArabicCase.accusative), 'مليونين');
    });
  });

  group('tafqit: hundred spelling', () {
    const s = HundredSpelling.classical;
    test('100', () => expect(tafqit(100, hundredSpelling: s), 'مائة'));
    test('200', () => expect(tafqit(200, hundredSpelling: s), 'مائتان'));
    test('300', () => expect(tafqit(300, hundredSpelling: s), 'ثلاثمائة'));
    test('200000', () {
      expect(tafqit(200000, hundredSpelling: s), 'مائتا ألف');
    });
  });

  group('tafqit: negatives and range', () {
    test('-5', () => expect(tafqit(-5), 'سالب خمسة'));
    test('-1000', () => expect(tafqit(-1000), 'سالب ألف'));
    test('max int is supported', () {
      expect(tafqit(9223372036854775807), startsWith('تسعة كوينتليونات '));
    });
    test('min int is supported', () {
      expect(tafqit(-9223372036854775807 - 1),
          startsWith('سالب تسعة كوينتليونات '));
    });
    test('BigInt up to 10^21 - 1', () {
      expect(tafqitBigInt(BigInt.parse('999000000000000000000')),
          'تسعمئة وتسعة وتسعون كوينتليونا');
    });
    test('BigInt of 10^21 throws', () {
      expect(() => tafqitBigInt(BigInt.parse('1000000000000000000000')),
          throwsArgumentError);
    });
  });

  group('tafqitCounted: masculine noun (دينار جزائري)', () {
    final noun = ArabicCurrency.dzd.major;
    const cases = <int, String>{
      0: 'صفر دينار جزائري',
      1: 'دينار جزائري واحد',
      2: 'ديناران جزائريان',
      3: 'ثلاثة دنانير جزائرية',
      10: 'عشرة دنانير جزائرية',
      11: 'أحد عشر دينارا جزائريا',
      20: 'عشرون دينارا جزائريا',
      100: 'مئة دينار جزائري',
      101: 'مئة دينار جزائري ودينار',
      102: 'مئة دينار جزائري وديناران',
      200: 'مئتا دينار جزائري',
      1000: 'ألف دينار جزائري',
      1001: 'ألف دينار جزائري ودينار',
      1002: 'ألف دينار جزائري وديناران',
      1250: 'ألف ومئتان وخمسون دينارا جزائريا',
      2000: 'ألفا دينار جزائري',
      3000: 'ثلاثة آلاف دينار جزائري',
      11000: 'أحد عشر ألف دينار جزائري',
      200000: 'مئتا ألف دينار جزائري',
      1000000: 'مليون دينار جزائري',
      2000000: 'مليونا دينار جزائري',
      2000500: 'مليونان وخمسمئة دينار جزائري',
    };
    cases.forEach((n, expected) {
      test('$n', () => expect(tafqitCounted(n, noun), expected));
    });

    test('1 accusative', () {
      expect(
        tafqitCounted(1, noun, grammaticalCase: ArabicCase.accusative),
        'دينارا جزائريا واحدا',
      );
    });
    test('2 accusative', () {
      expect(
        tafqitCounted(2, noun, grammaticalCase: ArabicCase.accusative),
        'دينارين جزائريين',
      );
    });
    test('2000 genitive', () {
      expect(
        tafqitCounted(2000, noun, grammaticalCase: ArabicCase.genitive),
        'ألفي دينار جزائري',
      );
    });
    test('numeral style for a trailing one (common cheque usage)', () {
      expect(
        tafqitCounted(101, noun, oneTwoStyle: OneTwoStyle.numeral),
        'مئة وواحد دينار جزائري',
      );
    });
    test('numeral style for a trailing two', () {
      expect(
        tafqitCounted(1002, noun, oneTwoStyle: OneTwoStyle.numeral),
        'ألف واثنان دينار جزائري',
      );
    });
    test('numeral style keeps noun-first form for exactly 1', () {
      expect(
        tafqitCounted(1, noun, oneTwoStyle: OneTwoStyle.numeral),
        'دينار جزائري واحد',
      );
    });
  });

  group('tafqitCounted: feminine noun (ساعة)', () {
    const noun = ArabicNoun(
      singular: 'ساعة',
      singularAccusative: 'ساعة',
      dual: 'ساعتان',
      dualAccusative: 'ساعتين',
      plural: 'ساعات',
      gender: ArabicGender.feminine,
    );
    const cases = <int, String>{
      1: 'ساعة واحدة',
      2: 'ساعتان',
      3: 'ثلاث ساعات',
      8: 'ثماني ساعات',
      11: 'إحدى عشرة ساعة',
      18: 'ثماني عشرة ساعة',
      23: 'ثلاث وعشرون ساعة',
      103: 'مئة وثلاث ساعات',
      3000: 'ثلاثة آلاف ساعة',
    };
    cases.forEach((n, expected) {
      test('$n', () => expect(tafqitCounted(n, noun), expected));
    });
  });

  group('tafqitCurrency', () {
    test('DZD with centimes (cheque example)', () {
      expect(
        tafqitCurrency(1250.50),
        'ألف ومئتان وخمسون دينارا جزائريا وخمسون سنتيما',
      );
    });
    test('fraction only', () {
      expect(tafqitCurrency(0.5), 'خمسون سنتيما');
    });
    test('one and one', () {
      expect(tafqitCurrency(1.01), 'دينار جزائري واحد وسنتيم واحد');
    });
    test('two and two', () {
      expect(tafqitCurrency(2.02), 'ديناران جزائريان وسنتيمان');
    });
    test('zero', () {
      expect(tafqitCurrency(0), 'صفر دينار جزائري');
    });
    test('whole amount has no fraction part', () {
      expect(tafqitCurrency(100), 'مئة دينار جزائري');
    });
    test('floating point noise is rounded to the minor unit', () {
      expect(tafqitCurrency(0.1 + 0.2), 'ثلاثون سنتيما');
    });
    test('faqat ... la ghayr wrapper', () {
      expect(
        tafqitCurrency(1000, only: true),
        'فقط ألف دينار جزائري لا غير',
      );
    });
    test('negative amount', () {
      expect(tafqitCurrency(-3), 'سالب ثلاثة دنانير جزائرية');
    });
    test('from minor units', () {
      expect(
        tafqitCurrencyMinor(125050),
        'ألف ومئتان وخمسون دينارا جزائريا وخمسون سنتيما',
      );
    });
    test('SAR with feminine minor unit', () {
      expect(
        tafqitCurrency(5.25, currency: ArabicCurrency.sar),
        'خمسة ريالات سعودية وخمس وعشرون هللة',
      );
    });
    test('TND has 1000 millimes', () {
      expect(
        tafqitCurrency(1.5, currency: ArabicCurrency.tnd),
        'دينار تونسي واحد وخمسمئة مليم',
      );
    });
    test('classical hundred spelling', () {
      expect(
        tafqitCurrency(300, hundredSpelling: HundredSpelling.classical),
        'ثلاثمائة دينار جزائري',
      );
    });
    test('custom currency', () {
      const riyal = ArabicCurrency(
        code: 'QAR',
        major: ArabicNoun(
          singular: 'ريال',
          singularAccusative: 'ريالا',
          dual: 'ريالان',
          dualAccusative: 'ريالين',
          plural: 'ريالات',
          gender: ArabicGender.masculine,
          adjective: ArabicAdjective(
            singular: 'قطري',
            singularAccusative: 'قطريا',
            dual: 'قطريان',
            dualAccusative: 'قطريين',
            plural: 'قطرية',
          ),
        ),
        minor: ArabicNoun(
          singular: 'درهم',
          singularAccusative: 'درهما',
          dual: 'درهمان',
          dualAccusative: 'درهمين',
          plural: 'دراهم',
          gender: ArabicGender.masculine,
        ),
        minorPerMajor: 100,
      );
      expect(tafqitCurrency(4.07, currency: riyal),
          'أربعة ريالات قطرية وسبعة دراهم');
    });
  });
}
