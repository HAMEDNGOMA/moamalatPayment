import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

/// A page demonstrating direct usage of the Moamalat SDK service.
///
/// This page shows advanced developers how to use the [MoamalatSdkService]
/// directly without the widget interface. This approach provides more control
/// over the payment flow but requires additional error handling.
///
/// **Use Cases:**
/// - Custom payment UI implementations
/// - Advanced integration scenarios
/// - Applications requiring direct SDK control
/// - Testing SDK functionality
///
/// **Note:** This approach bypasses the automatic method selection and
/// fallback mechanisms provided by [MoamalatPaymentUnified].
class DirectSdkExamplePage extends StatefulWidget {
  /// Creates a direct SDK example page.
  const DirectSdkExamplePage({super.key});

  @override
  State<DirectSdkExamplePage> createState() => _DirectSdkExamplePageState();
}

class _DirectSdkExamplePageState extends State<DirectSdkExamplePage> {
  /// Test merchant configuration.
  ///
  /// **Important:** Replace these with your actual merchant credentials.
  /// In production, these should be stored securely and not hardcoded.
  static const String _merchantId = "10081014649";
  static const String _terminalId = "99179395";
  static const String _secureKey = "3a488a89b3f7993476c252f017c488bb";

  /// Test payment amount in Libyan Dinars.
  ///
  /// **Note:** When using the SDK service directly, amounts are passed
  /// as double values in LYD. The service handles the conversion internally.
  static const double _testAmount = 5.75;

  /// Whether a payment operation is currently in progress.
  bool _isLoading = false;

  /// The result of the last payment attempt.
  String? _result;

  /// The last transaction details for successful payments.
  TransactionSucsses? _lastTransaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct SDK Usage'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                _buildHeaderSection(context),
                const SizedBox(height: 32),

                // Payment details section
                _buildPaymentDetailsSection(context),
                const SizedBox(height: 32),

                // Action button
                _buildActionButton(),
                const SizedBox(height: 24),

                // Result section
                if (_result != null) _buildResultSection(context),

                // SDK information section
                _buildSdkInfoSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and description.
  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Direct SDK Service Usage',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This example demonstrates how to use MoamalatSdkService directly '
              'without the widget interface. This approach provides more control '
              'but requires manual error handling and platform checking.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the payment details section.
  Widget _buildPaymentDetailsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Amount', CurrencyConverter.formatDinarAmount(_testAmount)),
            _buildDetailRow('Merchant ID', _merchantId),
            _buildDetailRow('Terminal ID', _terminalId),
            _buildDetailRow('Environment', 'Test Environment'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SDK accepts amounts in LYD directly (no conversion needed)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a detail row with label and value.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Builds the action button for starting payment.
  Widget _buildActionButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _startPaymentWithSdk,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Start Payment with SDK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Builds the result section showing payment outcome.
  Widget _buildResultSection(BuildContext context) {
    final isSuccess = _lastTransaction != null;
    final backgroundColor = isSuccess ? Colors.green[50] : Colors.red[50];
    final borderColor = isSuccess ? Colors.green[200] : Colors.red[200];

    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor!),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                ),
                const SizedBox(width: 8),
                Text(
                  isSuccess ? 'Payment Successful' : 'Payment Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green[800] : Colors.red[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _result!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the SDK information section.
  Widget _buildSdkInfoSection(BuildContext context) {
    return FutureBuilder<bool>(
      future: MoamalatSdkService.isAvailable(),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SDK Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: isAvailable ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable
                          ? 'Native SDK is available and ready'
                          : 'Native SDK is not available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Starts a payment using the SDK service directly.
  ///
  /// This method demonstrates the direct usage of [MoamalatSdkService.startPayment].
  /// It handles all aspects of the payment flow including loading states and errors.
  Future<void> _startPaymentWithSdk() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _lastTransaction = null;
    });

    try {
      // Call the SDK service directly
      final transaction = await MoamalatSdkService.startPayment(
        merchantId: _merchantId,
        terminalId: _terminalId,
        amount: _testAmount, // Amount in LYD - SDK handles conversion
        merchantReference: "SDK_${DateTime.now().millisecondsSinceEpoch}",
        secureKey: _secureKey,
        isProduction: false,
      );

      // Handle successful payment
      setState(() {
        _lastTransaction = transaction;
        _result = 'Payment completed successfully!\n'
            'Reference: ${transaction.systemReference}\n'
            'Amount: ${CurrencyConverter.formatDinarAmount(_testAmount)}\n'
            'Payment Type: ${transaction.paidThrough ?? 'Unknown'}';
      });
    } catch (e) {
      // Handle payment errors
      setState(() {
        _lastTransaction = null;
        _result = 'Payment failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
