import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'formatter_core.dart';
import 'parser.dart';

class IndianCurrencyFormField extends StatefulWidget {
  const IndianCurrencyFormField({
    super.key,
    this.controller,
    this.focusNode,
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
    this.fixOnFocusLost = true,
    this.validator,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.style,
    this.textAlign = TextAlign.start,
    this.textInputAction,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final int maxDecimals;
  final int? maxIntegerDigits;
  final bool allowNegative;
  final bool allowTrailingDecimal;
  final String symbol;
  final bool showSymbol;
  final SymbolPosition symbolPosition;
  final GroupingStyle groupingStyle;
  final String separator;
  final bool strictMode;
  final RoundingMode roundingMode;
  final num? minValue;
  final num? maxValue;

  /// If true, when the field loses focus, value will be normalized:
  /// - trailing "." removed
  /// - fully formatted
  final bool fixOnFocusLost;

  final String? Function(num? value)? validator;
  final void Function(num? value)? onChanged;

  final InputDecoration decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;

  @override
  State<IndianCurrencyFormField> createState() =>
      _IndianCurrencyFormFieldState();
}

class _IndianCurrencyFormFieldState extends State<IndianCurrencyFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final IndianCurrencyInputFormatter _formatter;
  late final IndianCurrencyInputFormatter _normalizeFormatter;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _formatter = IndianCurrencyInputFormatter(
      maxDecimals: widget.maxDecimals,
      maxIntegerDigits: widget.maxIntegerDigits,
      allowNegative: widget.allowNegative,
      allowTrailingDecimal: widget.allowTrailingDecimal,
      symbol: widget.symbol,
      showSymbol: widget.showSymbol,
      symbolPosition: widget.symbolPosition,
      groupingStyle: widget.groupingStyle,
      separator: widget.separator,
      strictMode: widget.strictMode,
      roundingMode: widget.roundingMode,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );

    _normalizeFormatter = IndianCurrencyInputFormatter(
      maxDecimals: widget.maxDecimals,
      maxIntegerDigits: widget.maxIntegerDigits,
      allowNegative: widget.allowNegative,
      allowTrailingDecimal: false, // no trailing "." on blur
      symbol: widget.symbol,
      showSymbol: widget.showSymbol,
      symbolPosition: widget.symbolPosition,
      groupingStyle: widget.groupingStyle,
      separator: widget.separator,
      strictMode: true,
      roundingMode: widget.roundingMode,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
    );

    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;

    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.fixOnFocusLost) {
      final text = _controller.text;
      if (text.isEmpty) return;

      final normalized = _normalizeFormatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );

      _controller.value = normalized;
      final value = parseIndianCurrency(normalized.text);
      widget.onChanged?.call(value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      inputFormatters: <TextInputFormatter>[_formatter],
      decoration: widget.decoration.copyWith(
        prefixText:
            widget.showSymbol && widget.symbolPosition == SymbolPosition.prefix
                ? '${widget.symbol} '
                : widget.decoration.prefixText,
        suffixText:
            widget.showSymbol && widget.symbolPosition == SymbolPosition.suffix
                ? ' ${widget.symbol}'
                : widget.decoration.suffixText,
      ),
      keyboardType: widget.keyboardType,
      style: widget.style,
      textAlign: widget.textAlign,
      textInputAction: widget.textInputAction,
      onChanged: (text) {
        final value = text.trim().isEmpty ? null : parseIndianCurrency(text);
        widget.onChanged?.call(value);
      },
      validator: (text) {
        final value = (text == null || text.trim().isEmpty)
            ? null
            : parseIndianCurrency(text);
        return widget.validator?.call(value);
      },
    );
  }
}
