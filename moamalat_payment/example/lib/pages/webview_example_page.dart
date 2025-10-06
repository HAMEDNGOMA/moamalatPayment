import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

/// A page demonstrating the original WebView-based payment implementation.
///
/// This page showcases the WebView payment method with comprehensive
/// currency conversion examples and best practices for user-friendly
/// payment amount handling.
///
/// **Features:**
/// - Currency conversion examples
/// - User-friendly amount input
/// - Comprehensive payment information display
/// - Arabic loading message support
/// - Detailed transaction feedback
///
/// **Use Cases:**
/// - Cross-platform payment consistency
/// - When native SDK is not available
/// - Web application support
/// - Fallback payment method
class WebViewExamplePage extends StatefulWidget {
  /// Creates a WebView example page.
  ///
  /// The [title] parameter is displayed in the app bar.
  const WebViewExamplePage({
    super.key,
    required this.title,
  });

  /// The title displayed in the app bar.
  final String title;

  @override
  State<WebViewExamplePage> createState() => _WebViewExamplePageState();
}

class _WebViewExamplePageState extends State<WebViewExamplePage> {
  /// Test merchant configuration.
  ///
  /// **Security Note:** Replace these with your actual credentials.
  /// In production, store these securely and never commit to version control.
  static const String _merchantId = "10081014649";
  static const String _terminalId = "99179395";
  static const String _secretKey = "3a488a89b3f7993476c252f017c488bb";

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // CURRENCY CONVERSION EXAMPLES
    // ==========================================

    // Example 1: Customer wants to pay 1 Libyan Dinar
    const double customerDinarAmount1 = 1.0; // Customer enters 1 LYD
    final String dirhamAmount1 = CurrencyConverter.dinarToDirham(
      customerDinarAmount1,
    ); // Converts to "1000" dirham

    // Example 2: Customer wants to pay 10.5 Libyan Dinars
    const double customerDinarAmount2 = 10.5; // Customer enters 10.5 LYD
    final String dirhamAmount2 = CurrencyConverter.dinarToDirham(
      customerDinarAmount2,
    ); // Converts to "10500" dirham

    // Example 3: Customer enters amount as string
    const String customerDinarString = "25.750"; // Customer enters "25.750" LYD
    final String dirhamAmount3 = CurrencyConverter.dinarStringToDirham(
      customerDinarString,
    ); // Converts to "25750" dirham

    // ==========================================
    // PAYMENT AMOUNT SELECTION
    // ==========================================

    // Use the converted amount for payment processing
    final String paymentAmount = dirhamAmount2; // Using 10.5 LYD = "10500" dirham

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Currency conversion information panel
          _buildCurrencyInfoPanel(
            context,
            dirhamAmount1: dirhamAmount1,
            dirhamAmount2: dirhamAmount2,
            dirhamAmount3: dirhamAmount3,
            customerDinarAmount2: customerDinarAmount2,
            paymentAmount: paymentAmount,
          ),

          // WebView payment widget
          Expanded(
            child: _buildPaymentWidget(
              paymentAmount: paymentAmount,
              customerDinarAmount2: customerDinarAmount2,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the currency conversion information panel.
  Widget _buildCurrencyInfoPanel(
    BuildContext context, {
    required String dirhamAmount1,
    required String dirhamAmount2,
    required String dirhamAmount3,
    required double customerDinarAmount2,
    required String paymentAmount,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Currency Conversion Examples',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Conversion examples
          _buildConversionExample(
            '1.0 LYD',
            CurrencyConverter.formatDirhamAmount(dirhamAmount1),
          ),
          _buildConversionExample(
            '10.5 LYD',
            CurrencyConverter.formatDirhamAmount(dirhamAmount2),
          ),
          _buildConversionExample(
            '25.750 LYD',
            CurrencyConverter.formatDirhamAmount(dirhamAmount3),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.payment, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[700],
                          ),
                      children: [
                        const TextSpan(
                          text: 'Current payment: ',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: CurrencyConverter.formatDinarAmount(customerDinarAmount2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' = '),
                        TextSpan(
                          text: CurrencyConverter.formatDirhamAmount(paymentAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single conversion example row.
  Widget _buildConversionExample(String input, String output) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Text('• '),
          Text(
            input,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Text(' → '),
          Text(
            output,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Builds the main payment widget with WebView implementation.
  Widget _buildPaymentWidget({
    required String paymentAmount,
    required double customerDinarAmount2,
  }) {
    return MoamalatPayment(
      // Custom loading message with Arabic support
      loadingMessage: "الرجاء الإنتظار جاري تحويلك لبوابة الدفع",

      // Environment configuration
      isTest: true, // Set to false for production

      // Merchant configuration (provided by Moamalat)
      merchantId: _merchantId,
      merchantReference: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
      terminalId: _terminalId,

      // ==========================================
      // AMOUNT PARAMETER - CRITICAL!
      // ==========================================
      // The amount MUST be in dirham (smallest currency unit)
      //
      // CORRECT APPROACH (using CurrencyConverter):
      // - Customer enters: 10.5 LYD
      // - You use: CurrencyConverter.dinarToDirham(10.5)
      // - Result: "10500" (dirham)
      //
      // INCORRECT EXAMPLES:
      // - amount: "10.5" ❌ (This is dinar, not dirham)
      // - amount: "10,500" ❌ (Contains comma)
      // - amount: 10500 ❌ (Should be string, not number)
      amount: paymentAmount, // "10500" dirham (converted from 10.5 LYD)

      // Security configuration
      merchantSecretKey: _secretKey,

      // Payment completion callbacks
      onCompleteSucsses: (transaction) {
        _handlePaymentSuccess(transaction, customerDinarAmount2);
      },
      onError: (error) {
        _handlePaymentError(error);
      },
    );
  }

  /// Handles successful payment completion.
  void _handlePaymentSuccess(
    TransactionSucsses transaction,
    double originalAmount,
  ) {
    // Show success feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Payment Successful!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Reference: ${transaction.systemReference}'),
            Text('Amount: ${transaction.amount} dirham'),
            Text(
              'Equivalent: ${CurrencyConverter.formatDinarAmount(
                CurrencyConverter.dirhamToDinar(transaction.amount.toString()),
              )}',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Handles payment errors.
  void _handlePaymentError(PaymentError error) {
    // Show error feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '❌ Payment Failed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Error: ${error.error}'),
            Text('Amount: ${error.amount} dirham'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}