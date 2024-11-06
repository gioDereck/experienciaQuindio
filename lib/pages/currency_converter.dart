import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/config/config.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String fromCurrency = 'COP';
  String toCurrency = 'USD';
  double result = 0.0;
  bool isLoading = false;
  double amount = 0.0;
  
  final List<Map<String, String>> currencies = Config().currencies;

  Future<void> convertCurrency() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please enter amount').tr(),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      amount = double.parse(_amountController.text);

      final response = await http.get(
        Uri.parse('${Config().url}/api/currency/convert?symbol=$fromCurrency&convert=$toCurrency&amount=$amount'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          result = data['data'][0]['quote'][toCurrency]['price'];
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error converting').tr(),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;

      convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color.fromARGB(255, 213, 240, 253)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('currency converter').tr(),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: easy.tr('importe'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixText: '\$ ',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCurrencyDropdown(
                            value: fromCurrency,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  fromCurrency = newValue;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_vert),
                            onPressed: _swapCurrencies,
                          ),
                          _buildCurrencyDropdown(
                            value: toCurrency,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  toCurrency = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : convertCurrency,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'convert'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (isLoading)
                            const CircularProgressIndicator()
                          else if (result > 0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'result',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ).tr(),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_amountController.text} $fromCurrency = ${result.toStringAsFixed(2)} $toCurrency',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items: currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency['code'],
              child: Row(
                children: [
                  Text(
                    currency['flag']!,
                    style: TextStyle(fontFamily: 'NotoColorEmoji'),
                  ),
                  const SizedBox(width: 8),
                  Text('${currency['code']} - ${easy.tr(currency['name']!)}'),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}