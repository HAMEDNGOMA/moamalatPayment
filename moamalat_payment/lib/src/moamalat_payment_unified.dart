import 'package:flutter/material.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';
import 'package:moamalat_payment/src/payment_method.dart';
import 'package:moamalat_payment/src/moamalat_sdk_service.dart';
import 'package:moamalat_payment/src/currency_converter.dart';
import 'package:moamalat_payment/src/moamalat_payment.dart' as webview_impl;

/// Unified Moamalat payment widget supporting both SDK and WebView methods.
///
/// This widget provides a single interface for integrating Moamalat payments
/// with automatic method selection or manual override. It handles both
/// native SDK and WebView implementations seamlessly.
///
/// ## Features
/// - Automatic payment method selection based on platform capability
/// - Manual override for payment method selection
/// - Unified error handling across both implementations
/// - Consistent callback interface
/// - Fallback mechanism for unsupported platforms
/// - Loading state management
///
/// ## Usage
///
/// ### Automatic Method Selection (Recommended)
/// ```dart
/// MoamalatPaymentUnified(
///   merchantId: "your_merchant_id",
///   merchantReference: "unique_ref",
///   terminalId: "your_terminal_id",
///   amount: "1000", // Amount in dirham
///   merchantSecretKey: "your_secret_key",
///   onCompleteSucsses: (transaction) {
///     print('Payment successful: ${transaction.systemReference}');
///   },
///   onError: (error) {
///     print('Payment failed: ${error.error}');
///   },
/// )
/// ```
///
/// ### Manual Method Selection
/// ```dart
/// MoamalatPaymentUnified(
///   paymentMethod: PaymentMethod.sdk, // Force SDK usage
///   merchantId: "your_merchant_id",
///   // ... other parameters
/// )
/// ```
///
/// ## Payment Method Selection Logic
/// 1. If `paymentMethod` is specified, use that method
/// 2. If on Android and SDK is available, use SDK
/// 3. Otherwise, fallback to WebView
/// 4. If neither is available, show error state
class MoamalatPaymentUnified extends StatefulWidget {
  /// Payment method to use (optional - auto-selects if not provided).
  ///
  /// When null, the widget automatically selects the best available method:
  /// - SDK on Android (if available)
  /// - WebView on other platforms or as fallback
  final PaymentMethod? paymentMethod;

  /// Custom loading message displayed during payment initialization.
  ///
  /// Shown while determining payment method or initializing payment flow.
  /// Supports Arabic text for localized user experience.
  final String? loadingMessage;

  /// Determines the environment for payment processing.
  ///
  /// - `true`: Uses test environment
  /// - `false`: Uses production environment (default)
  final bool isTest;

  /// Unique identifier for the merchant account.
  ///
  /// Provided by Moamalat during merchant registration.
  final String merchantId;

  /// Unique reference for this specific transaction.
  ///
  /// Must be unique for each payment attempt to avoid conflicts.
  final String merchantReference;

  /// Terminal identifier associated with the merchant account.
  ///
  /// Provided by Moamalat during terminal setup.
  final String terminalId;

  /// Transaction amount in dirham (smallest currency unit).
  ///
  /// For LYD: 1 LYD = 1000 dirham
  /// Example: "10500" for 10.5 LYD
  final String amount;

  /// Merchant's secret key for transaction signing.
  ///
  /// **Security Warning**: Store securely and never commit to version control.
  final String merchantSecretKey;

  /// Callback invoked when payment completes successfully.
  ///
  /// Receives transaction details including references and payment info.
  final void Function(TransactionSucsses transactionSucsses) onCompleteSucsses;

  /// Callback invoked when payment fails or encounters an error.
  ///
  /// Receives error details including failure reason and context.
  final void Function(PaymentError paymentError) onError;

  /// Creates a unified Moamalat payment widget.
  ///
  /// All required parameters must be provided. The payment method will be

  /// automatically selected unless explicitly specified.
  final Widget? buildSdkWidget;
  const MoamalatPaymentUnified({
    super.key,
    this.paymentMethod,
    required this.merchantId,
    required this.merchantReference,
    required this.terminalId,
    required this.amount,
    required this.merchantSecretKey,
    required this.onCompleteSucsses,
    required this.onError,
    this.loadingMessage,
    this.isTest = false,
    this.buildSdkWidget,
  });

  @override
  State<MoamalatPaymentUnified> createState() => _MoamalatPaymentUnifiedState();
}

class _MoamalatPaymentUnifiedState extends State<MoamalatPaymentUnified> {
  /// Current payment method being used.
  PaymentMethod? _selectedMethod;

  /// Loading state for method determination.
  bool _isInitializing = true;

