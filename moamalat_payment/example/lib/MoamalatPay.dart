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
