import 'package:flutter/services.dart';

import 'caret_utils.dart';

enum SymbolPosition { prefix, suffix }

enum GroupingStyle { indian, international }

enum RoundingMode { truncate, round, floor, ceil }

class IndianCurrencyInputFormatter extends TextInputFormatter {
  const IndianCurrencyInputFormatter({
    this.maxDecimals = 2,
    this.maxIntegerDigits,
    this.allowNegative = false,
    this.allowTrailingDecimal = true,
    this.symbol = '₹',
    this.showSymbol = false,
    this.symbolPosition = SymbolPosition.prefix,
    this.groupingStyle = GroupingStyle.indian,
    this.separator = ',',
    this.strictMode = false,
    this.roundingMode = RoundingMode.truncate,
    this.minValue,
    this.maxValue,
  });

  final int maxDecimals;
  final int? maxIntegerDigits;
  final bool allowNegative;
  final bool allowTrailingDecimal;

  final String symbol;
  final bool showSymbol;
  final SymbolPosition symbolPosition;

  final GroupingStyle groupingStyle;
  final String separator;

  /// When true, invalid patterns are rejected and the old value is kept.
  final bool strictMode;

  /// How to behave when user tries to enter more than [maxDecimals].
  final RoundingMode roundingMode;

  /// Optional minimum/maximum allowed value.
  /// If user tries to go outside this range, the old value is kept.
  final num? minValue;
  final num? maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // IME / composing text: don't interfere – let the IME finish.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final oldText = oldValue.text;
    final rawNewText = _stripSymbolAndSeparators(newValue.text);

    // Strict mode: basic quick validation – reject obviously bad input.
    if (strictMode && !_isRawInputValid(rawNewText)) {
      return oldValue;
    }

    // If empty or just "-" or ".", allow as transitional states.
    if (rawNewText.isEmpty ||
        rawNewText == '-' && allowNegative ||
        rawNewText == '.') {
      final displayed = _applySymbolIfNeeded(rawNewText);
      return TextEditingValue(
        text: displayed,
        selection: TextSelection.collapsed(offset: displayed.length),
      );
    }

    // Apply core formatting.
    final formattedCore = _formatNumber(
      rawNewText,
      maxDecimals: maxDecimals,
      maxIntegerDigits: maxIntegerDigits,
      allowNegative: allowNegative,
      allowTrailingDecimal: allowTrailingDecimal,
      groupingStyle: groupingStyle,
      separator: separator,
      roundingMode: roundingMode,
    );

    // Enforce min/max if possible.
    final parsed = _tryParseRawToNum(rawNewText);
    if (parsed != null && (minValue != null || maxValue != null)) {
      if ((minValue != null && parsed < minValue!) ||
          (maxValue != null && parsed > maxValue!)) {
        // Reject and keep old value.
        return oldValue;
      }
    }

    final displayed = _applySymbolIfNeeded(formattedCore);

    final newSelection = calculateNewSelection(
      oldText: oldText,
      newText: newValue.text,
      formattedText: displayed,
      oldSelection: oldValue.selection,
      newSelection: newValue.selection,
      symbol: showSymbol ? symbol : '',
      symbolPosition: symbolPosition,
      separator: separator,
    );

