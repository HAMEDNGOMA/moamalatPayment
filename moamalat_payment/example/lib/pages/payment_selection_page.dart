import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';
import '../widgets/payment_amount_input.dart';
import '../widgets/payment_method_button.dart';
import '../widgets/payment_status_card.dart';
import '../widgets/sdk_availability_indicator.dart';

/// A page that demonstrates different payment methods available in the package.
///
/// This page provides a comprehensive interface for testing all payment methods:
/// - Automatic method selection (recommended)
/// - Forced SDK method (Android only)
/// - Forced WebView method (all platforms)
///
/// Features:
/// - Interactive payment amount input
/// - Real-time currency conversion display
/// - Payment method selection buttons
/// - Transaction status display
/// - SDK availability checking
/// - Proper error handling and user feedback
class PaymentSelectionPage extends StatefulWidget {
  /// Creates a payment selection page.
  const PaymentSelectionPage({super.key});

  @override
  State<PaymentSelectionPage> createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  /// Test merchant configuration.
  ///
  /// **Note**: Replace these with your actual merchant credentials.
  /// These values should be stored securely in production applications.
  static const String _merchantId = "10081014649";
  static const String _terminalId = "99179395";
  static const String _secureKey = "3a488a89b3f7993476c252f017c488bb";

  /// Current payment amount in Libyan Dinars.
  double _paymentAmount = 10.50;

  /// Current transaction result, if any.
  TransactionSucsses? _lastTransaction;

  /// Current error message, if any.
  String? _errorMessage;

  /// Last used payment method for display purposes.
  String? _lastPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moamalat Payment Methods'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Payment amount input section
              PaymentAmountInput(
                initialAmount: _paymentAmount,
                onAmountChanged: (newAmount) {
                  setState(() {
                    _paymentAmount = newAmount;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Payment method selection section
              Text(
                'Choose Payment Method:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Auto-select method (recommended)
              PaymentMethodButton(
                title: 'Auto-Select Method (Recommended)',
                subtitle: 'Automatically chooses the best available payment method',
                icon: Icons.auto_awesome,
                color: Colors.blue,
                onPressed: () => _navigateToPayment(null),
              ),
              const SizedBox(height: 12),

              // Force SDK method
              PaymentMethodButton(
                title: 'Force SDK Method',
                subtitle: 'Uses native Android SDK (Android only)',
                icon: Icons.phone_android,
                color: Colors.green,
                onPressed: () => _navigateToPayment(PaymentMethod.sdk),
              ),
              const SizedBox(height: 12),

              // Force WebView method
              PaymentMethodButton(
                title: 'Force WebView Method',
                subtitle: 'Uses WebView implementation (all platforms)',
                icon: Icons.web,
                color: Colors.orange,
                onPressed: () => _navigateToPayment(PaymentMethod.webview),
              ),
              const SizedBox(height: 24),

              // Payment status section
              if (_lastTransaction != null || _errorMessage != null) ...[
                Text(
                  'Last Transaction:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                PaymentStatusCard(
                  transaction: _lastTransaction,
                  errorMessage: _errorMessage,
                  paymentMethod: _lastPaymentMethod,
                  amount: _lastTransaction != null
                      ? _lastTransaction!.amount?.toString()
                      : CurrencyConverter.dinarToDirham(_paymentAmount),
                ),
                const SizedBox(height: 24),
              ],

              // SDK availability indicator
              const SdkAvailabilityIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to the payment flow with the specified method.
  ///
  /// [method] The payment method to use, or null for auto-selection.
  void _navigateToPayment(PaymentMethod? method) {
    // Clear previous results
    setState(() {
      _lastTransaction = null;
      _errorMessage = null;
      _lastPaymentMethod = method?.displayName ?? 'Auto-selected';
    });

    // Generate unique merchant reference for this transaction
    final merchantReference = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    // Convert payment amount to dirham string format
    final amountInDirham = CurrencyConverter.dinarToDirham(_paymentAmount);

    // Navigate to payment page
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MoamalatPaymentUnified(
          paymentMethod: method,
          merchantId: _merchantId,
          merchantReference: merchantReference,
          terminalId: _terminalId,
          amount: amountInDirham,
          merchantSecretKey: _secureKey,
          isTest: true, // Set to false for production
          loadingMessage: 'Processing your payment...',
          onCompleteSucsses: _handlePaymentSuccess,
          onError: _handlePaymentError,
        ),
      ),
    );
  }

  /// Handles successful payment completion.
  ///
  /// [transaction] The completed transaction details.
  void _handlePaymentSuccess(TransactionSucsses transaction) {
    Navigator.of(context).pop();
    setState(() {
      _lastTransaction = transaction;
      _errorMessage = null;
    });

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment successful! Reference: ${transaction.systemReference}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Handles payment errors.
  ///
  /// [error] The payment error details.
  void _handlePaymentError(PaymentError error) {
    Navigator.of(context).pop();
    setState(() {
      _lastTransaction = null;
      _errorMessage = error.error;
    });

    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${error.error}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}