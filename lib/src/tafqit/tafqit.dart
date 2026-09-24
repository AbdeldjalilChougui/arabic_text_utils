import 'grammar.dart';

/// Numbers accepted by [tafqitBigInt] are strictly below this bound (10^21).
final BigInt _limit = BigInt.from(10).pow(21);

const String _and = ' و';

class _Scale {
  const _Scale(this.singular, this.singularAccusative, this.dual, this.plural);

  final String singular;
  final String singularAccusative;
  final String dual;
  final String plural;

  String get dualAccusative => '${dual.substring(0, dual.length - 2)}ين';
}

const List<_Scale> _scales = [
  _Scale('ألف', 'ألفا', 'ألفان', 'آلاف'),
  _Scale('مليون', 'مليونا', 'مليونان', 'ملايين'),
  _Scale('مليار', 'مليارا', 'ملياران', 'مليارات'),
  _Scale('تريليون', 'تريليونا', 'تريليونان', 'تريليونات'),
  _Scale('كوادريليون', 'كوادريليونا', 'كوادريليونان', 'كوادريليونات'),
  _Scale('كوينتليون', 'كوينتليونا', 'كوينتليونان', 'كوينتليونات'),
];

// Forms of 3..10 that go with a masculine counted noun (they carry ة).
const List<String> _unitsForMasculine = [
  'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة', //
];

// Forms of 3..10 that go with a feminine counted noun.
const List<String> _unitsForFeminine = [
  'ثلاث', 'أربع', 'خمس', 'ست', 'سبع', 'ثماني', 'تسع', 'عشر', //
];

const List<String> _tensStems = [
  'عشر', 'ثلاث', 'أربع', 'خمس', 'ست', 'سبع', 'ثمان', 'تسع', //
];

// Prefixes for 300..900, joined to مئة in modern writing.
const List<String> _hundredPrefixes = [
  'ثلاث', 'أربع', 'خمس', 'ست', 'سبع', 'ثمان', 'تسع', //
];

class _Ctx {
  const _Ctx(this.grammaticalCase, this.hundredSpelling, this.oneTwoStyle);

  final ArabicCase grammaticalCase;
  final HundredSpelling hundredSpelling;
  final OneTwoStyle oneTwoStyle;

  bool get nominative => grammaticalCase == ArabicCase.nominative;
  bool get accusative => grammaticalCase == ArabicCase.accusative;
}

/// Converts [number] to Arabic words (تفقيط).
///
/// [gender] is the gender of the (implied) counted noun: 3-10 take the
/// opposite gender, 1, 2, 11 and 12 agree with it. [grammaticalCase] selects
/// nominative (اثنان, عشرون) or accusative/genitive (اثنين, عشرين) forms.
///
/// ```dart
/// tafqit(1250); // ألف ومئتان وخمسون
/// tafqit(3, gender: ArabicGender.feminine); // ثلاث
/// ```
String tafqit(
  int number, {
  ArabicGender gender = ArabicGender.masculine,
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
}) =>
    tafqitBigInt(
      BigInt.from(number),
      gender: gender,
      grammaticalCase: grammaticalCase,
      hundredSpelling: hundredSpelling,
    );

/// Like [tafqit] for a [BigInt]. The magnitude must be below 10^21
/// (the largest scale word is كوينتليون, 10^18); otherwise an
/// [ArgumentError] is thrown.
String tafqitBigInt(
  BigInt number, {
  ArabicGender gender = ArabicGender.masculine,
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
}) {
  _checkRange(number);
  final ctx = _Ctx(grammaticalCase, hundredSpelling, OneTwoStyle.repeatNoun);
  if (number.isNegative) {
    return 'سالب ${_plain(-number, gender, ctx)}';
  }
  return _plain(number, gender, ctx);
}

/// Converts [number] to Arabic words followed by the counted noun, applying
/// the rules of التمييز:
///
/// - 1: noun then واحد/واحدة (دينار واحد); 2: the dual (ديناران).
/// - 3-10: plural noun (ثلاثة دنانير), number in the opposite gender.
/// - 11-99: singular accusative (أحد عشر دينارا).
/// - 100, 1000, ...: singular genitive, with a dual in إضافة
///   (مئتا دينار, ألفا دينار).
/// - Several parts: the last part governs (ألف ومئتان وخمسون دينارا).
/// - A trailing 1 or 2 after a larger part repeats the noun by default
///   (مئة دينار ودينار); see [OneTwoStyle].
String tafqitCounted(
  int number,
  ArabicNoun noun, {
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
  OneTwoStyle oneTwoStyle = OneTwoStyle.repeatNoun,
}) =>
    tafqitCountedBigInt(
      BigInt.from(number),
      noun,
      grammaticalCase: grammaticalCase,
      hundredSpelling: hundredSpelling,
      oneTwoStyle: oneTwoStyle,
    );

