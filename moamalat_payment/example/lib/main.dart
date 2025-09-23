/// Example demonstrating how to use the MoamalatPayment widget
/// with and without the CurrencyConverter utility.
///
/// This example shows two approaches:
/// 1. Direct dirham amount (without converter)
/// 2. Converting from dinar to dirham (with converter)

import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moamalat Payment Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Moamalat Payment Example'),
    );
  }
}

/// Home page demonstrating MoamalatPayment usage with currency conversion examples
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // ========================================
    // CURRENCY CONVERSION EXAMPLES
    // ========================================
    
    // Example 1: Customer wants to pay 1 Libyan Dinar
    double customerDinarAmount1 = 1.0; // Customer enters 1 LYD
    String dirhamAmount1 = CurrencyConverter.dinarToDirham(customerDinarAmount1); // Converts to "1000" dirham
    
    // Example 2: Customer wants to pay 10.5 Libyan Dinars
    double customerDinarAmount2 = 10.5; // Customer enters 10.5 LYD
    String dirhamAmount2 = CurrencyConverter.dinarToDirham(customerDinarAmount2); // Converts to "10500" dirham
    
    // Example 3: Customer enters amount as string
    String customerDinarString = "25.750"; // Customer enters "25.750" LYD
    String dirhamAmount3 = CurrencyConverter.dinarStringToDirham(customerDinarString); // Converts to "25750" dirham
    
    // ========================================
    // CHOOSE YOUR APPROACH
    // ========================================
    
    // APPROACH 1: Use CurrencyConverter (RECOMMENDED for user-friendly apps)
    // - Customer works with familiar dinar amounts
    // - App automatically converts to dirham
    // - Better user experience
    String paymentAmount = dirhamAmount2; // Using converted amount (10.5 LYD = "10500" dirham)
    
    // APPROACH 2: Direct dirham amount (if you already have dirham)
    // - Use this if you already have the amount in dirham
    // - No conversion needed
    // String paymentAmount = "10500"; // Direct dirham amount
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Information panel showing conversion examples
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Currency Conversion Examples:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text('• 1.0 LYD → ${CurrencyConverter.formatDirhamAmount(dirhamAmount1)}'),
                Text('• 10.5 LYD → ${CurrencyConverter.formatDirhamAmount(dirhamAmount2)}'),
                Text('• 25.750 LYD → ${CurrencyConverter.formatDirhamAmount(dirhamAmount3)}'),
                const SizedBox(height: 8),
                Text(
                  'Current payment: ${CurrencyConverter.formatDinarAmount(customerDinarAmount2)} = ${CurrencyConverter.formatDirhamAmount(paymentAmount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // MoamalatPayment widget
          Expanded(
            child: MoamalatPayment(
              // Arabic loading message for Libyan users
              loadingMessage: "الرجاء الإنتظار جاري تحويلك لبوابة الدفع",
              
              // Environment setting
              isTest: true, // Set to false for production, true for testing
              
              // Merchant configuration (provided by Moamalat)
              merchantId: "YOUR_MERCHANT_ID", // Your merchant ID from Moamalat
              merchantReference: "PS_Merchant_${DateTime.now().millisecondsSinceEpoch}", // Unique reference for this transaction
              terminalId: "YOUR_TERMINAL_ID", // Your terminal ID from Moamalat
              
              // ========================================
              // AMOUNT PARAMETER - CRITICAL!
              // ========================================
              // The amount MUST be in dirham (smallest currency unit)
              // 
              // WITH CONVERTER (Recommended):
              // - Customer enters: 10.5 LYD
              // - You use: CurrencyConverter.dinarToDirham(10.5)
              // - Result: "10500" (dirham)
              // 
              // WITHOUT CONVERTER (Manual calculation):
              // - Customer enters: 10.5 LYD
              // - You manually calculate: 10.5 * 1000 = 10500
              // - You pass: "10500" (dirham)
              // 
              // WRONG EXAMPLES (DO NOT DO THIS):
              // - amount: "10.5" ❌ (This is dinar, not dirham)
              // - amount: "10,500" ❌ (Contains comma)
              // - amount: 10500 ❌ (Should be string, not number)
              //
              amount: paymentAmount, // "10500" dirham (converted from 10.5 LYD)
              
              // Security key (keep this secure!)
              merchantSecretKey: "YOUR_MERCHANT_SECRET_KEY", // Replace with your actual secret key
              
              // Payment completion callbacks
              onCompleteSucsses: (transaction) {
                // Payment successful!
                print('✅ Payment successful!');
                print('System Reference: ${transaction.systemReference}');
                print('Amount: ${transaction.amount} dirham');
                print('Equivalent: ${CurrencyConverter.formatDinarAmount(CurrencyConverter.dirhamToDinar(transaction.amount.toString()))}');
                
                // Show success message to user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment successful! Reference: ${transaction.systemReference}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              
              onError: (error) {
                // Payment failed!
                print('❌ Payment failed: ${error.error}');
                print('Amount: ${error.amount} dirham');
                
                // Show error message to user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment failed: ${error.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// CURRENCY CONVERSION GUIDE
// ========================================
//
// WHEN TO USE CurrencyConverter:
// ✅ When customers enter amounts in Libyan Dinars
// ✅ When you want user-friendly input (e.g., "10.5 LYD")
// ✅ When building customer-facing applications
// ✅ When you need to display formatted amounts
//
// WHEN NOT TO USE CurrencyConverter:
// ❌ When you already have the amount in dirham
// ❌ When integrating with systems that provide dirham amounts
// ❌ When the amount comes from APIs that return dirham values
//
// CONVERSION EXAMPLES:
// 
// WITH CurrencyConverter:
// double userAmount = 10.5; // User enters 10.5 LYD
// String paymentAmount = CurrencyConverter.dinarToDirham(userAmount); // "10500"
// 
// WITHOUT CurrencyConverter (manual):
// double userAmount = 10.5; // User enters 10.5 LYD
// String paymentAmount = (userAmount * 1000).toInt().toString(); // "10500"
//
// VALIDATION EXAMPLES:
//
// Validate dinar input:
// if (CurrencyConverter.isValidDinarAmount("10.5")) {
//   String dirham = CurrencyConverter.dinarStringToDirham("10.5");
// }
//
// Validate dirham input:
// if (CurrencyConverter.isValidDirhamAmount("10500")) {
//   // Amount is valid for payment
// }
//
// FORMATTING EXAMPLES:
//
// Format for display:
// String displayDinar = CurrencyConverter.formatDinarAmount(10.5); // "10.50 LYD"
// String displayDirham = CurrencyConverter.formatDirhamAmount("10500"); // "10,500 dirham"
//
// ========================================
