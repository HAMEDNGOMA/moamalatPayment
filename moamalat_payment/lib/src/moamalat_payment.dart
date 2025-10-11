import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// A Flutter widget that integrates Moamalat payment gateway for secure payment processing.
///
/// This widget provides a complete payment solution using Moamalat's payment gateway,
/// handling the entire payment flow from initialization to completion or error handling.
///
/// ## Features
/// - Secure payment processing through Moamalat gateway
/// - Support for both test and production environments
/// - Real-time payment status callbacks
/// - Automatic WebView cleanup and resource management
/// - Customizable loading messages with Arabic support
/// - Smooth navigation transitions
///
/// ## Usage
/// ```dart
/// MoamalatPayment(
///   merchantId: "your_merchant_id",
///   merchantReference: "unique_transaction_ref",
///   terminalId: "your_terminal_id",
///   amount: "1000", // Amount in smallest currency unit (dirham)
///   merchantSecretKey: "your_secret_key",
///   isTest: false, // Set to true for testing
///   loadingMessage: "Processing payment...",
///   onCompleteSucsses: (transaction) {
///     // Handle successful payment
///     print('Payment successful: ${transaction.systemReference}');
///   },
///   onError: (error) {
///     // Handle payment error
///     print('Payment failed: ${error.error}');
///   },
/// )
/// ```
///
/// ## Important Notes
/// - All monetary amounts should be in the smallest currency unit (dirham for LYD)
/// - 1 Libyan Dinar (LYD) = 1000 Libyan Dirham
/// - The merchant secret key should be stored securely and never exposed in client code
/// - Test mode should only be used during development
class MoamalatPayment extends StatefulWidget {
  /// Custom loading message displayed while the payment gateway initializes.
  ///
  /// Supports Arabic text for localized user experience.
  /// If null, defaults to "Loading Payment Gateway...".
  ///
  /// Example:
  /// ```dart
  /// loadingMessage: "الرجاء الإنتظار جاري تحويلك لبوابة الدفع"
  /// ```
  final String? loadingMessage;

  /// Determines the environment for payment processing.
  ///
  /// - `true`: Uses test environment (tnpg.moamalat.net:6006)
  /// - `false`: Uses production environment (npg.moamalat.net:6006)
  ///
  /// **Warning**: Always set to `false` for production releases.
  final bool isTest;

  /// Unique identifier for the merchant account.
  ///
  /// This is provided by Moamalat during merchant registration.
  /// Must be a valid merchant ID registered with Moamalat.
  ///
  /// Example: `"10038160862"`
  final String merchantId;

  /// Unique reference for this specific transaction.
  ///
  /// Should be unique for each payment attempt to avoid conflicts.
  /// Used for transaction tracking and reconciliation.
  ///
  /// Example: `"ORDER_${DateTime.now().millisecondsSinceEpoch}"`
  final String merchantReference;

  /// Terminal identifier associated with the merchant account.
  ///
  /// Provided by Moamalat during terminal setup.
  /// Links the transaction to a specific payment terminal.
  ///
  /// Example: `"93082651"`
  final String terminalId;

  /// Transaction amount in the smallest currency unit.
  ///
  /// For LYD (Libyan Dinar):
  /// - 1 LYD = 1000 dirham
  /// - For 10.500 LYD, pass "10500"
  /// - For 1 LYD, pass "1000"
  ///
  /// **Important**: Must be a string representation of an integer.
  final String amount;

  /// Merchant's secret key for transaction signing.
  ///
  /// **Security Warning**: This key should be:
  /// - Stored securely (preferably server-side)
  /// - Never committed to version control
  /// - Rotated regularly for security
  ///
  /// Used to generate HMAC-SHA256 signatures for transaction verification.
  final String merchantSecretKey;

  /// Callback invoked when payment completes successfully.
  ///
  /// Receives a [TransactionSucsses] object containing:
  /// - System reference number
  /// - Network reference
  /// - Transaction details
  /// - Payment method information
  ///
  /// Example:
  /// ```dart
  /// onCompleteSucsses: (transaction) {
  ///   print('Payment completed: ${transaction.systemReference}');
  ///   // Navigate to success page
  ///   Navigator.pushReplacement(context, SuccessPage(transaction));
  /// }
  /// ```
  final void Function(TransactionSucsses transactionSucsses) onCompleteSucsses;

