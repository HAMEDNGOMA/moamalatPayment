import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// Web-compatible version of MoamalatPayment widget for WASM runtime.
///
/// This version uses dart:html instead of flutter_inappwebview to ensure
/// compatibility with WASM runtime. It provides the same functionality
/// as the native version but uses web-specific APIs.
///
/// ## Usage
/// ```dart
/// MoamalatPaymentWeb(
///   merchantId: "your_merchant_id",
///   merchantReference: "unique_transaction_ref",
///   terminalId: "your_terminal_id",
///   amount: "1000", // Amount in dirham
///   merchantSecretKey: "your_secret_key",
///   isTest: false,
///   loadingMessage: "Processing payment...",
///   onCompleteSucsses: (transaction) {
///     // Handle successful payment
///   },
///   onError: (error) {
///     // Handle payment error
///   },
/// )
/// ```
class MoamalatPaymentWeb extends StatefulWidget {
  /// Custom loading message displayed while the payment gateway initializes.
  final String? loadingMessage;

  /// Determines the environment for payment processing.
  final bool isTest;

  /// Unique identifier for the merchant account.
  final String merchantId;

  /// Unique reference for this specific transaction.
  final String merchantReference;

  /// Terminal identifier associated with the merchant account.
  final String terminalId;

  /// Transaction amount in dirham (smallest currency unit).
  final String amount;

  /// Merchant's secret key for transaction signing.
  final String merchantSecretKey;

  /// Callback invoked when payment completes successfully.
  final void Function(TransactionSucsses transactionSucsses) onCompleteSucsses;

  /// Callback invoked when payment fails or encounters an error.
  final void Function(PaymentError paymentError) onError;

