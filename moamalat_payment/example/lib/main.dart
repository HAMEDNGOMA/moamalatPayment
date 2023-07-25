import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