  /// Callback invoked when payment fails or encounters an error.
  ///
  /// Receives a [PaymentError] object containing:
  /// - Error message
  /// - Transaction details
  /// - Failure reason
  ///
  /// Example:
  /// ```dart
  /// onError: (error) {
  ///   print('Payment failed: ${error.error}');
  ///   showDialog(context: context, builder: (_) => ErrorDialog(error));
  /// }
  /// ```
  final void Function(PaymentError paymentError) onError;

  /// Creates a new MoamalatPayment widget.
  ///
  /// All required parameters must be provided for proper payment processing.
  /// The widget will automatically handle the payment flow and invoke the
  /// appropriate callback based on the transaction result.
  ///
  /// **Important**: Ensure all required string parameters are not empty.
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
  State<MoamalatPayment> createState() => _MoamalatPaymentState();
}

/// Private state class for [MoamalatPayment] widget.
///
/// Manages the WebView lifecycle, payment flow, and transaction processing.
class _MoamalatPaymentState extends State<MoamalatPayment> {
  /// WebView controller for managing the payment interface.
  InAppWebViewController? controller;

  /// Placeholder for future use (currently unused).
  late String moamalatScriptWebPage;

  /// Transaction timestamp in Unix epoch format.
  late String dateTime;

  /// Payment gateway URL (test or production).
  late final String _url;

  /// Loading state indicator for the payment interface.
  bool isLoading = true;

  /// Visibility state for smooth navigation transitions.
  bool isWebViewVisible = true;

  /// WebView configuration optimized for payment processing.
  ///
  /// Key settings:
  /// - `useHybridComposition`: Ensures proper rendering on Android
  /// - `clearCache`: Prevents cached payment data
  /// - `cacheEnabled`: Disabled for security
  /// - `javaScriptEnabled`: Required for payment gateway
  /// - `domStorageEnabled`: Enables local storage for payment flow
  InAppWebViewSettings options = InAppWebViewSettings(
    useHybridComposition: true,
    clearCache: true,
    cacheEnabled: false,
    javaScriptEnabled: true,
    domStorageEnabled: true,
  );

  /// Initializes the payment widget state.
  ///
  /// Sets up the payment environment and generates transaction timestamp.
  @override
  void initState() {
    super.initState();
    checkTest();
    dateTime = getDateTimeLocalTrxnStr();
  }

  /// Cleans up WebView resources when the widget is disposed.
  ///
  /// Ensures proper cleanup to prevent memory leaks and security issues.
  /// Called automatically when the widget is removed from the widget tree.
  @override
  void dispose() {
    // Clean up WebView resources properly
    if (controller != null) {
      controller!.stopLoading();
    }
    controller?.dispose();
    super.dispose();
  }

  /// Determines the payment gateway URL based on environment setting.
  ///
  /// Sets [_url] to:
  /// - Test environment: `https://tnpg.moamalat.net:6006/js/lightbox.js`
  /// - Production environment: `https://npg.moamalat.net:6006/js/lightbox.js`
  void checkTest() {
    if (widget.isTest) {
      _url = "https://tnpg.moamalat.net:6006/js/lightbox.js";
    } else {
      _url = "https://npg.moamalat.net:6006/js/lightbox.js";
    }
  }

  /// Generates current timestamp in Unix epoch format for transaction identification.
  ///
  /// Returns a string representation of seconds since Unix epoch.
  /// This timestamp is used for transaction tracking and security hashing.
  ///
  /// Example return value: `"1640995200"` (represents 2022-01-01 00:00:00 UTC)
  String getDateTimeLocalTrxnStr() {
    DateTime dateTimeLocalTrxn = DateTime.now();
    int dateTimeLocalTrxnSeconds =
        dateTimeLocalTrxn.millisecondsSinceEpoch ~/ 1000;
    String dateTimeLocalTrxnStr = dateTimeLocalTrxnSeconds.toString();
    return dateTimeLocalTrxnStr;
  }

  /// Encodes payment parameters into a query string format for hash calculation.
  ///
  /// Creates a standardized string containing all transaction parameters
  /// in the format required by Moamalat's security specification.
  ///
  /// Returns a string in format:
  /// `"Amount=1000&DateTimeLocalTrxn=1640995200&MerchantId=123&MerchantReference=REF&TerminalId=456"`
  ///
  /// This encoded string is used as input for HMAC-SHA256 signature generation.
  String encodeData() {
    return 'Amount=${widget.amount}&DateTimeLocalTrxn=$dateTime&MerchantId=${widget.merchantId}&MerchantReference=${widget.merchantReference}&TerminalId=${widget.terminalId}';
  }

