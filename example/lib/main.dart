import 'package:flutter/material.dart';
import 'package:indian_currency_input_formatter/indian_currency_input_formatter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indian Currency Formatter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _formattedAmountController = TextEditingController();
  final _customFormatController = TextEditingController();

  num? _parsedValue;
  bool _showIndianFormat = true;

  final _basicFormatter = const IndianCurrencyInputFormatter(showSymbol: true);
  final _customFormatter = IndianCurrencyInputFormatter(
    showSymbol: true,
    symbol: '₹',
    maxDecimals: 3,
    allowNegative: true,
    minValue: -1000000,
    maxValue: 1000000,
  );

  @override
  void dispose() {
    _amountController.dispose();
    _formattedAmountController.dispose();
    _customFormatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Currency Formatter'),
        actions: [
          IconButton(
            icon:
                Icon(_showIndianFormat ? Icons.language : Icons.currency_rupee),
            onPressed: () {
              setState(() {
                _showIndianFormat = !_showIndianFormat;
              });
            },
            tooltip: _showIndianFormat
                ? 'Switch to International Format'
                : 'Switch to Indian Format',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Usage
              _buildSectionTitle('Basic Usage'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_basicFormatter],
                decoration: const InputDecoration(
                  labelText: 'Enter Amount',
                  hintText: '1,23,456.78',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                onChanged: (value) {
                  setState(() {
                    _parsedValue = parseIndianCurrency(value);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Parsed Value Display
              if (_parsedValue != null) ...[
                Text(
                  'Parsed Value: ${_parsedValue!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Formatted: ${_formatNumber(_parsedValue ?? 0)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 40),
              ],

              // Custom Formatter
              _buildSectionTitle('Custom Formatter'),
              TextFormField(
                controller: _customFormatController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [_customFormatter],
                decoration: const InputDecoration(
                  labelText: 'Amount with Validation (-1,000,000 to 1,000,000)',
                  hintText: '-50,000.50',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final val = parseIndianCurrency(value);
                  if (val < -1000000 || val > 1000000) {
                    return 'Amount must be between -1,000,000 and 1,000,000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Formatted Display
              _buildSectionTitle('Format Existing Number'),
              TextFormField(
                controller: _formattedAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Enter a number to format',
                  hintText: '1234567.89',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final number =
                      double.tryParse(_formattedAmountController.text);
                  if (number != null) {
                    final formatted = _formatNumber(number);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Formatted: $formatted'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Format Number'),
              ),

              // Toggle Format
              const SizedBox(height: 24),
              _buildSectionTitle('Toggle Format Style'),
              Text(
                _showIndianFormat
                    ? 'Current Format: Indian (e.g., 12,34,56,789.00)'
                    : 'Current Format: International (e.g., 123,456,789.00)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  IndianCurrencyInputFormatter(
                    showSymbol: true,
                    groupingStyle: _showIndianFormat
                        ? GroupingStyle.indian
                        : GroupingStyle.international,
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'Try typing here',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Form is valid!')),
            );
          }
        },
        label: const Text('Validate Form'),
        icon: const Icon(Icons.check_circle),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _formatNumber(num value) {
    final formatter = IndianCurrencyInputFormatter(
      showSymbol: true,
      symbol: '₹',
      maxDecimals: 2,
    );
    final textEditingValue = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: value.toString()),
    );
    return textEditingValue.text;
  }
}
