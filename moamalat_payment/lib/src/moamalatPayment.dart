import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// A widget that displays a Moamalat payment form and handles payment callbacks
class MoamalatPayment extends StatefulWidget {
  final bool isTest;

  /// The ID of the merchant.
  final String merchantId;

  /// A unique reference for the transaction.
  final String merchantReference;

  /// The ID of the terminal.
  final String terminalId;

  /// The amount of the transaction.
  final String amount;

  /// The secret key of the merchant.
  final String merchantSecretKey;

  /// A callback function that is called when the payment is completed successfully.
  final void Function(TransactionSucsses transactionSucsses) onCompleteSucsses;

  /// A callback function that is called when an error occurs during the payment process.
  final void Function(PaymentError paymentError) onError;

  /// Creates a new MoamalatPayment widget.
  const MoamalatPayment({
    super.key,
    required this.merchantId,
    required this.merchantReference,
    required this.terminalId,
    required this.amount,
    required this.merchantSecretKey,
    required this.onCompleteSucsses,
    required this.onError,
    this.isTest = false,
  });

  /// The state for the MoamalatPayment widget.

  @override
  State<MoamalatPayment> createState() => _MoamalatPaymentState();
}

class _MoamalatPaymentState extends State<MoamalatPayment> {
  InAppWebViewController? controller;
  late String moamalatScriptWebPage;
  late String dateTime;
  late final String _url;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
  );

  /// Initializes the widget's state.
  @override
  void initState() {
    super.initState();
    checkTest();
    dateTime = getDateTimeLocalTrxnStr();
  }

  /// Determines the URL of the Moamalat payment script based on the `isTest` property.
  checkTest() {
    if (widget.isTest) {
      _url = "https://tnpg.moamalat.net:6006/js/lightbox.js";
    } else {
      _url = "https://npg.moamalat.net:6006/js/lightbox.js";
    }
  }

  /// Returns the current date and time in the format required by Moamalat.
  String getDateTimeLocalTrxnStr() {
    DateTime dateTimeLocalTrxn = DateTime.now();
    int dateTimeLocalTrxnSeconds =
        dateTimeLocalTrxn.millisecondsSinceEpoch ~/ 1000;
    String dateTimeLocalTrxnStr = dateTimeLocalTrxnSeconds.toString();
    return dateTimeLocalTrxnStr;
  }

  /// Encodes the payment data as a string for use in the hash calculation.

  String encodeData() {
    return 'Amount=${widget.amount}&DateTimeLocalTrxn=$dateTime&MerchantId=${widget.merchantId}&MerchantReference=${widget.merchantReference}&TerminalId=${widget.terminalId}';
  }

  /// Calculates the hash of the payment data using the merchant's secret key.
  String hash() {
    var key = hex2a(widget.merchantSecretKey);

    var msg = encodeData();
    var hmac = Hmac(sha256, utf8.encode(key));
    var hash = hmac.convert(utf8.encode(msg)).toString().toUpperCase();
    return '"$hash"';
  }

  /// Converts a hexadecimal string to an ASCII string.

  String hex2a(String hex) {
    var str = '';
    var i = 0;
    while (i < hex.length) {
      str += String.fromCharCode(int.parse(hex.substring(i, i + 2), radix: 16));
      i += 2;
    }
    return str;
  }

  /// Builds the widget's UI by displaying an InAppWebView that loads the Moamalat payment form
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
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
        MID: ${widget.merchantId},
        TID: ${widget.terminalId},
        AmountTrxn: ${widget.amount},
        MerchantReference: '${widget.merchantReference}',
        TrxDateTime: $dateTime,
        SecureHash: ${hash()},
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
      initialOptions: options,
      onWebViewCreated: (controller) {
        this.controller = controller;

        controller.addJavaScriptHandler(
            handlerName: 'error',
            callback: (args) {
              handleError(args[0]);
            });

        controller.addJavaScriptHandler(
            handlerName: 'sucsses',
            callback: (args) {
              handleComplete(args[0]);
            });
      },
      onLoadStart: (controller, url) {},
      onLoadStop: (controller, url) {},
      onProgressChanged: (controller, progress) {},
    );
  }

  TransactionSucsses handleComplete(String message) {
    Map<String, dynamic> successObject = json.decode(message);

    // Parse the response into a `Transaction` instance
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

    return transaction;
  }

  PaymentError? handleError(String consoleMessage) {
    try {
      /// Directly parse the JSON string into a Dart Map
      Map<String, dynamic> errorObject = json.decode(consoleMessage);

      // Now you can access the properties like error, Amount, MerchantReference, etc.
      String errorMessage = errorObject['error'];
      String amount = errorObject['Amount'];
      String merchantReference = errorObject['MerchantReferenece'];
      String dateTimeLocalTrxn = errorObject['DateTimeLocalTrxn'];
      String secureHash = errorObject['SecureHash'];

      /// Create a new PaymentError instance with the parsed data and return it
      widget.onError(PaymentError(
        error: errorMessage,
        amount: amount,
        merchantReference: merchantReference,
        dateTimeLocalTrxn: dateTimeLocalTrxn,
        secureHash: secureHash,
      ));
      return PaymentError(
        error: errorMessage,
        amount: amount,
        merchantReference: merchantReference,
        dateTimeLocalTrxn: dateTimeLocalTrxn,
        secureHash: secureHash,
      );
    } catch (e) {
      return null;

      /// Handle the error gracefully, for example, show an error message to the user
    }
  }
}
