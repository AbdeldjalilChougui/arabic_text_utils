/// Grammatical gender of the counted noun (المعدود).
enum ArabicGender {
  /// مذكر, e.g. دينار, كتاب.
  masculine,

  /// مؤنث, e.g. ساعة, هللة.
  feminine,
}

/// Grammatical case (الإعراب) of the number phrase.
enum ArabicCase {
  /// مرفوع, e.g. اثنان, عشرون, مئتان.
  nominative,

  /// منصوب, e.g. اثنين, عشرين, مئتين, ألفا.
  accusative,

  /// مجرور, e.g. اثنين, عشرين, مئتين, ألف.
  genitive,
}

/// How the word for 100 is spelled.
enum HundredSpelling {
  /// مئة, مئتان, ثلاثمئة (modern spelling, the default).
  modern,

  /// مائة, مائتان, ثلاثمائة (older spelling, still common on cheques).
  classical,
}

/// How a counted noun is written when the number ends in 1 or 2 after a
/// larger part (101, 1002, ...).
enum OneTwoStyle {
  /// Repeat the noun, as in "ألف ليلة وليلة": مئة دينار ودينار,
  /// ألف دينار وديناران. This is the grammatical form and the default.
  repeatNoun,

  /// Keep the numeral: مئة وواحد دينار, ألف واثنان دينار. Common on
  /// cheques and invoices, but criticised by grammarians.
  numeral,
}

/// An adjective that follows a counted noun and agrees with it,
/// e.g. جزائري in دينار جزائري.
class ArabicAdjective {
  /// Creates an adjective from its inflected forms.
  const ArabicAdjective({
    required this.singular,
    required this.singularAccusative,
    required this.dual,
    required this.dualAccusative,
    required this.plural,
  });

  /// Singular, nominative or genitive: جزائري.
  final String singular;

  /// Singular accusative with tanween alef: جزائريا.
  final String singularAccusative;

  /// Dual nominative: جزائريان.
  final String dual;

  /// Dual accusative and genitive: جزائريين.
  final String dualAccusative;

  /// Form that agrees with the plural noun: جزائرية (a non-human plural
  /// takes a feminine singular adjective).
  final String plural;
}

/// A counted noun (المعدود) with the forms tafqit needs.
class ArabicNoun {
  /// Creates a noun from its inflected forms.
  const ArabicNoun({
    required this.singular,
    required this.singularAccusative,
    required this.dual,
    required this.dualAccusative,
    required this.plural,
    required this.gender,
    this.adjective,
  });

  /// Singular, nominative or genitive: دينار. Used after مئة / ألف.
  final String singular;

  /// Singular accusative with tanween alef: دينارا. Used after 11-99.
  final String singularAccusative;

  /// Dual nominative: ديناران.
  final String dual;

  /// Dual accusative and genitive: دينارين.
  final String dualAccusative;

  /// Plural (genitive after 3-10): دنانير.
  final String plural;

  /// Grammatical gender, which drives the gender of 1-19.
  final ArabicGender gender;

  /// Optional agreeing adjective, e.g. جزائري.
  final ArabicAdjective? adjective;
}

/// Internal form selector for [ArabicNoun] phrases.
enum NounForm {
  /// Singular genitive/nominative.
  singular,

  /// Singular accusative.
  singularAccusative,

  /// Dual nominative.
  dual,

  /// Dual accusative/genitive.
  dualAccusative,

  /// Plural.
  plural,
}

/// Renders [noun] in [form], with its adjective unless [bare] is true.
String nounPhrase(ArabicNoun noun, NounForm form, {bool bare = false}) {
  final adj = bare ? null : noun.adjective;
  String pick(String s, String sa, String d, String da, String p) =>
      switch (form) {
        NounForm.singular => s,
        NounForm.singularAccusative => sa,
        NounForm.dual => d,
        NounForm.dualAccusative => da,
        NounForm.plural => p,
      };
  final head = pick(noun.singular, noun.singularAccusative, noun.dual,
      noun.dualAccusative, noun.plural);
  if (adj == null) return head;
  return '$head ${pick(adj.singular, adj.singularAccusative, adj.dual, adj.dualAccusative, adj.plural)}';
}
