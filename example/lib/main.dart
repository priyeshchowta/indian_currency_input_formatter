import 'package:flutter/material.dart';
import 'package:indian_currency_input_formatter/indian_currency_input_formatter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: DemoPage()));
  }
}

class DemoPage extends StatelessWidget {
  final formatter = const IndianCurrencyInputFormatter(showSymbol: true);

  DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [formatter],
            decoration: const InputDecoration(labelText: 'Amount'),
            onChanged: (s) {
              final val = parseIndianCurrency(s);
              // show parsed value in debug console
              debugPrint('parsed: $val');
            },
          ),
        ],
      ),
    );
  }
}
