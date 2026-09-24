import 'grammar.dart';
import 'tafqit.dart';

/// A currency for [tafqitCurrency]: a major unit, a minor unit and how many
/// minor units make one major unit.
class ArabicCurrency {
  /// Creates a currency definition.
  const ArabicCurrency({
    required this.code,
    required this.major,
    required this.minor,
    required this.minorPerMajor,
  }) : assert(minorPerMajor > 0);

  /// ISO 4217 code, for your own bookkeeping (not rendered).
  final String code;

  /// Major unit, e.g. دينار جزائري.
  final ArabicNoun major;

  /// Minor unit, e.g. سنتيم.
  final ArabicNoun minor;

  /// Minor units per major unit (100 for DZD, 1000 for TND).
  final int minorPerMajor;

  /// Algerian dinar: دينار جزائري / سنتيم (100).
  static const ArabicCurrency dzd = ArabicCurrency(
    code: 'DZD',
    major: ArabicNoun(
      singular: 'دينار',
      singularAccusative: 'دينارا',
      dual: 'ديناران',
      dualAccusative: 'دينارين',
      plural: 'دنانير',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'جزائري',
        singularAccusative: 'جزائريا',
        dual: 'جزائريان',
        dualAccusative: 'جزائريين',
        plural: 'جزائرية',
      ),
    ),
    minor: _centime,
    minorPerMajor: 100,
  );

  /// Moroccan dirham: درهم مغربي / سنتيم (100).
  static const ArabicCurrency mad = ArabicCurrency(
    code: 'MAD',
    major: ArabicNoun(
      singular: 'درهم',
      singularAccusative: 'درهما',
      dual: 'درهمان',
      dualAccusative: 'درهمين',
      plural: 'دراهم',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'مغربي',
        singularAccusative: 'مغربيا',
        dual: 'مغربيان',
        dualAccusative: 'مغربيين',
        plural: 'مغربية',
      ),
    ),
    minor: _centime,
    minorPerMajor: 100,
  );

  /// Tunisian dinar: دينار تونسي / مليم (1000).
  static const ArabicCurrency tnd = ArabicCurrency(
    code: 'TND',
    major: ArabicNoun(
      singular: 'دينار',
      singularAccusative: 'دينارا',
      dual: 'ديناران',
      dualAccusative: 'دينارين',
      plural: 'دنانير',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'تونسي',
        singularAccusative: 'تونسيا',
        dual: 'تونسيان',
        dualAccusative: 'تونسيين',
        plural: 'تونسية',
      ),
    ),
    minor: ArabicNoun(
      singular: 'مليم',
      singularAccusative: 'مليما',
      dual: 'مليمان',
      dualAccusative: 'مليمين',
      plural: 'مليمات',
      gender: ArabicGender.masculine,
    ),
    minorPerMajor: 1000,
  );

  /// Saudi riyal: ريال سعودي / هللة (100, feminine).
  static const ArabicCurrency sar = ArabicCurrency(
    code: 'SAR',
    major: ArabicNoun(
      singular: 'ريال',
      singularAccusative: 'ريالا',
      dual: 'ريالان',
      dualAccusative: 'ريالين',
      plural: 'ريالات',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'سعودي',
        singularAccusative: 'سعوديا',
        dual: 'سعوديان',
        dualAccusative: 'سعوديين',
        plural: 'سعودية',
      ),
    ),
    minor: ArabicNoun(
      singular: 'هللة',
      singularAccusative: 'هللة',
      dual: 'هللتان',
      dualAccusative: 'هللتين',
      plural: 'هللات',
      gender: ArabicGender.feminine,
    ),
    minorPerMajor: 100,
  );

  /// Egyptian pound: جنيه مصري / قرش (100).
  static const ArabicCurrency egp = ArabicCurrency(
    code: 'EGP',
    major: ArabicNoun(
      singular: 'جنيه',
      singularAccusative: 'جنيها',
      dual: 'جنيهان',
      dualAccusative: 'جنيهين',
      plural: 'جنيهات',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'مصري',
        singularAccusative: 'مصريا',
        dual: 'مصريان',
        dualAccusative: 'مصريين',
        plural: 'مصرية',
      ),
    ),
    minor: ArabicNoun(
      singular: 'قرش',
      singularAccusative: 'قرشا',
      dual: 'قرشان',
      dualAccusative: 'قرشين',
      plural: 'قروش',
      gender: ArabicGender.masculine,
    ),
    minorPerMajor: 100,
  );

  /// US dollar: دولار أمريكي / سنت (100).
  static const ArabicCurrency usd = ArabicCurrency(
    code: 'USD',
    major: ArabicNoun(
      singular: 'دولار',
      singularAccusative: 'دولارا',
      dual: 'دولاران',
      dualAccusative: 'دولارين',
      plural: 'دولارات',
      gender: ArabicGender.masculine,
      adjective: ArabicAdjective(
        singular: 'أمريكي',
        singularAccusative: 'أمريكيا',
        dual: 'أمريكيان',
        dualAccusative: 'أمريكيين',
        plural: 'أمريكية',
      ),
    ),
    minor: ArabicNoun(
      singular: 'سنت',
      singularAccusative: 'سنتا',
      dual: 'سنتان',
      dualAccusative: 'سنتين',
      plural: 'سنتات',
      gender: ArabicGender.masculine,
    ),
    minorPerMajor: 100,
  );
}

