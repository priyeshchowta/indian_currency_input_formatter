# indian_currency_input_formatter

[![pub package](https://img.shields.io/pub/v/indian_currency_input_formatter.svg)](https://pub.dev/packages/indian_currency_input_formatter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A powerful, production-ready Flutter `TextInputFormatter` for Indian currency formatting (₹, lakh/crore grouping, decimals, caret-safe editing), built especially for fintech apps.

## Features

- ✅ **Indian Numbering System** - Supports lakh/crore formatting (e.g., 12,34,56,789)
- 💰 **Smart Formatting** - Auto-corrects input and maintains proper cursor position
- 🔄 **Decimal Support** - Configurable decimal places with smart handling
- ⚡ **High Performance** - Optimized for smooth typing experience
- 🎯 **Validation** - Built-in min/max value validation
- 🛡️ **Strict Mode** - Optionally reject invalid input
- 🔄 **Number Parsing** - Convert formatted strings back to numbers
- 🌍 **International Support** - Switch between Indian and International grouping
- 🎨 **Customizable** - Supports custom symbols, separators, and formatting options
- 📱 **Widget Included** - Comes with `IndianCurrencyFormField` for easy integration

## Installation

Add this to your project's `pubspec.yaml` file:

```yaml
dependencies:
  indian_currency_input_formatter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:indian_currency_input_formatter/indian_currency_input_formatter.dart';

TextField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    IndianCurrencyInputFormatter(),
  ],
)
```

### With Currency Symbol

```dart
IndianCurrencyInputFormatter(
  showSymbol: true,
  symbol: '₹',
  symbolPosition: SymbolPosition.prefix,
)
```

### With Validation

```dart
IndianCurrencyFormField(
  showSymbol: true,
  maxDecimals: 2,
  minValue: 1,
  maxValue: 500000,
  onChanged: (value) {
    print("Value: $value");
  },
  validator: (value) {
    if (value == null || value <= 0) return "Enter a valid amount";
    return null;
  },
)
```

## API Reference

### IndianCurrencyInputFormatter

| Parameter           | Type            | Default    | Description                          |
|---------------------|-----------------|------------|--------------------------------------|
| `maxDecimals`       | `int`           | `2`        | Maximum number of decimal digits     |
| `maxIntegerDigits`  | `int?`          | `null`     | Maximum integer digits allowed       |
| `allowNegative`     | `bool`          | `false`    | Whether to allow negative values     |
| `allowTrailingDecimal`| `bool`       | `true`     | Whether to allow trailing decimal    |
| `symbol`            | `String`        | `₹`        | Currency symbol to use               |
| `showSymbol`        | `bool`          | `false`    | Whether to show the currency symbol  |
| `symbolPosition`    | `SymbolPosition`| `prefix`   | Position of the currency symbol      |
| `groupingStyle`     | `GroupingStyle` | `indian`   | Number grouping style                |
| `separator`         | `String`        | `,`        | Thousand separator                   |
| `strictMode`        | `bool`          | `false`    | Whether to reject invalid input      |
| `roundingMode`      | `RoundingMode`  | `truncate` | How to handle decimal rounding       |
| `minValue`          | `num?`          | `null`     | Minimum allowed value                |
| `maxValue`          | `num?`          | `null`     | Maximum allowed value                |

### IndianCurrencyFormField

A ready-to-use form field with built-in validation and formatting.

## Examples

See the `example` directory for a complete example app.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue on the [GitHub repository](https://github.com/yourusername/indian_currency_input_formatter).
