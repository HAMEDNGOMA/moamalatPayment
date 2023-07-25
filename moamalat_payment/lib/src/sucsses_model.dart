/// A class representing the data returned by a successful Moamalat transaction.
class TransactionSucsses {
  String? txnDate;
  String? systemReference;
  String? networkReference;
  String? merchantReference;
  int? amount;
  String? currency;
  String? paidThrough;
  String? payerAccount;
  String? payerName;
  String? providerSchemeName;
  String? secureHash;
  String? displayData;
  String? tokenCustomerId;
  String? tokenCard;

  TransactionSucsses({
    this.txnDate,
    this.systemReference,
    this.networkReference,
    this.merchantReference,
    this.amount,
    this.currency,
    this.paidThrough,
    this.payerAccount,
    this.payerName,
    this.providerSchemeName,
    this.secureHash,
    this.displayData,
    this.tokenCustomerId,
    this.tokenCard,
  });

  factory TransactionSucsses.fromJson(Map<String, dynamic> json) {
    return TransactionSucsses(
      txnDate: json['TxnDate'],
      systemReference: json['SystemReference'],
      networkReference: json['NetworkReference'],
      merchantReference: json['MerchantReference'],
      amount: int.parse(json['Amount']),
      currency: json['Currency'],
      paidThrough: json['PaidThrough'],
      payerAccount: json['PayerAccount'],
      payerName: json['PayerName'],
      providerSchemeName: json['ProviderSchemeName'],
      secureHash: json['SecureHash'],
      displayData: json['DisplayData'],
      tokenCustomerId: json['TokenCustomerId'],
      tokenCard: json['TokenCard'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TxnDate'] = txnDate;
    data['SystemReference'] = systemReference;
    data['NetworkReference'] = networkReference;
    data['MerchantReference'] = merchantReference;
    data['Amount'] = amount.toString();
    data['Currency'] = currency;
    data['PaidThrough'] = paidThrough;
    data['PayerAccount'] = payerAccount;
    data['PayerName'] = payerName;
    data['ProviderSchemeName'] = providerSchemeName;
    data['SecureHash'] = secureHash;
    data['DisplayData'] = displayData;
    data['TokenCustomerId'] = tokenCustomerId;
    data['TokenCard'] = tokenCard;
    return data;
  }
}
