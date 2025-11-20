import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indian_currency_input_formatter/indian_currency_input_formatter.dart';

void main() {
  group('IndianCurrencyInputFormatter', () {
    test('formats basic numbers', () {
      final formatter = IndianCurrencyInputFormatter();

      final oldValue = TextEditingValue.empty;
      final newValue = const TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 4),
      );

      final output = formatter.formatEditUpdate(oldValue, newValue);

      expect(output.text, '1,234');
    });

    test('handles decimal values properly', () {
      final formatter = IndianCurrencyInputFormatter();

      final oldValue = TextEditingValue.empty;
      final newValue = const TextEditingValue(
        text: '1234.56',
        selection: TextSelection.collapsed(offset: 7),
      );

      final output = formatter.formatEditUpdate(oldValue, newValue);

      expect(output.text, '1,234.56');
    });

    test('adds leading zero to .84', () {
      final formatter = IndianCurrencyInputFormatter();

      final newValue = const TextEditingValue(
        text: '.84',
        selection: TextSelection.collapsed(offset: 3),
      );

      final output = formatter.formatEditUpdate(TextEditingValue.empty, newValue);

      expect(output.text, '0.84');
    });

    test('restricts decimals to maxDecimals = 2', () {
      final formatter = IndianCurrencyInputFormatter(maxDecimals: 2);

      final newValue = const TextEditingValue(
        text: '12.3456',
        selection: TextSelection.collapsed(offset: 7),
      );

      final output = formatter.formatEditUpdate(TextEditingValue.empty, newValue);

      expect(output.text, '12.34'); // truncated
    });
  });
}
