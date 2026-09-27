/// A full UK postcode, upper case with one space before the inward code,
/// e.g. `WA1 1UH`.
extension type const Postcode._(String value) {
  static final _pattern = RegExp(r'^([A-Z]{1,2}\d[A-Z\d]?)(\d[A-Z]{2})$');

  /// Accepts any case and spacing; returns null unless [input] is a full
  /// postcode.
  static Postcode? tryParse(String input) {
    final compact = input.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final match = _pattern.firstMatch(compact);
    return match == null ? null : Postcode._('${match[1]} ${match[2]}');
  }
}