  /// Generates HMAC-SHA256 signature for transaction security.
  ///
  /// Creates a cryptographic signature using the merchant's secret key
  /// and encoded transaction data to ensure payment integrity.
  ///
  /// Process:
  /// 1. Converts hex-encoded secret key to bytes (or uses UTF-8 if not hex)
  /// 2. Encodes transaction data using [encodeData]
  /// 3. Generates HMAC-SHA256 hash
  /// 4. Returns uppercase hex string
  ///
  /// Returns: Uppercase hex string (e.g., "A1B2C3D4E5F6...")
  ///
  /// **Security Note**: This signature prevents tampering and ensures
  /// the payment request originates from an authorized merchant.
  String hash() {
    List<int> keyBytes = [];
    String hexKey = widget.merchantSecretKey;

    try {
      // Check if the key is a valid hex string
      if (_isValidHexString(hexKey)) {
        // Convert hex key to bytes
        for (int i = 0; i < hexKey.length; i += 2) {
          String hexPair = hexKey.substring(i, i + 2);
          keyBytes.add(int.parse(hexPair, radix: 16));
        }
      } else {
        // If not hex, use UTF-8 encoding of the key
        keyBytes = utf8.encode(hexKey);
      }
    } catch (e) {
      // Fallback: use UTF-8 encoding if hex parsing fails
      keyBytes = utf8.encode(hexKey);
    }

    String msg = encodeData();
    var hmac = Hmac(sha256, keyBytes);
    var hash = hmac.convert(utf8.encode(msg)).toString().toUpperCase();
    return hash;
  }

  /// Validates if a string is a valid hexadecimal string.
  ///
  /// Returns true if the string contains only valid hex characters (0-9, A-F, a-f)
  /// and has even length (required for proper byte conversion).
  bool _isValidHexString(String str) {
    // Must have even length for proper byte conversion
    if (str.length % 2 != 0) return false;

    // Check if all characters are valid hex
    final hexRegex = RegExp(r'^[0-9A-Fa-f]+$');
    return hexRegex.hasMatch(str);
  }

  /// Converts a hexadecimal string to ASCII text.
  ///
  /// Takes a hex-encoded string and converts each pair of hex digits
  /// to their corresponding ASCII character.
  ///
  /// Example:
  /// - Input: `"48656C6C6F"`
  /// - Output: `"Hello"`
  ///
  /// **Note**: Currently unused in the payment flow but kept for compatibility.
  ///
  /// [hex] The hexadecimal string to convert (must have even length)
  /// Returns the decoded ASCII string
  String hex2a(String hex) {
    var str = '';
    var i = 0;
    while (i < hex.length) {
      str += String.fromCharCode(int.parse(hex.substring(i, i + 2), radix: 16));
      i += 2;
    }
    return str;
  }

