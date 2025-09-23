<div align="center">

<img src="https://www.moamalat.net/MoamalatApi/Website/Custom/GetCustomerLogo?branchID=1" alt="Moamalat Logo" width="200"/>

# 🏦 Moamalat Payment Gateway

**The most comprehensive Flutter package for Moamalat payment integration**

[![pub package](https://img.shields.io/pub/v/moamalat_payment.svg?style=for-the-badge&color=blue)](https://pub.dev/packages/moamalat_payment)
[![MIT License](https://img.shields.io/badge/license-MIT-purple.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg?style=for-the-badge)](https://flutter.dev)
[![WASM Compatible](https://img.shields.io/badge/WASM-compatible-green.svg?style=for-the-badge)](https://dart.dev/web/wasm)

*Seamlessly integrate Moamalat payment gateway into your Flutter applications with support for Android, iOS, Web, and WASM platforms.*

</div>

---

## 🌟 Overview

**MoamalatPayment** is a powerful, feature-rich Flutter package that provides seamless integration with Libya's leading payment gateway. Built specifically for the Libyan market, it offers comprehensive payment processing capabilities with support for Libyan Dinar (LYD) transactions.

### 🎯 **Why Choose MoamalatPayment?**

- 🚀 **Multi-Platform Support**: Works flawlessly on Android, iOS, Web, and WASM
- 💱 **Currency Conversion**: Built-in Dinar ↔ Dirham conversion utilities
- 🔒 **Enterprise Security**: HMAC-SHA256 encryption and secure transaction handling
- 🌐 **Arabic Support**: Full RTL and Arabic language support
- 📱 **Responsive Design**: Optimized for all screen sizes and orientations
- 🎨 **Customizable UI**: Beautiful loading indicators and error handling
- 🔧 **Developer Friendly**: Comprehensive documentation and examples

## ✨ Features

### 🏗️ **Core Functionality**
- ✅ **Complete Payment Integration** - Full Moamalat gateway integration with real-time processing
- ✅ **Multi-Platform WebView** - Native WebView on mobile, HTML iframe on web/WASM
- ✅ **Transaction Management** - Comprehensive success/error handling with detailed callbacks
- ✅ **Environment Support** - Seamless switching between test and production modes

### 💰 **Currency & Localization**
- ✅ **Currency Conversion** - Built-in Libyan Dinar to Dirham converter with validation
- ✅ **Arabic Language Support** - Full RTL support with customizable Arabic messages
- ✅ **Amount Formatting** - Smart formatting with thousands separators and currency symbols
- ✅ **Input Validation** - Comprehensive validation for all payment parameters

### 🔐 **Security & Compliance**
- ✅ **HMAC-SHA256 Encryption** - Industry-standard transaction signing
- ✅ **Secure Key Management** - Protected merchant secret key handling
- ✅ **Transaction Integrity** - Tamper-proof payment verification
- ✅ **PCI Compliance Ready** - Secure payment processing standards

### 🎨 **User Experience**
- ✅ **Loading Indicators** - Beautiful, customizable loading screens
- ✅ **Smooth Navigation** - Optimized back button and navigation handling
- ✅ **Responsive Design** - Perfect display on all screen sizes
- ✅ **Error Handling** - User-friendly error messages and recovery options

### 🛠️ **Developer Experience**
- ✅ **WASM Compatible** - Works with WebAssembly for modern web deployment
- ✅ **Comprehensive Documentation** - Detailed guides, examples, and API reference
- ✅ **Type Safety** - Full Dart type safety with detailed model classes
- ✅ **Easy Integration** - Simple setup with minimal configuration required

## 🚀 Quick Start

### 📦 Installation

Add `moamalat_payment` to your `pubspec.yaml`:

```yaml
dependencies:
  moamalat_payment: ^1.0.1
```

Then run:
```bash
flutter pub get
```

### 📱 Platform Setup

#### Android
Ensure your `android/app/build.gradle` has:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 19  // Minimum required
        targetSdkVersion 34
    }
}
```

#### iOS
Ensure your `ios/Runner/Info.plist` includes:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

#### Web
No additional setup required! Works out of the box with WASM support.

### 🔑 Getting Your Credentials

1. **Contact Moamalat**: Reach out to Moamalat to get your merchant account
2. **Receive Credentials**: You'll get:
   - `merchantId` - Your unique merchant identifier
   - `terminalId` - Your terminal identifier
   - `merchantSecretKey` - Your secret key for transaction signing
3. **Test Environment**: Request test credentials for development

### ⚡ Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:moamalat_payment/moamalat_payment.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: MoamalatPayment(
        // Required parameters
        merchantId: "your_merchant_id",
        merchantReference: "ORDER_${DateTime.now().millisecondsSinceEpoch}", // this will be used as your reference to the transaction you can manage this string by any format
        terminalId: "your_terminal_id",
        amount: "1000", // 1 LYD in dirham
        merchantSecretKey: "your_secret_key",
        
        // Environment
        isTest: true, // Set to false for production
        
        // Localization
        loadingMessage: "الرجاء الإنتظار جاري تحويلك لبوابة الدفع",
        
        // Callbacks
        onCompleteSucsses: (transaction) {
          print('Payment successful: ${transaction.systemReference}');
          // Navigate to success screen
        },
        onError: (error) {
          print('Payment failed: ${error.error}');
          // Show error dialog
        },
      ),
    );
  }
}
```

## 💱 Currency Conversion

The package includes a powerful `CurrencyConverter` utility for handling Libyan Dinar to Dirham conversions:

### 🔄 **Basic Conversion**

```dart
import 'package:moamalat_payment/moamalat_payment.dart';

// Convert 10.5 LYD to dirham
String dirhamAmount = CurrencyConverter.dinarToDirham(10.5); // "10500"

// Use in payment
MoamalatPayment(
  amount: dirhamAmount, // "10500" dirham
  // ... other parameters
)
```

### 🎯 **Advanced Usage**

```dart
// Convert from string input
String userInput = "25.750";
if (CurrencyConverter.isValidDinarAmount(userInput)) {
  String dirham = CurrencyConverter.dinarStringToDirham(userInput); // "25750"
}

// Format for display
String formatted = CurrencyConverter.formatDinarAmount(10.5); // "10.50 LYD"
String dirhamFormatted = CurrencyConverter.formatDirhamAmount("10500"); // "10,500 dirham"

// Convert back for display
double dinarValue = CurrencyConverter.dirhamToDinar("10500"); // 10.5
```

### 📊 **Conversion Reference**

| Libyan Dinar (LYD) | Dirham | Usage |
|-------------------|---------|-------|
| 1.0 LYD | 1,000 dirham | `CurrencyConverter.dinarToDirham(1.0)` |
| 10.5 LYD | 10,500 dirham | `CurrencyConverter.dinarToDirham(10.5)` |
| 25.750 LYD | 25,750 dirham | `CurrencyConverter.dinarToDirham(25.750)` |

## 📚 Complete Usage Examples

### 🏪 **E-commerce Integration**

```dart
class CheckoutScreen extends StatefulWidget {
  final double totalAmount; // Amount in LYD
  final String orderId;
  
  const CheckoutScreen({
    required this.totalAmount,
    required this.orderId,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Payment'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Order summary
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Order Total: ${CurrencyConverter.formatDinarAmount(widget.totalAmount)}'),
                Text('Order ID: ${widget.orderId}'),
              ],
            ),
          ),
          
          // Payment widget
          Expanded(
            child: MoamalatPayment(
              merchantId: "your_merchant_id",
              merchantReference: widget.orderId, // this will be used as your reference to the transaction you can manage this string by any format
              terminalId: "your_terminal_id",
              amount: CurrencyConverter.dinarToDirham(widget.totalAmount),
              merchantSecretKey: "your_secret_key",
              isTest: false, // Production mode
              loadingMessage: "جاري معالجة الدفع...",
              
              onCompleteSucsses: (transaction) {
                // Payment successful
                _handlePaymentSuccess(transaction);
              },
              
              onError: (error) {
                // Payment failed
                _handlePaymentError(error);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _handlePaymentSuccess(TransactionSucsses transaction) {
    // Save transaction to database
    // Send confirmation email
    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          transaction: transaction,
          orderAmount: widget.totalAmount,
        ),
      ),
    );
  }
  
  void _handlePaymentError(PaymentError error) {
    // Log error
    // Show user-friendly error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Sorry, we couldn\'t process your payment. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
```

### 🎮 **Gaming/App Purchase**

```dart
class InAppPurchaseScreen extends StatelessWidget {
  final String itemName;
  final double itemPrice;
  
  const InAppPurchaseScreen({
    required this.itemName,
    required this.itemPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Purchase $itemName')),
      body: MoamalatPayment(
        merchantId: "your_merchant_id",
        merchantReference: "ORDER_${DateTime.now().millisecondsSinceEpoch}", // this will be used as your reference to the transaction you can manage this string by any format
        terminalId: "your_terminal_id",
        amount: CurrencyConverter.dinarToDirham(itemPrice),
        merchantSecretKey: "your_secret_key",
        isTest: true, // Test mode for development
        loadingMessage: "جاري تحضير عملية الشراء...",
        
        onCompleteSucsses: (transaction) {
          // Unlock premium features
          _unlockPremiumFeatures();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase successful! Enjoy your $itemName'),
              backgroundColor: Colors.green,
            ),
          );
        },
        
        onError: (error) {
          // Handle purchase failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
  
  void _unlockPremiumFeatures() {
    // Your premium feature unlock logic
  }
}
```

## 📖 API Reference

### 🏗️ **MoamalatPayment Widget**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `merchantId` | `String` | ✅ | Your merchant ID from Moamalat |
| `merchantReference` | `String` | ✅ | Unique transaction reference |
| `terminalId` | `String` | ✅ | Your terminal ID from Moamalat |
| `amount` | `String` | ✅ | Amount in dirham (smallest unit) |
| `merchantSecretKey` | `String` | ✅ | Your secret key for signing |
| `onCompleteSucsses` | `Function(TransactionSucsses)` | ✅ | Success callback |
| `onError` | `Function(PaymentError)` | ✅ | Error callback |
| `isTest` | `bool` | ❌ | Test mode (default: `false`) |
| `loadingMessage` | `String?` | ❌ | Custom loading message |

### 💱 **CurrencyConverter Utility**

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `dinarToDirham()` | `double dinar` | `String` | Convert dinar to dirham string |
| `dinarStringToDirham()` | `String dinar` | `String` | Convert dinar string to dirham |
| `dirhamToDinar()` | `String dirham` | `double` | Convert dirham to dinar |
| `isValidDinarAmount()` | `String amount` | `bool` | Validate dinar format |
| `isValidDirhamAmount()` | `String amount` | `bool` | Validate dirham format |
| `formatDinarAmount()` | `double amount` | `String` | Format dinar for display |
| `formatDirhamAmount()` | `String amount` | `String` | Format dirham for display |

### 📊 **Response Models**

#### **TransactionSucsses**
```dart
class TransactionSucsses {
  final String txnDate;
  final String systemReference;
  final String networkReference;
  final String merchantReference;
  final int amount;
  final String currency;
  final String paidThrough;
  final String payerAccount;
  final String payerName;
  final String providerSchemeName;
  final String secureHash;
  final String displayData;
  final String tokenCustomerId;
  final String tokenCard;
}
```

#### **PaymentError**
```dart
class PaymentError {
  final String error;
  final String amount;
  final String merchantReference;
  final String dateTimeLocalTrxn;
  final String secureHash;
}
```

## 🔧 Advanced Configuration

### 🌐 **Multi-Language Support**

```dart
// Arabic (RTL)
MoamalatPayment(
  loadingMessage: "الرجاء الإنتظار جاري تحويلك لبوابة الدفع",
  // ... other parameters
)

// English (LTR)
MoamalatPayment(
  loadingMessage: "Please wait, redirecting to payment gateway...",
  // ... other parameters
)
```

### 🔒 **Security Best Practices**

```dart
// ✅ DO: Store secret key securely
class SecureConfig {
  static const String merchantSecretKey = String.fromEnvironment('MOAMALAT_SECRET');
}

// ✅ DO: Generate unique references
String generateReference() {
  return "YOUR_UNIQUE_REFERENCE"; // Generate unique reference for each transaction
}

// ❌ DON'T: Hardcode secret keys in source code
// const String secretKey = "your_actual_secret_key"; // Never do this!
```

### ⚠️ **CRITICAL SECURITY WARNING**

**NEVER commit production credentials to version control!**

- ❌ **DON'T**: Include real `merchantId`, `terminalId`, or `merchantSecretKey` in your code
- ❌ **DON'T**: Push production credentials to GitHub or any public repository
- ✅ **DO**: Use environment variables or secure configuration files
- ✅ **DO**: Use placeholder values in examples and documentation
- ✅ **DO**: Keep production credentials in secure, encrypted storage

```dart
// ❌ WRONG - Never do this
merchantId: "10038160862", // Real production ID
merchantSecretKey: "real_secret_key_here", // Real secret

// ✅ CORRECT - Use placeholders in examples
merchantId: "YOUR_MERCHANT_ID", // Placeholder
merchantSecretKey: "YOUR_MERCHANT_SECRET_KEY", // Placeholder
```

### 🎨 **Custom Error Handling**

```dart
void handlePaymentError(PaymentError error, BuildContext context) {
  String userMessage;
  
  switch (error.error.toLowerCase()) {
    case 'insufficient funds':
      userMessage = 'عذراً، الرصيد غير كافي';
      break;
    case 'card expired':
      userMessage = 'البطاقة منتهية الصلاحية';
      break;
    case 'network error':
      userMessage = 'خطأ في الاتصال، يرجى المحاولة مرة أخرى';
      break;
    default:
      userMessage = 'حدث خطأ في عملية الدفع';
  }
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('فشل في الدفع'),
      content: Text(userMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('حسناً'),
        ),
      ],
    ),
  );
}
```

## 🌍 Platform Support

| Platform | Status | Technology | Notes |
|----------|--------|------------|-------|
| **Android** | ✅ Full Support | flutter_inappwebview | Requires minSdkVersion 19+ |
| **iOS** | ✅ Full Support | flutter_inappwebview | Requires iOS 11.0+ |
| **Web** | ✅ Full Support | HTML iframe | Works with all browsers |
| **WASM** | ✅ Full Support | HTML iframe | Future-ready web deployment |
| **Desktop** | ⚠️ Limited | Error fallback | Shows platform not supported |

## 🚨 Important Notes

### 💰 **Amount Format**
- ✅ **Correct**: `"1000"` (1 LYD in dirham)
- ✅ **Correct**: `CurrencyConverter.dinarToDirham(1.0)` → `"1000"`
- ❌ **Wrong**: `"1.0"` (This is dinar, not dirham)
- ❌ **Wrong**: `"1,000"` (Contains comma)
- ❌ **Wrong**: `1000` (Should be string, not number)

### 🔐 **Security Requirements**
- Store `merchantSecretKey` securely (environment variables, secure storage)
- Use unique `merchantReference` for each transaction
- Never expose secret keys in client-side code
- Always validate amounts before processing

### 🌐 **Environment Setup**
- Use `isTest: true` during development
- Switch to `isTest: false` for production
- Test thoroughly in both environments
- Monitor transaction logs

## 🆘 Troubleshooting

### Common Issues

**❓ "Platform not supported" error**
- **Solution**: Use Android, iOS, or Web. Desktop platforms show this message.

**❓ Payment gateway not loading**
- **Solution**: Check internet connection and ensure Moamalat URLs are accessible.

**❓ Invalid hash error**
- **Solution**: Verify your `merchantSecretKey` is correct and properly formatted.

**❓ Amount validation failed**
- **Solution**: Ensure amount is in dirham format (string of integers only).

### Getting Help

- 📧 **Email**: Contact Moamalat support
- 🐛 **Issues**: [GitHub Issues](https://github.com/HAMEDNGOMA/moamalatPayment/issues)
- 📖 **Documentation**: This comprehensive guide
- 💬 **Community**: Flutter Libya community

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ for the Libyan developer community**

*If this package helped you, please consider giving it a ⭐ on [GitHub](https://github.com/HAMEDNGOMA/moamalatPayment)!*

</div>
