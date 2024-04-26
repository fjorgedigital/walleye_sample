import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:walleye_sample/models/subscription.dart';
import 'package:walleye_sample/utilities/api.dart';

class SubscriptionService {
  static Future<bool> verifyPurchase(
      PurchasedItem purchaseDetails, String authToken, int userId) async {
    var receiptData = {};
    String endPoint = '';

    if (Platform.isAndroid) {
      endPoint = '/subscriptions/google/validate-receipt';

      receiptData = {
        'product_id': purchaseDetails.productId,
        'token': purchaseDetails.purchaseToken,
        "user-id": userId.toString()
      };
    } else if (Platform.isIOS) {
      endPoint = '/subscriptions/apple/validate-receipt';

      receiptData = {
        "receipt_data": purchaseDetails.transactionReceipt,
        "password":
            const String.fromEnvironment('APPLE_SHARED_KEY', defaultValue: ''),
        "transaction_date": purchaseDetails.transactionDate?.toIso8601String(),
        "user_id": userId.toString()
      };
    }

    var response = await Api.post(endPoint, jsonEncode(receiptData),
        {'Authorization': 'Bearer $authToken'});

    if (response.statusCode != 200) {
      return false;
    } else {
      var jsonResponse = jsonDecode(response.body);
      //deliver product if subscription is not expired
      if (!jsonResponse['isExpired']) {
        return true;
      }
      return false;
    }
  }

  static Future<List<Subscription>> bulkVerifyPurchase(
      List<PurchasedItem> purchaseDetails, String authToken) async {
    var receipts = purchaseDetails
        .map((e) => {'receipt_data': e.transactionReceipt})
        .toList();

    var response = await Api.post(
        '/subscriptions/apple/bulk-validate-receipt',
        jsonEncode({'receipts': receipts}),
        {'Authorization': 'Bearer $authToken'});

    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }

    var jsonResponse = jsonDecode(response.body);
    var subscriptions =
        (jsonResponse as List).map((e) => Subscription.fromJson(e)).toList();
    return subscriptions;
  }
}
