/// A class representing an error that occurs during the Moamalat payment process.
///
/// This model encapsulates all error information returned by the Moamalat payment
/// gateway or SDK when a transaction fails. It provides structured access to
/// error details and transaction context for debugging and user feedback.
///
/// ## Usage Example
/// ```dart
/// onError: (PaymentError error) {
///   print('Payment failed: ${error.error}');
///   print('Amount: ${error.amount}');
///   print('Reference: ${error.merchantReference}');
///
///   // Handle specific error types
///   if (error.error?.contains('timeout') == true) {
///     // Handle timeout scenario
///   } else if (error.error?.contains('insufficient') == true) {
///     // Handle insufficient funds
///   }
/// }
/// ```
///
/// ## Error Types
/// Common error scenarios include:
/// - Network connectivity issues
/// - Invalid payment credentials
/// - Insufficient funds
/// - Transaction timeouts
/// - Invalid amount formats
/// - Merchant configuration issues
class PaymentError {
  /// The primary error message describing what went wrong.
  ///
  /// This field contains a human-readable description of the error that occurred
  /// during the payment process. It can be used for logging, debugging, or
  /// displaying user-friendly error messages.
  ///
  /// Examples:
  /// - "Payment was declined by the issuing bank"
  /// - "Network timeout occurred"
  /// - "Invalid merchant credentials"
  /// - "Insufficient funds"
  final String? error;

  /// The payment amount that was being processed when the error occurred.
  ///
  /// This field contains the amount in dirham (smallest currency unit) that was
  /// being processed when the error happened. Useful for transaction reconciliation
  /// and error analysis.
  ///
  /// Format: String representation of dirham amount (e.g., "10500" for 10.5 LYD)
  final String? amount;

  /// The unique merchant reference for the failed transaction.
  ///
  /// This is the same reference that was provided when initiating the payment.
  /// It's useful for tracking failed transactions and correlating them with
  /// your internal systems.
  ///
  /// Example: "ORDER_1234567890123"
  final String? merchantReference;

  /// Timestamp when the error occurred on the local device.
  ///
  /// This field contains the local timestamp (in milliseconds since epoch)
  /// when the error was generated. Useful for debugging timing issues and
  /// error correlation.
  ///
  /// Format: String representation of milliseconds since epoch
  final String? dateTimeLocalTrxn;

  /// Security hash for error verification (if applicable).
  ///
  /// This field may contain a security hash used to verify the integrity
  /// of the error response. Not all error scenarios will include this field.
  final String? secureHash;

  /// Creates a new [PaymentError] instance.
  ///
  /// All parameters are optional as different error scenarios may provide
  /// different sets of information. At minimum, the [error] field should
  /// be provided to describe what went wrong.
  ///
  /// Parameters:
  /// - [error]: Human-readable error description
  /// - [amount]: Payment amount in dirham format
  /// - [merchantReference]: Unique transaction reference
  /// - [dateTimeLocalTrxn]: Local error timestamp
  /// - [secureHash]: Optional security verification hash
  PaymentError({
    this.error,
    this.amount,
    this.merchantReference,
    this.dateTimeLocalTrxn,
    this.secureHash,
  });

  /// Creates a [PaymentError] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize error responses received
  /// from the Moamalat payment gateway or SDK. It handles the specific field
  /// naming conventions used by the Moamalat API.
  ///
  /// The [json] parameter should contain the error response data with the
  /// following possible keys:
  /// - 'error': The error message
  /// - 'Amount': Payment amount in dirham
  /// - 'MerchantReferenece': Merchant transaction reference (note the typo in API)
  /// - 'DateTimeLocalTrxn': Local transaction timestamp
  /// - 'SecureHash': Security verification hash
  ///
  /// Example:
  /// ```dart
  /// final errorData = {
  ///   'error': 'Payment declined',
  ///   'Amount': '10500',
  ///   'MerchantReferenece': 'ORDER_123'
  /// };
  /// final error = PaymentError.fromJson(errorData);
  /// ```
  factory PaymentError.fromJson(Map<String, dynamic> json) {
    return PaymentError(
      error: json['error'],
      amount: json['Amount'],
      merchantReference: json['MerchantReferenece'], // Note: API has typo in key name
      dateTimeLocalTrxn: json['DateTimeLocalTrxn'],
      secureHash: json['SecureHash'],
    );
  }

  /// Converts this [PaymentError] instance to a JSON map.
  ///
  /// This method serializes the error object back to the same JSON format
  /// used by the Moamalat API. This is useful for logging, debugging, or
  /// sending error information to analytics services.
  ///
  /// Returns a map with the following structure:
  /// ```dart
  /// {
  ///   'error': 'Error message',
  ///   'Amount': '10500',
  ///   'MerchantReferenece': 'ORDER_123',
  ///   'DateTimeLocalTrxn': '1640995200000',
  ///   'SecureHash': 'abc123...'
  /// }
  /// ```
  ///
  /// Note: The key names match the Moamalat API format, including the typo
  /// in 'MerchantReferenece'.
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'Amount': amount,
      'MerchantReferenece': merchantReference, // Keep API typo for consistency
      'DateTimeLocalTrxn': dateTimeLocalTrxn,
      'SecureHash': secureHash,
    };
  }

  /// Returns a string representation of this [PaymentError].
  ///
  /// This method provides a human-readable representation of the error object,
  /// which is useful for debugging and logging purposes. It includes all
  /// available error information in a structured format.
  ///
  /// Example output:
  /// ```
  /// PaymentError{error: Payment declined, amount: 10500, merchantReference: ORDER_123, dateTimeLocalTrxn: 1640995200000, secureHash: null}
  /// ```
  @override
  String toString() {
    return 'PaymentError{error: $error, amount: $amount, merchantReference: $merchantReference, dateTimeLocalTrxn: $dateTimeLocalTrxn, secureHash: $secureHash}';
  }
}