    return TextEditingValue(
      text: displayed,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  /// Utility you can use from widgets: formats a numeric value programmatically.
  String formatFromNum(num? value, {bool allowNegativeZero = false}) {
    if (value == null) return '';
    var v = value;
    if (!allowNegative && v < 0) {
      v = 0;
    }
    // Normalize to maxDecimals.
    final fixed = v.toStringAsFixed(maxDecimals);
    final core = _formatNumber(
      fixed,
      maxDecimals: maxDecimals,
      maxIntegerDigits: maxIntegerDigits,
      allowNegative: allowNegative,
      allowTrailingDecimal: false,
      groupingStyle: groupingStyle,
      separator: separator,
      roundingMode: roundingMode,
    );
    return _applySymbolIfNeeded(core);
  }

  String _applySymbolIfNeeded(String text) {
    if (!showSymbol || text.isEmpty) return text;
    return symbolPosition == SymbolPosition.prefix
        ? '$symbol$text'
        : '$text$symbol';
  }

  String _stripSymbolAndSeparators(String s) {
    var out = s.replaceAll(symbol, '');
    if (separator.isNotEmpty) {
      out = out.replaceAll(separator, '');
    }
    out = out.replaceAll(' ', '');
    return out.trim();
  }

  bool _isRawInputValid(String input) {
    // Only digits, optional single leading '-', optional single '.'
    final minusCount = '-'.allMatches(input).length;
    if (minusCount > 1) return false;
    if (minusCount == 1 && !input.startsWith('-')) return false;

    final dotCount = '.'.allMatches(input).length;
    if (dotCount > 1) return false;

    // All other characters must be digits.
    final cleaned = input.replaceAll('-', '').replaceAll('.', '');
    if (!RegExp(r'^\d*$').hasMatch(cleaned)) return false;

    return true;
  }
}

/// Core formatting function (pure).
String _formatNumber(
  String input, {
  required int maxDecimals,
  required int? maxIntegerDigits,
  required bool allowNegative,
  required bool allowTrailingDecimal,
  required GroupingStyle groupingStyle,
  required String separator,
  required RoundingMode roundingMode,
}) {
  var raw = input;

  // Handle negative.
  var negative = false;
  if (raw.startsWith('-')) {
    if (allowNegative) {
      negative = true;
    }
    raw = raw.substring(1);
  }

  // Split into integer + decimal.
  final parts = raw.split('.');
  var intPart = parts.isNotEmpty ? parts[0] : '';
  var decPart = parts.length > 1 ? parts.sublist(1).join('.') : '';

  // Handle leading dot: ".84" -> "0.84"
  if (intPart.isEmpty && decPart.isNotEmpty) {
    intPart = '0';
  }

  // Remove non-digits.
  intPart = intPart.replaceAll(RegExp('[^0-9]'), '');
  decPart = decPart.replaceAll(RegExp('[^0-9]'), '');

  // Enforce max integer digits.
  if (maxIntegerDigits != null && intPart.length > maxIntegerDigits) {
    intPart = intPart.substring(0, maxIntegerDigits);
  }

  // Rounding/truncation logic if more decimals than allowed.
  if (decPart.length > maxDecimals) {
    switch (roundingMode) {
      case RoundingMode.truncate:
        decPart = decPart.substring(0, maxDecimals);
        break;
      case RoundingMode.floor:
      case RoundingMode.ceil:
      case RoundingMode.round:
        final sign = negative ? -1 : 1;
        final asNum = double.tryParse('$intPart.$decPart') ?? 0;
        final factor = MathPow10.of(maxDecimals);
        num rounded;
        switch (roundingMode) {
          case RoundingMode.round:
            rounded = (asNum * factor).round() / factor;
            break;
          case RoundingMode.floor:
            rounded = (asNum * factor).floor() / factor;
            break;
          case RoundingMode.ceil:
            rounded = (asNum * factor).ceil() / factor;
            break;
          case RoundingMode.truncate:
            rounded = (asNum * factor).truncate() / factor;
            break;
        }
        rounded *= sign;
        final fixed = rounded.toStringAsFixed(maxDecimals);
        final fixedParts = fixed.split('.');
        intPart = fixedParts[0].replaceAll('-', '');
        decPart = fixedParts.length > 1 ? fixedParts[1] : '';
        negative = rounded < 0;
        break;
    }
  }

  // Apply grouping.
  final grouped =
      _applyGrouping(intPart.isEmpty ? '0' : intPart, groupingStyle, separator);

  final buffer = StringBuffer();
  if (negative) buffer.write('-');
  buffer.write(grouped);

  if (decPart.isNotEmpty) {
    buffer.write('.');
    buffer.write(decPart);
  } else if (allowTrailingDecimal && raw.endsWith('.')) {
    buffer.write('.');
  }

  return buffer.toString();
}

String _applyGrouping(
  String digits,
  GroupingStyle style,
  String separator,
) {
  if (digits.isEmpty) return '';
  if (digits.length <= 3) return digits;

  if (style == GroupingStyle.international) {
    // 1234567 -> 1,234,567
    final buffer = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(separator);
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
  } else {
    // Indian: 12,34,56,789
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    final head = parts.join(separator);
    return '$head$separator$last3';
  }
}

num? _tryParseRawToNum(String raw) {
  if (raw.isEmpty || raw == '-' || raw == '.') return null;
  final s = raw == '.' ? '0' : raw;
  return num.tryParse(s);
}

/// Precomputed powers of 10 helper for rounding.
class MathPow10 {
  static final Map<int, num> _cache = {0: 1};

  static num of(int n) {
    if (_cache.containsKey(n)) return _cache[n]!;
    num result = 1;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    _cache[n] = result;
    return result;
  }
}
