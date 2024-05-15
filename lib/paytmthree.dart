import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:paytm_routersdk/paytm_routersdk.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _txnToken = '';
  String _orderId = '';
  String _amount = '';
  bool _isProcessingPayment = false;
  String _result = '';

  Future<void> _initiatePayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Make a POST request to your backend API to initiate the payment
      final response = await http.post(
        Uri.parse('http://13.127.81.177:8000/pay/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": "Azhan", "amount": 432}),
      );

      if (response.statusCode == 200) {
        print("${response.statusCode}");
        final responseData = jsonDecode(response.body);
        setState(() {
          _txnToken = responseData['txnToken'];
          _orderId = responseData['orderId'];
          _amount = responseData['amount'];
        });

        // Use Paytm router SDK to start the payment transaction
        await _startPayment();
      } else {
        setState(() {
          _result = 'Failed to initiate payment';
        });
      }
    } catch (error) {
      setState(() {
        _result = 'Error: $error';
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<void> _startPayment() async {
    try {
      final response = await PaytmRouterSdk.startTransaction(
        "216820000000000014719",
        _orderId,
        _amount,
        _txnToken,
        "http://13.127.81.177:8000/callback/",
        true,
      );

      setState(() {
        _result = response.toString();
      });
    } catch (error) {
      setState(() {
        _result = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initiate Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                _initiatePayment();
              },
              child: _isProcessingPayment
                  ? const CircularProgressIndicator()
                  : const Text('Initiate Payment'),
            ),
            const SizedBox(height: 20),
            Text('Result: $_result'),
          ],
        ),
      ),
    );
  }
}

// initiate_payment.dart
