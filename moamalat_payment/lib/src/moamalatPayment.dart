import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

class MoamalatPayment extends StatefulWidget {
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
    this.isTest = false,
  });

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

  @override
  void initState() {
    super.initState();
    checkTest();
    dateTime = getDateTimeLocalTrxnStr();
  }

  checkTest() {
    if (widget.isTest) {
      _url = "https://tnpg.moamalat.net:6006/js/lightbox.js";
    } else {
      _url = "https://npg.moamalat.net:6006/js/lightbox.js";
    }
  }

  String getDateTimeLocalTrxnStr() {
    DateTime dateTimeLocalTrxn = DateTime.now();
    int dateTimeLocalTrxnSeconds =
        dateTimeLocalTrxn.millisecondsSinceEpoch ~/ 1000;
    String dateTimeLocalTrxnStr = dateTimeLocalTrxnSeconds.toString();
    return dateTimeLocalTrxnStr;
  }

  String encodeData() {
    return 'Amount=${widget.amount}&DateTimeLocalTrxn=$dateTime&MerchantId=${widget.merchantId}&MerchantReference=${widget.merchantReference}&TerminalId=${widget.terminalId}';
  }

  String hash() {
    var key = hex2a(widget.merchantSecretKey);

    var msg = encodeData();
    var hmac = Hmac(sha256, utf8.encode(key));
    var hash = hmac.convert(utf8.encode(msg)).toString().toUpperCase();
    return '"$hash"';
  }

  String hex2a(String hex) {
    var str = '';
    var i = 0;
    while (i < hex.length) {
      str += String.fromCharCode(int.parse(hex.substring(i, i + 2), radix: 16));
      i += 2;
    }
    return str;
  }

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
              print("error from handler ");

              handleError(args[0]);

              // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
            });

        controller.addJavaScriptHandler(
            handlerName: 'sucsses',
            callback: (args) {
              print("sucsses from handler ");
              //  handleError(args[0]);
              handleComplete(args[0]);
              print(args);
              // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
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

    // Do something with the `Transaction` instance, for example, show a success message to the user
    return transaction;
  }

  PaymentError? handleError(String consoleMessage) {
    try {
      // Directly parse the JSON string into a Dart Map
      // Directly parse the JSON string into a Dart Map
      Map<String, dynamic> errorObject = json.decode(consoleMessage);

      // Now you can access the properties like error, Amount, MerchantReference, etc.
      String errorMessage = errorObject['error'];
      String amount = errorObject['Amount'];
      String merchantReference = errorObject['MerchantReferenece'];
      String dateTimeLocalTrxn = errorObject['DateTimeLocalTrxn'];
      String secureHash = errorObject['SecureHash'];

      // Create a new PaymentError instance with the parsed data and return it
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
      print('Error parsing JSON: $e');
      return null;
      // Handle the error gracefully, for example, show an error message to the user
    }
  }
}
