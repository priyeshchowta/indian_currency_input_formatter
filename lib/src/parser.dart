/// Parse a formatted Indian currency string to [num].
/// Accepts strings like:
/// - "1,23,456.78"
/// - "₹1,23,456.78"
/// - "-12,34,567"
num parseIndianCurrency(String formatted) {
  if (formatted.trim().isEmpty) return 0;

  var s = formatted.trim();
  s = s.replaceAll('₹', '');
  s = s.replaceAll(',', '');
  s = s.replaceAll(' ', '');

  if (s.endsWith('.')) {
    s = s.substring(0, s.length - 1);
  }

  return num.parse(s);
}