  /// Creates a new MoamalatPaymentWeb widget for web/WASM compatibility.
  const MoamalatPaymentWeb({
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
  State<MoamalatPaymentWeb> createState() => _MoamalatPaymentWebState();
}

/// Private state class for [MoamalatPaymentWeb] widget.
class _MoamalatPaymentWebState extends State<MoamalatPaymentWeb> {
  late String dateTime;
  late final String _url;
  bool isLoading = true;
  html.IFrameElement? _iframeElement;

  @override
  void initState() {
    super.initState();
    checkTest();
    dateTime = getDateTimeLocalTrxnStr();
    _initializePayment();
  }

  @override
  void dispose() {
    _iframeElement?.remove();
    super.dispose();
  }

  /// Determines the payment gateway URL based on environment setting.
  void checkTest() {
    if (widget.isTest) {
      _url = "https://tnpg.moamalat.net:6006/js/lightbox.js";
    } else {
      _url = "https://npg.moamalat.net:6006/js/lightbox.js";
    }
  }

  /// Generates current timestamp in Unix epoch format.
  String getDateTimeLocalTrxnStr() {
    DateTime dateTimeLocalTrxn = DateTime.now();
    int dateTimeLocalTrxnSeconds =
        dateTimeLocalTrxn.millisecondsSinceEpoch ~/ 1000;
    String dateTimeLocalTrxnStr = dateTimeLocalTrxnSeconds.toString();
    return dateTimeLocalTrxnStr;
  }

  /// Encodes payment parameters into a query string format.
  String encodeData() {
    return 'Amount=${widget.amount}&DateTimeLocalTrxn=$dateTime&MerchantId=${widget.merchantId}&MerchantReference=${widget.merchantReference}&TerminalId=${widget.terminalId}';
  }

  /// Generates HMAC-SHA256 signature for transaction security.
  String hash() {
    // Convert hex key to bytes
    List<int> keyBytes = [];
    String hexKey = widget.merchantSecretKey;
    for (int i = 0; i < hexKey.length; i += 2) {
      keyBytes.add(int.parse(hexKey.substring(i, i + 2), radix: 16));
    }

    String msg = encodeData();
    var hmac = Hmac(sha256, keyBytes);
    var hash = hmac.convert(utf8.encode(msg)).toString().toUpperCase();
    return hash;
  }

  /// Initializes the payment interface using HTML iframe.
  void _initializePayment() {
    // Create HTML content for payment
    String htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moamalat Payment</title>
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
                    window.parent.postMessage({
                        type: 'payment_success',
                        data: JSON.stringify(data)
                    }, '*');
                },
                errorCallback: function (error) {
                    window.parent.postMessage({
                        type: 'payment_error',
                        data: JSON.stringify(error)
                    }, '*');
                },
                cancelCallback: function () {
                    window.parent.postMessage({
                        type: 'payment_cancel',
                        data: 'Payment cancelled'
                    }, '*');
                }
            };
            
            Lightbox.Checkout.showLightbox();
            
            // Notify parent that payment interface is ready
            window.parent.postMessage({
                type: 'payment_ready'
            }, '*');
        </script>
    </div>
</body>
</html>
    ''';

    // Create iframe element
    _iframeElement = html.IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..style.border = 'none'
      ..srcdoc = htmlContent;

    // Register the iframe as a platform view
    final String viewType = 'moamalat-payment-iframe-${widget.merchantReference}';
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => _iframeElement!,
    );

    // Listen for messages from iframe
    html.window.addEventListener('message', _handleMessage);

    setState(() {
      isLoading = false;
    });
  }

  /// Handles messages from the payment iframe.
  void _handleMessage(html.Event event) {
    if (event is html.MessageEvent) {
      final data = event.data;
      if (data is Map && data['type'] != null) {
        switch (data['type']) {
          case 'payment_success':
            _handleSuccess(data['data']);
            break;
          case 'payment_error':
            _handleError(data['data']);
            break;
          case 'payment_cancel':
            _handleCancel();
            break;
          case 'payment_ready':
            setState(() {
              isLoading = false;
            });
            break;
        }
      }
    }
  }

  /// Handles successful payment completion.
  void _handleSuccess(String message) {
    try {
      Map<String, dynamic> successObject = json.decode(message);

      TransactionSucsses transaction = TransactionSucsses(
        txnDate: successObject['TrxDateTime'],
        systemReference: successObject['SystemReference'],
        networkReference: successObject['NetworkReference'],
        merchantReference: successObject['MerchantReference'],
        amount: int.parse(successObject['Amount']),
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
    } catch (e) {
      _handleError('{"error": "Failed to parse success response", "Amount": "${widget.amount}", "MerchantReferenece": "${widget.merchantReference}", "DateTimeLocalTrxn": "$dateTime", "SecureHash": ""}');
    }
  }

  /// Handles payment errors and failures.
  void _handleError(String consoleMessage) {
    try {
      Map<String, dynamic> errorObject = json.decode(consoleMessage);

      PaymentError paymentError = PaymentError(
        error: errorObject['error'] ?? 'Unknown error',
        amount: errorObject['Amount'] ?? widget.amount,
        merchantReference: errorObject['MerchantReferenece'] ?? widget.merchantReference,
        dateTimeLocalTrxn: errorObject['DateTimeLocalTrxn'] ?? dateTime,
        secureHash: errorObject['SecureHash'] ?? '',
      );

      widget.onError(paymentError);
    } catch (e) {
      // Fallback error handling
      PaymentError paymentError = PaymentError(
        error: 'Payment processing failed',
        amount: widget.amount,
        merchantReference: widget.merchantReference,
        dateTimeLocalTrxn: dateTime,
        secureHash: '',
      );

      widget.onError(paymentError);
    }
  }

  /// Handles payment cancellation.
  void _handleCancel() {
    PaymentError paymentError = PaymentError(
      error: 'Payment cancelled by user',
      amount: widget.amount,
      merchantReference: widget.merchantReference,
      dateTimeLocalTrxn: dateTime,
      secureHash: '',
    );

    widget.onError(paymentError);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Payment iframe container
        if (_iframeElement != null && !isLoading)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: HtmlElementView(
              viewType: 'moamalat-payment-iframe-${widget.merchantReference}',
            ),
          ),

        // Loading indicator
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
    );
  }
}
