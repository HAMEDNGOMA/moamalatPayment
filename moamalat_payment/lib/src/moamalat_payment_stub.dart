import 'package:flutter/material.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// Stub implementation for unsupported platforms.
/// 
/// This class provides a fallback implementation when the platform
/// doesn't support the required features for payment processing.
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
    // Show error message for unsupported platforms
    return Container(
      color: Colors.red.shade50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Gateway Not Supported',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This platform does not support the Moamalat payment gateway. Please use a supported platform (Android, iOS, or Web).',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Trigger error callback
                  onError(PaymentError(
                    error: 'Platform not supported',
                    amount: amount,
                    merchantReference: merchantReference,
                    dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
                    secureHash: '',
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Report Error'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
