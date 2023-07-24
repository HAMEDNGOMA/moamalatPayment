class PaymentError {
  final String error;
  final String amount;
  final String merchantReference;
  final String dateTimeLocalTrxn;
  final String secureHash;

  PaymentError({
    required this.error,
    required this.amount,
    required this.merchantReference,
    required this.dateTimeLocalTrxn,
    required this.secureHash,
  });

  factory PaymentError.fromJson(Map<String, dynamic> json) {
    return PaymentError(
      error: json['error'],
      amount: json['Amount'],
      merchantReference: json['MerchantReferenece'],
      dateTimeLocalTrxn: json['DateTimeLocalTrxn'],
      secureHash: json['SecureHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'Amount': amount,
      'MerchantReferenece': merchantReference,
      'DateTimeLocalTrxn': dateTimeLocalTrxn,
      'SecureHash': secureHash,
    };
  }

  @override
  String toString() {
    return 'PaymentError{error: $error, amount: $amount, merchantReference: $merchantReference, dateTimeLocalTrxn: $dateTimeLocalTrxn, secureHash: $secureHash}';
  }
}