const ArabicNoun _centime = ArabicNoun(
  singular: 'سنتيم',
  singularAccusative: 'سنتيما',
  dual: 'سنتيمان',
  dualAccusative: 'سنتيمين',
  plural: 'سنتيمات',
  gender: ArabicGender.masculine,
);

/// Writes a money [amount] in Arabic words, as on cheques and invoices.
///
/// The amount is rounded to the nearest minor unit, so binary floating point
/// noise (0.1 + 0.2) does not leak into the words. For exact amounts above
/// about 10^13, use [tafqitCurrencyMinor] with an integer count of minor
/// units instead.
///
/// ```dart
/// tafqitCurrency(1250.50);
/// // ألف ومئتان وخمسون دينارا جزائريا وخمسون سنتيما
/// ```
///
/// Set [only] to wrap the result in "فقط ... لا غير", the usual cheque guard.
String tafqitCurrency(
  num amount, {
  ArabicCurrency currency = ArabicCurrency.dzd,
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
  OneTwoStyle oneTwoStyle = OneTwoStyle.repeatNoun,
  bool only = false,
}) {
  if (amount.isNaN || amount.isInfinite) {
    throw ArgumentError.value(amount, 'amount', 'Must be finite');
  }
  return tafqitCurrencyMinor(
    (amount * currency.minorPerMajor).round(),
    currency: currency,
    grammaticalCase: grammaticalCase,
    hundredSpelling: hundredSpelling,
    oneTwoStyle: oneTwoStyle,
    only: only,
  );
}

/// Like [tafqitCurrency], but takes an exact integer number of minor units
/// (for DZD, 125050 means 1250 dinars and 50 centimes).
String tafqitCurrencyMinor(
  int minorUnits, {
  ArabicCurrency currency = ArabicCurrency.dzd,
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
  OneTwoStyle oneTwoStyle = OneTwoStyle.repeatNoun,
  bool only = false,
}) {
  final total = BigInt.from(minorUnits);
  final perMajor = BigInt.from(currency.minorPerMajor);
  final abs = total.abs();
  final major = abs ~/ perMajor;
  final minor = abs % perMajor;

  String counted(BigInt n, ArabicNoun noun) => tafqitCountedBigInt(
        n,
        noun,
        grammaticalCase: grammaticalCase,
        hundredSpelling: hundredSpelling,
        oneTwoStyle: oneTwoStyle,
      );

  final String body;
  if (minor == BigInt.zero) {
    body = counted(major, currency.major);
  } else if (major == BigInt.zero) {
    body = counted(minor, currency.minor);
  } else {
    body = '${counted(major, currency.major)} و'
        '${counted(minor, currency.minor)}';
  }
  final signed = total.isNegative ? 'سالب $body' : body;
  return only ? 'فقط $signed لا غير' : signed;
}
