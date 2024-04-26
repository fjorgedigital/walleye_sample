class Subscription {
  int? id;
  String? productId;
  String? transactionId;
  String? originalTransactionId;
  String? purchaseDate;
  String? originalPurchaseDate;
  String? expirationDate;
  String? cancellationDate;
  bool? isTrial;
  String? createdAt;
  String? updatedAt;
  String? publishedAt;
  bool isExpired;

  Subscription(
      {this.id,
      this.productId,
      this.transactionId,
      required this.originalTransactionId,
      this.purchaseDate,
      this.originalPurchaseDate,
      this.expirationDate,
      this.cancellationDate,
      this.isTrial,
      this.createdAt,
      this.updatedAt,
      this.publishedAt,
      required this.isExpired});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
        id: json['sub']['id'],
        productId: json['sub']['product_id'],
        transactionId: json['sub']['transaction_id'],
        originalTransactionId: json['sub']['original_transaction_id'],
        purchaseDate: json['sub']['purchase_date'],
        originalPurchaseDate: json['sub']['original_purchase_date'],
        expirationDate: json['sub']['expiration_date'],
        cancellationDate: json['sub']['cancellation_date'],
        isTrial: json['sub']['is_trial'],
        createdAt: json['sub']['createdAt'],
        updatedAt: json['sub']['updatedAt'],
        publishedAt: json['sub']['publishedAt'],
        isExpired: json['isExpired']);
  }
}
