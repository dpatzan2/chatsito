/// Formats a raw digit string into groups of three: "612345678" -> "612 345 678".
String formatPhone(String digits) {
  if (digits.isEmpty) return '';
  final a = digits.substring(0, digits.length >= 3 ? 3 : digits.length);
  final b = digits.length > 3 ? digits.substring(3, digits.length >= 6 ? 6 : digits.length) : '';
  final c = digits.length > 6 ? digits.substring(6) : '';
  return [a, b, c].where((s) => s.isNotEmpty).join(' ');
}
