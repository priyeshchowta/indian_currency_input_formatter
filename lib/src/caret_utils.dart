import 'package:flutter/services.dart';
import 'formatter_core.dart';

TextSelection calculateNewSelection({
  required String oldText,
  required String newText,
  required String formattedText,
  required TextSelection oldSelection,
  required TextSelection newSelection,
  required String symbol,
  required SymbolPosition symbolPosition,
  required String separator,
}) {
  // Based on "digits to the right" heuristic.
  final caretIndexInNew = newSelection.extentOffset.clamp(0, newText.length);

  final digitsRight = _countDigitsRight(
    text: newText,
    caretIndex: caretIndexInNew,
    separator: separator,
    symbol: symbol,
  );

  // Now walk formattedText from right and find where that many digits are to the right.
  int pos = formattedText.length;
  int seen = 0;
  while (pos > 0 && seen < digitsRight) {
    pos--;
    final ch = formattedText[pos];
    if (_isDigit(ch)) {
      seen++;
    }
  }

  var offset = pos;

  // Avoid putting cursor before symbol in prefix mode.
  if (symbol.isNotEmpty &&
      symbolPosition == SymbolPosition.prefix &&
      formattedText.startsWith(symbol) &&
      offset < symbol.length) {
    offset = symbol.length;
  }

  offset = offset.clamp(0, formattedText.length);

  return TextSelection.fromPosition(TextPosition(offset: offset));
}

bool _isDigit(String ch) =>
    ch.codeUnitAt(0) ^ 0x30 <= 9 && ch.codeUnitAt(0) ^ 0x30 >= 0;

int _countDigitsRight({
  required String text,
  required int caretIndex,
  required String separator,
  required String symbol,
}) {
  int count = 0;
  for (int i = caretIndex; i < text.length; i++) {
    final ch = text[i];
    if (ch == separator || ch == ' ' || ch == symbol) continue;
    if (_isDigit(ch)) count++;
  }
  return count;
}
