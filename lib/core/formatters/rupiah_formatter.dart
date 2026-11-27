/// Formats whole-Rupiah integer amounts (`*_rp`) without floating-point math.
abstract final class RupiahFormatter {
  /// Formats [amountRp] as Indonesian Rupiah (e.g. `Rp 150.000` or `-Rp 50.000`).
  static String format(int amountRp) {
    final isNegative = amountRp < 0;
    final digits = amountRp.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}Rp $buffer';
  }
}
