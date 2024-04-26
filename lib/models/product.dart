import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

enum ProductStatus {
  purchasable,
  purchased,
  pending,
}

class Product {
  String get id => productDetails.productId ?? '';
  String get title => productDetails.title ?? '';
  String get description => productDetails.description ?? '';
  String get price => productDetails.localizedPrice ?? '';
  ProductStatus status;
  IAPItem productDetails;

  Product(this.productDetails) : status = ProductStatus.purchasable;
}
