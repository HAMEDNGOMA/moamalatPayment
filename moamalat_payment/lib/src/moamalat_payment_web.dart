import 'package:flutter/material.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// Web-compatible version of MoamalatPayment widget.
///
/// Currently shows a development message. Full web support will be added in a future version.
class MoamalatPayment extends StatelessWidget {
  final String? loadingMessage;
  final bool isTest;
  final String merchantId;
  final String merchantReference;
  final String terminalId;
  final String amount;
  final String merchantSecretKey;
  final void Function(TransactionSucsses transactionSucsses) onCompleteSucsses;
  final void Function(PaymentError paymentError) onError;

  const MoamalatPayment({
    super.key,
    required this.merchantId,
    required this.merchantReference,
    required this.terminalId,
    required this.amount,
    required this.merchantSecretKey,
    required this.onCompleteSucsses,
    required this.onError,
    this.loadingMessage,
    this.isTest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.web,
                size: 64,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Web Support Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Full web support for Moamalat payment gateway is currently in development. Please use Android or iOS for now.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Trigger error callback to indicate web not supported yet
                  onError(PaymentError(
                    error: 'Web support coming soon',
                    amount: amount,
                    merchantReference: merchantReference,
                    dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
                    secureHash: '',
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Acknowledge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