/// Like [tafqitCounted] for a [BigInt] below 10^21 in magnitude.
String tafqitCountedBigInt(
  BigInt number,
  ArabicNoun noun, {
  ArabicCase grammaticalCase = ArabicCase.nominative,
  HundredSpelling hundredSpelling = HundredSpelling.modern,
  OneTwoStyle oneTwoStyle = OneTwoStyle.repeatNoun,
}) {
  _checkRange(number);
  final ctx = _Ctx(grammaticalCase, hundredSpelling, oneTwoStyle);
  if (number.isNegative) {
    return 'سالب ${_counted(-number, noun, ctx)}';
  }
  return _counted(number, noun, ctx);
}

void _checkRange(BigInt number) {
  if (number.abs() >= _limit) {
    throw ArgumentError.value(
        number, 'number', 'Magnitude must be below 10^21');
  }
}

List<int> _groups(BigInt n) {
  final groups = <int>[];
  final thousand = BigInt.from(1000);
  var rest = n;
  while (rest > BigInt.zero) {
    groups.add((rest % thousand).toInt());
    rest = rest ~/ thousand;
  }
  return groups; // groups[0] is units, groups[1] thousands, ...
}

String _plain(BigInt n, ArabicGender gender, _Ctx ctx) {
  if (n == BigInt.zero) return 'صفر';
  final groups = _groups(n);
  final parts = <String>[];
  for (var i = groups.length - 1; i >= 0; i--) {
    final c = groups[i];
    if (c == 0) continue;
    if (i == 0) {
      parts.add(_unitsGroupPlain(c, gender, ctx));
    } else {
      parts.add(_scaleGroup(c, _scales[i - 1], ctx, construct: false));
    }
  }
  return parts.join(_and);
}

String _counted(BigInt n, ArabicNoun noun, _Ctx ctx) {
  if (n == BigInt.zero) return 'صفر ${nounPhrase(noun, NounForm.singular)}';
  final hundred = BigInt.from(100);
  final r = (n % hundred).toInt();
  final isWholeOneOrTwo = n == BigInt.from(r);

  if ((r == 1 || r == 2) && !isWholeOneOrTwo) {
    if (ctx.oneTwoStyle == OneTwoStyle.repeatNoun) {
      final repeated = r == 1
          ? nounPhrase(noun, _singularFor(ctx), bare: true)
          : nounPhrase(noun, _dualFor(ctx), bare: true);
      return '${_counted(n - BigInt.from(r), noun, ctx)}$_and$repeated';
    }
    return '${_plain(n, noun.gender, ctx)} '
        '${nounPhrase(noun, NounForm.singular)}';
  }
  if (r == 1 && isWholeOneOrTwo) {
    final one = noun.gender == ArabicGender.feminine
        ? 'واحدة'
        : (ctx.accusative ? 'واحدا' : 'واحد');
    return '${nounPhrase(noun, _singularFor(ctx))} $one';
  }
  if (r == 2 && isWholeOneOrTwo) {
    return nounPhrase(noun, _dualFor(ctx));
  }

  final groups = _groups(n);
  var lowest = 0;
  while (groups[lowest] == 0) {
    lowest++;
  }
  final parts = <String>[];
  for (var i = groups.length - 1; i >= 0; i--) {
    final c = groups[i];
    if (c == 0) continue;
    if (i == 0) {
      parts.add(_unitsGroupCounted(c, noun, ctx));
    } else {
      parts.add(_scaleGroup(c, _scales[i - 1], ctx, construct: i == lowest));
    }
  }
  final text = parts.join(_and);
  if (lowest > 0) {
    // Ends in a scale word: the noun is its singular genitive مضاف إليه.
    return '$text ${nounPhrase(noun, NounForm.singular)}';
  }
  return text;
}

NounForm _singularFor(_Ctx ctx) =>
    ctx.accusative ? NounForm.singularAccusative : NounForm.singular;

NounForm _dualFor(_Ctx ctx) =>
    ctx.nominative ? NounForm.dual : NounForm.dualAccusative;