  /// Builds the payment interface using an embedded WebView.
  ///
  /// Creates a full-screen WebView that loads the Moamalat payment gateway
  /// with proper navigation handling and loading states.
  ///
  /// Features:
  /// - Smooth navigation transitions with [PopScope]
  /// - Loading indicator with customizable message
  /// - Automatic WebView cleanup on navigation
  /// - Responsive payment form interface
  ///
  /// The WebView loads an HTML page that:
  /// 1. Includes the Moamalat Lightbox JavaScript library
  /// 2. Configures payment parameters and callbacks
  /// 3. Displays the payment form interface
  /// 4. Handles success/error/cancel scenarios
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Hide the WebView immediately to prevent visual glitch
          setState(() {
            isWebViewVisible = false;
          });
          if (controller != null) {
            await controller!.stopLoading();
          }
        }
      },
      child: Stack(
        children: [
          Visibility(
            visible: isWebViewVisible,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: '''
     <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Load file or HTML string example</title>
    <style>
      html, body {
      width: 100%;
      height: 100%;
      margin: 0;
      padding: 0;
      overflow: hidden;
      }
      #lightbox {
      width: 100%;
      height: 100%;
      position: absolute;
      top: 0;
      left: 0;
      }
    </style>
    </head>
    
    <body>
    <div id="lightbox">
    
      <script src="$_url"></script>
        <script>
        Lightbox.Checkout.configure = {
          MID: '${widget.merchantId}',
          TID: '${widget.terminalId}',
          AmountTrxn: '${widget.amount}',
          MerchantReference: '${widget.merchantReference}',
          TrxDateTime: '$dateTime',
          SecureHash: '${hash()}',
          completeCallback: function (data) {
            window.flutter_inappwebview.callHandler('sucsses', JSON.stringify(data));
            window.complete.postMessage('Payment completed successfully');
          },
          errorCallback: function (error) {
            window.flutter_inappwebview.callHandler('error', JSON.stringify(error));
            console.log()
          },
          cancelCallback: function () {
            window.cancel.postMessage('Payment cancelled');
          }
        };
      
        Lightbox.Checkout.showLightbox();
        </script>
      </div>
      </body>
      </html>
        '''),
              initialSettings: options,
              onWebViewCreated: (controller) {
                this.controller = controller;

                // Clear any existing cache and data

                controller.addJavaScriptHandler(
                    handlerName: 'error',
                    callback: (args) {
                      handleError(args[0]);
                    });

                controller.addJavaScriptHandler(
                    handlerName: 'sucsses',
                    callback: (args) {
                      print("This is args received $args");
                      handleComplete(args[0]);
                    });
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {},
            ),
          ),
          // Loading indicator overlay
          if (isLoading)
            Container(
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
                      widget.loadingMessage ?? 'Loading Payment Gateway...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Handles successful payment completion from the WebView.
  ///
  /// Parses the JSON response from Moamalat's payment gateway and creates
  /// a [TransactionSucsses] object with all transaction details.
  ///
  /// **Response Data Includes:**
  /// - Transaction references (system, network, merchant)
  /// - Payment amount and currency
  /// - Payer information and payment method
  /// - Security hash for verification
  /// - Tokenization data (if applicable)
  ///
  /// [message] JSON string containing transaction success data
  /// Returns [TransactionSucsses] object with parsed transaction details
  ///
  /// **Note**: Automatically invokes [onCompleteSucsses] callback
  TransactionSucsses handleComplete(String message) {
    Map<String, dynamic> successObject = json.decode(message);

    // Parse the response into a `Transaction` instance
    TransactionSucsses transaction = TransactionSucsses(
      txnDate: successObject['TxnDate'],
      systemReference: successObject['SystemReference'],
      networkReference: successObject['NetworkReference'],
      merchantReference: successObject['MerchantReference'],
      amount: double.parse(successObject['Amount']),
      currency: successObject['Currency'],
      paidThrough: successObject['PaidThrough'],
      payerAccount: successObject['PayerAccount'],
      payerName: successObject['PayerName'],
      providerSchemeName: successObject['ProviderSchemeName'],
      secureHash: successObject['SecureHash'],
      displayData: successObject['DisplayData'],
      tokenCustomerId: successObject['TokenCustomerId'],
      tokenCard: successObject['TokenCard'],
    );

    widget.onCompleteSucsses(transaction);

    return transaction;
  }

  /// Handles payment errors and failures from the WebView.
  ///
  /// Parses error responses from Moamalat's payment gateway and creates
  /// a [PaymentError] object with failure details.
  ///
  /// **Error Data Includes:**
  /// - Error message describing the failure
  /// - Transaction amount and reference
  /// - Timestamp of the failed transaction
  /// - Security hash for verification
  ///
  /// **Common Error Scenarios:**
  /// - Invalid payment credentials
  /// - Insufficient funds
  /// - Network connectivity issues
  /// - Payment gateway timeouts
  /// - User cancellation
  ///
  /// [consoleMessage] JSON string containing error details from payment gateway
  /// Returns [PaymentError] object with parsed error data, or null if parsing fails
  ///
  /// **Note**: Automatically invokes [onError] callback when error is successfully parsed
  PaymentError? handleError(String consoleMessage) {
    try {
      // Parse the JSON error response
      Map<String, dynamic> errorObject = json.decode(consoleMessage);

      // Extract error details from the response
      String errorMessage = errorObject['error'];
      String amount = errorObject['Amount'];
      String merchantReference = errorObject['MerchantReferenece'];
      String dateTimeLocalTrxn = errorObject['DateTimeLocalTrxn'];
      String secureHash = errorObject['SecureHash'];

      // Create PaymentError instance with parsed data
      PaymentError paymentError = PaymentError(
        error: errorMessage,
        amount: amount,
        merchantReference: merchantReference,
        dateTimeLocalTrxn: dateTimeLocalTrxn,
        secureHash: secureHash,
      );

      // Notify the parent widget of the error
      widget.onError(paymentError);

      return paymentError;
    } catch (e) {
      // Return null if JSON parsing fails
      // This allows the calling code to handle malformed error responses
      return null;
    }
  }
}
