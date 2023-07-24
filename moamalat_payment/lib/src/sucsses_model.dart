class TransactionSucsses {
  String txnDate;
  String systemReference;
  String networkReference;
  String merchantReference;
  int amount;
  String currency;
  String paidThrough;
  String payerAccount;
  String payerName;
  String providerSchemeName;
  String secureHash;
  String displayData;
  String tokenCustomerId;
  String tokenCard;

  TransactionSucsses({
    required this.txnDate,
    required this.systemReference,
    required this.networkReference,
    required this.merchantReference,
    required this.amount,
    required this.currency,
    required this.paidThrough,
    required this.payerAccount,
    required this.payerName,
    required this.providerSchemeName,
    required this.secureHash,
    required this.displayData,
    required this.tokenCustomerId,
    required this.tokenCard,
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TxnDate'] = this.txnDate;
    data['SystemReference'] = this.systemReference;
    data['NetworkReference'] = this.networkReference;
    data['MerchantReference'] = this.merchantReference;
    data['Amount'] = this.amount.toString();
    data['Currency'] = this.currency;
    data['PaidThrough'] = this.paidThrough;
    data['PayerAccount'] = this.payerAccount;
    data['PayerName'] = this.payerName;
    data['ProviderSchemeName'] = this.providerSchemeName;
    data['SecureHash'] = this.secureHash;
    data['DisplayData'] = this.displayData;
    data['TokenCustomerId'] = this.tokenCustomerId;
    data['TokenCard'] = this.tokenCard;
    return data;
  }
}