  /// Error state if no payment method is available.
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializePaymentMethod();
  }

  /// Determines and initializes the appropriate payment method.
  ///
  /// Logic:
  /// 1. Use explicitly specified method if provided
  /// 2. Check SDK availability on Android
  /// 3. Fallback to WebView
  /// 4. Set error if no method available
  Future<void> _initializePaymentMethod() async {
    try {
      if (widget.paymentMethod != null) {
        // Use explicitly specified method
        final method = widget.paymentMethod!;
        if (method.isAvailable) {
          if (method == PaymentMethod.sdk) {
            // Additional check for SDK availability
            final isAvailable = await MoamalatSdkService.isAvailable();
            if (isAvailable) {
              _selectedMethod = PaymentMethod.sdk;
            } else {
              // SDK not properly configured, fallback to WebView
              _selectedMethod = PaymentMethod.webview;
            }
          } else {
            _selectedMethod = method;
          }
        } else {
          _initializationError =
              'Specified payment method (${method.displayName}) is not available on this platform';
        }
      } else {
        // Auto-select best available method
        if (PaymentMethod.sdk.isAvailable) {
          // Check if SDK is actually configured
          final isAvailable = await MoamalatSdkService.isAvailable();
          if (isAvailable) {
            _selectedMethod = PaymentMethod.sdk;
          } else {
            _selectedMethod = PaymentMethod.webview;
          }
        } else if (PaymentMethod.webview.isAvailable) {
          _selectedMethod = PaymentMethod.webview;
        } else {
          _initializationError =
              'No payment methods available on this platform';
        }
      }
    } catch (e) {
      _initializationError =
          'Failed to initialize payment method: ${e.toString()}';
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  /// Handles SDK payment execution.
  ///
  /// Converts the widget parameters to the format expected by the SDK service
  /// and executes the payment transaction.
  Future<void> _executeSdkPayment() async {
    try {
      // Convert amount string from dirham to LYD using CurrencyConverter
      final amountInLyd = CurrencyConverter.dirhamToDinar(widget.amount);

      final result = await MoamalatSdkService.startPayment(
        merchantId: widget.merchantId,
        terminalId: widget.terminalId,
        amount: amountInLyd,
        merchantReference: widget.merchantReference,
        secureKey: widget.merchantSecretKey,
        isProduction: !widget.isTest,
      );

      widget.onCompleteSucsses(result);
    } catch (e) {
      if (e is PaymentError) {
        widget.onError(e);
      } else {
        widget.onError(PaymentError(
          error: 'SDK payment failed: ${e.toString()}',
          amount: widget.amount,
          merchantReference: widget.merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show initialization loading
    if (_isInitializing) {
      return _buildLoadingWidget('Initializing payment method...');
    }

    // Show initialization error
    if (_initializationError != null) {
      return _buildErrorWidget(_initializationError!);
    }

    // Show payment method specific widget
    switch (_selectedMethod!) {
      case PaymentMethod.sdk:
        return widget.buildSdkWidget ?? _buildSdkWidget();
      case PaymentMethod.webview:
        return _buildWebViewWidget();
    }
  }

  /// Builds the SDK payment widget.
  ///
  /// For SDK payments, we show a native-looking interface and handle
  /// the payment execution programmatically.
  Widget _buildSdkWidget() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.payment,
                  size: 40,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 24),

              // Payment details
              Text(
                'Moamalat Payment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure payment processing via native SDK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Amount display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      CurrencyConverter.formatDinarAmount(
                        CurrencyConverter.dirhamToDinar(widget.amount),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pay now button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _executeSdkPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Secured by Moamalat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the WebView payment widget.
  ///
  /// Delegates to the existing WebView implementation.
  Widget _buildWebViewWidget() {
    return webview_impl.MoamalatPayment(
      merchantId: widget.merchantId,
      merchantReference: widget.merchantReference,
      terminalId: widget.terminalId,
      amount: widget.amount,
      merchantSecretKey: widget.merchantSecretKey,
      onCompleteSucsses: widget.onCompleteSucsses,
      onError: widget.onError,
      loadingMessage: widget.loadingMessage,
      isTest: widget.isTest,
    );
  }

  /// Builds a loading widget with custom message.
  Widget _buildLoadingWidget(String message) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an error widget for initialization failures.
  Widget _buildErrorWidget(String error) {
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
                'Payment Initialization Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onError(PaymentError(
                    error: error,
                    amount: widget.amount,
                    merchantReference: widget.merchantReference,
                    dateTimeLocalTrxn:
                        DateTime.now().millisecondsSinceEpoch.toString(),
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
