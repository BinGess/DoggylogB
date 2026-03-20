import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum RestorePurchasesResult { requested, unavailable, failed }

abstract class DoggylogPurchaseService {
  Future<RestorePurchasesResult> restorePurchases();
}

class AppStorePurchaseService implements DoggylogPurchaseService {
  AppStorePurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Future<RestorePurchasesResult> restorePurchases() async {
    try {
      if (!await _inAppPurchase.isAvailable()) {
        return RestorePurchasesResult.unavailable;
      }
      await _inAppPurchase.restorePurchases();
      return RestorePurchasesResult.requested;
    } catch (error) {
      debugPrint('AppStorePurchaseService.restorePurchases failed: $error');
      return RestorePurchasesResult.failed;
    }
  }
}
