import 'package:flutter/services.dart';
import 'package:moamalat_payment/src/error_model.dart';
import 'package:moamalat_payment/src/sucsses_model.dart';

/// Native SDK service for Moamalat payment processing.
///
/// This service handles communication with the native Moamalat SDKs on both
/// Android and iOS platforms through platform method channels, providing a
/// clean Dart API for payment processing.
///
/// ## Features
/// - Direct integration with native Moamalat SDKs (Android & iOS)
/// - Optimized performance compared to WebView
/// - Native error handling and transaction callbacks
/// - Support for both card and wallet transactions
/// - Platform-specific UI and user experience
/// - Comprehensive error handling and validation
///
/// ## Usage
/// ```dart
/// final service = MoamalatSdkService();
/// try {
///   final result = await service.startPayment(
///     merchantId: "your_merchant_id",
///     terminalId: "your_terminal_id",
///     amount: 1000.0,
///     merchantReference: "REF123",
///     secureKey: "your_secure_key",
///   );
///   // Handle success
/// } catch (e) {
///   // Handle error
/// }
/// ```
class MoamalatSdkService {
  /// Method channel for communicating with native platform code (Android/iOS).
  static const MethodChannel _channel = MethodChannel('moamalat_payment/sdk');

  /// Starts a payment transaction using the native Moamalat SDK.
  ///
  /// This method initiates a payment flow by calling the native SDK
  /// (Android or iOS) and returns the transaction result through a Future.
  ///
  /// **Parameters:**
  /// - [merchantId]: Unique merchant identifier provided by Moamalat
  /// - [terminalId]: Terminal identifier associated with the merchant
  /// - [amount]: Payment amount (in LYD, will be converted to dirham internally)
  /// - [merchantReference]: Unique transaction reference for tracking
  /// - [secureKey]: Merchant's secret key for transaction signing
  /// - [currencyCode]: Currency code (default: 434 for LYD)
  /// - [isProduction]: Environment flag (true for production, false for testing)
  ///
  /// **Returns:**
  /// A [TransactionSucsses] object containing transaction details on success.
  ///
  /// **Throws:**
  /// - [PaymentError] if the transaction fails
  /// - [PlatformException] if there's a platform-specific error
  /// - [MissingPluginException] if the native SDK is not properly configured
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final result = await MoamalatSdkService.startPayment(
  ///     merchantId: "10081014649",
  ///     terminalId: "99179395",
  ///     amount: 10.50, // 10.50 LYD
  ///     merchantReference: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
  ///     secureKey: "your_secret_key",
  ///     isProduction: false,
  ///   );
  ///   print('Payment successful: ${result.systemReference}');
  /// } on PaymentError catch (e) {
  ///   print('Payment failed: ${e.error}');
  /// }
  /// ```
  static Future<TransactionSucsses> startPayment({
    required String merchantId,
    required String terminalId,
    required double amount,
    required String merchantReference,
    required String secureKey,
    String currencyCode = '434',
    bool isProduction = false,
  }) async {
    try {
      // Validate required parameters
      if (merchantId.isEmpty) {
        throw PaymentError(
          error: 'Merchant ID cannot be empty',
          amount: amount.toString(),
          merchantReference: merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        );
      }

      if (terminalId.isEmpty) {
        throw PaymentError(
          error: 'Terminal ID cannot be empty',
          amount: amount.toString(),
          merchantReference: merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        );
      }

      if (secureKey.isEmpty) {
        throw PaymentError(
          error: 'Secure key cannot be empty',
          amount: amount.toString(),
          merchantReference: merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        );
      }

      if (amount <= 0) {
        throw PaymentError(
          error: 'Amount must be greater than zero',
          amount: amount.toString(),
          merchantReference: merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        );
      }

      // Prepare arguments for native method call
      final Map<String, dynamic> arguments = {
        'merchantId': merchantId,
        'terminalId': terminalId,
        'secureKey': secureKey,
        'amount': amount,
        'merchantReference': merchantReference,
        'currencyCode': currencyCode,
        'isProduction': isProduction,
      };

      // Call native method
      final result = await _channel.invokeMethod('startPayment', arguments);

      // Parse result from platform channel

      // Parse the result - handle different Map types from platform channels
      if (result is Map) {
        // Convert to Map<String, dynamic> for safe access
        final resultMap = Map<String, dynamic>.from(result);
        final success = resultMap['success'] as bool? ?? false;
        // Check success flag from result

        if (success) {
          // Convert successful result to TransactionSucsses
          // Process successful transaction
          return _parseSuccessResult(resultMap);
        } else {
          // Handle error result
          // Process transaction error
          throw _parseErrorResult(
              resultMap, merchantReference, amount.toString());
        }
      } else {
        // Invalid result format received
        throw PaymentError(
          error:
              'Invalid response format from native SDK. Expected Map but got ${result.runtimeType}: $result',
          amount: amount.toString(),
          merchantReference: merchantReference,
          dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
          secureHash: '',
        );
      }
    } on PlatformException catch (e) {
      throw PaymentError(
        error: e.message ?? 'Platform error occurred',
        amount: amount.toString(),
        merchantReference: merchantReference,
        dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
        secureHash: '',
      );
    } on MissingPluginException {
      throw PaymentError(
        error:
            'Native SDK not configured. Please ensure the Moamalat SDK is properly set up in your Android project.',
        amount: amount.toString(),
        merchantReference: merchantReference,
        dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
        secureHash: '',
      );
    } catch (e) {
      if (e is PaymentError) {
        rethrow;
      }
      throw PaymentError(
        error: 'Unexpected error: ${e.toString()}',
        amount: amount.toString(),
        merchantReference: merchantReference,
        dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
        secureHash: '',
      );
    }
  }

  /// Parses a successful payment result from the native SDK.
  ///
  /// Converts the Map result from the native Android SDK into a
  /// [TransactionSucsses] object with proper type handling.
  ///
  /// [result] Map containing transaction success data from native SDK
  /// Returns a [TransactionSucsses] object with parsed transaction details
  static TransactionSucsses _parseSuccessResult(Map<String, dynamic> result) {
    // Parse successful transaction result

    // Parse amount safely - the native SDK might return it as String or Number
    double? amount;
    final amountValue = result['amount'];
    // Parse amount value with type checking

    if (amountValue != null) {
      if (amountValue is String) {
        amount = double.tryParse(amountValue);
      } else if (amountValue is num) {
        amount = amountValue.toDouble();
      }
    }
    // Amount parsed successfully

    final transaction = TransactionSucsses(
      txnDate: DateTime.now().toString(), // Current timestamp
      systemReference: result['networkReference']?.toString(),
      networkReference: result['networkReference']?.toString(),
      merchantReference: result['merchantReference']?.toString(),
      amount: amount, // Keep exact amount as returned by SDK
      currency: '434', // LYD currency code
      paidThrough: result['type']?.toString(), // 'card' or 'wallet'
      payerAccount:
          result['authCode']?.toString() ?? '', // Handle null authCode
      payerName: '', // Not provided by SDK
      providerSchemeName: 'Moamalat',
      secureHash: '', // Would need to be calculated if required
      displayData: 'Payment processed via Moamalat SDK',
      tokenCustomerId: '',
      tokenCard: '',
    );

    // Transaction object created successfully
    return transaction;
  }

  /// Parses an error result from the native SDK.
  ///
  /// Converts error information from the native Android SDK into a
  /// [PaymentError] object for consistent error handling.
  ///
  /// [result] Map containing error data from native SDK
  /// [merchantReference] Transaction reference for tracking
  /// [amount] Transaction amount for error context
  /// Returns a [PaymentError] object with parsed error details
  static PaymentError _parseErrorResult(
    Map<String, dynamic> result,
    String merchantReference,
    String amount,
  ) {
    final errorMessage = result['error']?.toString() ??
        result['message']?.toString() ??
        'Payment failed';

    return PaymentError(
      error: errorMessage,
      amount: amount,
      merchantReference: merchantReference,
      dateTimeLocalTrxn: DateTime.now().millisecondsSinceEpoch.toString(),
      secureHash: '',
    );
  }

  /// Checks if the native SDK is available and properly configured.
  ///
  /// This method can be used to verify that the native SDK (Android or iOS)
  /// is properly set up before attempting payment operations.
  ///
  /// Returns `true` if the SDK is available, `false` otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// if (await MoamalatSdkService.isAvailable()) {
  ///   // Use SDK method
  ///   final result = await MoamalatSdkService.startPayment(...);
  /// } else {
  ///   // Fallback to WebView or show error
  ///   print('Native SDK not available for this platform');
  /// }
  /// ```
  static Future<bool> isAvailable() async {
    try {
      await _channel.invokeMethod('isAvailable');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets version information from the native SDK.
  ///
  /// Returns version details for debugging and compatibility checking.
  /// Useful for troubleshooting and ensuring proper SDK integration.
  ///
  /// Returns a Map containing version information, or null if unavailable.
  ///
  /// **Example:**
  /// ```dart
  /// final version = await MoamalatSdkService.getVersion();
  /// print('SDK Version: ${version?['sdkVersion']}');
  /// ```
  static Future<Map<String, dynamic>?> getVersion() async {
    try {
      final result = await _channel.invokeMethod('getVersion');
      return result is Map<String, dynamic> ? result : null;
    } catch (e) {
      return null;
    }
  }
}
