
The MoamalatPayment class is a Flutter widget that allows you to integrate the Moamalat payment gateway into your Flutter app. It provides a WebView that loads a Moamalat payment page with the transaction details to be processed. The class handles the response from the payment gateway and provides callback functions for handling successful transactions and errors. The class requires parameters such as merchantId, merchantReference, terminalId, amount, and merchantSecretKey to process the payment. The MoamalatPayment class is designed to work with Moamalat SDK in both test and production modes.

## Features

Integration with Moamalat Payment Gateway: The MoamalatPayment class allows you to easily integrate the Moamalat payment gateway into your Flutter app.

WebView Integration: The class provides a WebView that loads the Moamalat payment page with the transaction details to be processed.

Transaction Handling: The class handles the response from the payment gateway and provides callback functions for handling successful transactions and errors.

Test Mode Support: The MoamalatPayment class is designed to work with Moamalat SDK in both test and production modes.

Secure Transactions: The class generates a secure hash required by Moamalat to ensure secure transactions.

Customizable: The class is customizable and allows you to configure parameters such as merchantId, merchantReference, terminalId, amount, and merchantSecretKey to process the payment.

Overall, the MoamalatPayment class provides a convenient and secure way to integrate the Moamalat payment gateway into your Flutter app.
## Getting started
The MoamalatPayment class is a Flutter widget that allows you to integrate Moamalat payment gateway into your Flutter app. It provides a WebView that loads a Moamalat payment page with the details of the transaction to be processed. It then handles the response from the payment gateway and passes it to the appropriate callback.

Constructors
The MoamalatPayment class has one constructor that takes the following parameters:

merchantId: The merchant ID obtained from Moamalat.
merchantReference: A unique reference number for the transaction.
terminalId: The terminal ID obtained from Moamalat.
amount: The amount to be charged for the transaction.
merchantSecretKey: The secret key obtained from Moamalat.
onCompleteSucsses: A callback function that is called when the payment is completed successfully. This function takes a TransactionSucsses object as a parameter.
onError: A callback function that is called when an error occurs during the payment process. This function takes a PaymentError object as a parameter.
isTest: A boolean value that indicates whether the payment should be processed in test mode or production mode. The default value is false.
State
The MoamalatPayment class has a single state class _MoamalatPaymentState that extends the State class. It contains the logic for handling the WebView and processing the payment.

Methods
The MoamalatPayment class has two private methods:

checkTest(): This method sets the URL of the Moamalat payment page based on whether the payment is being processed in test mode or production mode.
hex2a(String hex): This method converts a hexadecimal string to ASCII.
The _MoamalatPaymentState class has three private methods:

getDateTimeLocalTrxnStr(): This method gets the current date and time in the format required by Moamalat.
encodeData(): This method encodes the transaction details in the format required by Moamalat.
hash(): This method generates the secure hash required by Moamalat.
Widgets
The MoamalatPayment class contains an InAppWebView widget that loads the Moamalat payment page. It also contains the InAppWebViewGroupOptions class that provides options for the WebView.

Callbacks
The MoamalatPayment class has two callback functions:

onCompleteSucsses: This callback function is called when the payment is completed successfully. It takes a TransactionSucsses object as a parameter.
onError: This callback function is called when an error occurs during the payment process. It takes a PaymentError object as a parameter.
Error Handling
The MoamalatPayment class handles errors by calling the onError function with a PaymentError object that contains details about the error.

Response Handling
The MoamalatPayment class handles the response from Moamalat by calling the onCompleteSucsses function with a TransactionSucsses object that contains details about the completed transaction.

## Usage
 import 'package:moamalat_payment/moamalat_payment.dart';


```dart
import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

class MoamalatPay extends StatefulWidget {
  const MoamalatPay({super.key});

  @override
  State<MoamalatPay> createState() => _MoamalatPayState();
}

class _MoamalatPayState extends State<MoamalatPay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MoamalatPayment(
        isTest:
            true, // Test SDK Mode - if you are working on production make it false
        merchantId: "10081014649", // put your merchantId
        merchantReference: "PS_Merchant",
        terminalId: "99179395", // put your terminalId
        amount:
            "1000", // get your amount from previos screen  Note: required  Integer number without any comma *1000
        //ex 1: if you need to recharge 10 dinnar  the amount will be 10 *1000
        //ex 2: if you need to recharge 10.5 dinnar the ammount will be 10500
        merchantSecretKey:
            "39636630633731362D663963322D346362642D386531662D633963303432353936373431", //put your merchantSecretKey
        // * make sure all value's are String *
        onCompleteSucsses: (value) {},
        onError: (error) {},
      ),
    );
  }
}
```

## Additional information
 get your amount from previos screen  Note: required  Integer number without any comma *1000
 ex 1: if you need to recharge 10 dinnar  the amount will be 10 *1000
 ex 2: if you need to recharge 10.5 dinnar the ammount will be 10500
 make sure all value's are String 
 make sure minSdkVersion 17 or higher
.
