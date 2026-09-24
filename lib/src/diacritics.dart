/// TATWEEL (kashida), U+0640.
const String tatweel = '\u0640';

const int _shadda = 0x0651;

bool _isTashkeel(int c) =>
    (c >= 0x064B && c <= 0x0652) || // tanween, harakat, shadda, sukun
    (c >= 0x0656 && c <= 0x065F) || // subscript alef, other vowel marks
    c == 0x0670; // superscript (dagger) alef

bool _isQuranicMark(int c) =>
    (c >= 0x0610 && c <= 0x061A) || (c >= 0x06D6 && c <= 0x06ED);

/// Removes Arabic diacritics (tashkeel) from [text].
///
/// Removed by default: tanween, fatha, damma, kasra, shadda, sukun
/// (U+064B-U+0652), other vowel marks (U+0656-U+065F), the superscript
/// alef (U+0670) and the Quranic annotation marks U+0610-U+061A and
/// U+06D6-U+06ED.
///
/// The combining hamza and madda marks (U+0653-U+0655) are kept because
/// removing them from decomposed text would change the letter (أ, إ, آ).
///
/// Options: [keepShadda] keeps the shadda, [keepQuranicMarks] keeps the Quranic
/// annotation marks, [removeTatweel] also removes ـ.
String removeDiacritics(
  String text, {
  bool keepShadda = false,
  bool keepQuranicMarks = false,
  bool removeTatweel = false,
}) {
  final out = StringBuffer();
  for (final c in text.codeUnits) {
    if (_isTashkeel(c) && !(keepShadda && c == _shadda)) continue;
    if (!keepQuranicMarks && _isQuranicMark(c)) continue;
    if (removeTatweel && c == 0x0640) continue;
    out.writeCharCode(c);
  }
  return out.toString();
}

/// Removes tatweel (kashida, ـ) used to stretch Arabic words.
String removeTatweel(String text) => text.replaceAll(tatweel, '');

/// Whether [text] contains any tashkeel mark removed by [removeDiacritics].
/// Quranic annotation marks count unless [includeQuranicMarks] is false.
bool hasDiacritics(String text, {bool includeQuranicMarks = true}) {
  for (final c in text.codeUnits) {
    if (_isTashkeel(c)) return true;
    if (includeQuranicMarks && _isQuranicMark(c)) return true;
  }
  return false;
}