/// 100..900 in words; [construct] drops the نون of مئتان (مئتا ألف).
String _hundreds(int h, _Ctx ctx, {required bool construct}) {
  final classical = ctx.hundredSpelling == HundredSpelling.classical;
  final mia = classical ? 'مائة' : 'مئة';
  if (h == 1) return mia;
  if (h == 2) {
    final stem = classical ? 'مائت' : 'مئت';
    if (construct) return ctx.nominative ? '$stemا' : '$stemي';
    return ctx.nominative ? '$stemان' : '$stemين';
  }
  return '${_hundredPrefixes[h - 3]}$mia';
}

String _unitsGroupPlain(int c, ArabicGender gender, _Ctx ctx) {
  final h = c ~/ 100;
  final r = c % 100;
  if (h == 0) return _below100(r, gender, ctx);
  final hundreds = _hundreds(h, ctx, construct: false);
  if (r == 0) return hundreds;
  return '$hundreds$_and${_below100(r, gender, ctx)}';
}

String _unitsGroupCounted(int c, ArabicNoun noun, _Ctx ctx) {
  final h = c ~/ 100;
  final r = c % 100;
  if (r == 0) {
    return '${_hundreds(h, ctx, construct: true)} '
        '${nounPhrase(noun, NounForm.singular)}';
  }
  final prefix = h == 0 ? '' : '${_hundreds(h, ctx, construct: false)}$_and';
  final number = '$prefix${_below100(r, noun.gender, ctx)}';
  if (r <= 10) return '$number ${nounPhrase(noun, NounForm.plural)}';
  return '$number ${nounPhrase(noun, NounForm.singularAccusative)}';
}

/// One group of a scale (thousands, millions, ...). [construct] is true when
/// a counted noun follows directly, so the scale word is مضاف.
String _scaleGroup(int c, _Scale s, _Ctx ctx, {required bool construct}) {
  final h = c ~/ 100;
  final r = c % 100;

  String single() =>
      (!construct && ctx.accusative) ? s.singularAccusative : s.singular;
  String dual() {
    final full = ctx.nominative ? s.dual : s.dualAccusative;
    return construct ? full.substring(0, full.length - 1) : full;
  }

  if (h == 0 && r == 1) return single();
  if (h == 0 && r == 2) return dual();
  if (r == 0) return '${_hundreds(h, ctx, construct: true)} ${s.singular}';
  if (r == 1 || r == 2) {
    // مئة ألف وألف, like "ألف ليلة وليلة".
    final head = '${_hundreds(h, ctx, construct: true)} ${s.singular}';
    return '$head$_and${r == 1 ? single() : dual()}';
  }
  final prefix = h == 0 ? '' : '${_hundreds(h, ctx, construct: false)}$_and';
  final number = '$prefix${_below100(r, ArabicGender.masculine, ctx)}';
  if (r <= 10) return '$number ${s.plural}';
  return '$number ${construct ? s.singular : s.singularAccusative}';
}

String _below100(int r, ArabicGender gender, _Ctx ctx) {
  final feminine = gender == ArabicGender.feminine;
  if (r <= 10) return _unit(r, feminine, ctx, inCompound: false);
  if (r == 11) return feminine ? 'إحدى عشرة' : 'أحد عشر';
  if (r == 12) {
    if (feminine) return ctx.nominative ? 'اثنتا عشرة' : 'اثنتي عشرة';
    return ctx.nominative ? 'اثنا عشر' : 'اثني عشر';
  }
  if (r < 20) {
    final unit = _unit(r - 10, feminine, ctx, inCompound: true);
    return '$unit ${feminine ? 'عشرة' : 'عشر'}';
  }
  final tensStem = _tensStems[r ~/ 10 - 2];
  final tens = '$tensStem${ctx.nominative ? 'ون' : 'ين'}';
  final u = r % 10;
  if (u == 0) return tens;
  return '${_unit(u, feminine, ctx, inCompound: true)}$_and$tens';
}

String _unit(int u, bool feminine, _Ctx ctx, {required bool inCompound}) {
  switch (u) {
    case 1:
      if (feminine) return inCompound ? 'إحدى' : 'واحدة';
      return ctx.accusative ? 'واحدا' : 'واحد';
    case 2:
      if (feminine) return ctx.nominative ? 'اثنتان' : 'اثنتين';
      return ctx.nominative ? 'اثنان' : 'اثنين';
    default:
      // Reversed gender: a feminine noun takes the form without ة.
      return feminine ? _unitsForFeminine[u - 3] : _unitsForMasculine[u - 3];
  }
}
