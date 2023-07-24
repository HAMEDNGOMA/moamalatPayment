class PaymentError {
  final String? error;
  final String? amount;
  final String? merchantReference;
  final String? dateTimeLocalTrxn;
  final String? secureHash;

  PaymentError({
    this.error,
    this.amount,
    this.merchantReference,
    this.dateTimeLocalTrxn,
    this.secureHash,
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
