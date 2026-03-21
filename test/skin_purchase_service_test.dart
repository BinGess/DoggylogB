import 'dart:async';

import 'package:doggylog/features/pets/data/skin_purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'SkinPurchaseService replaces cached ownership with verified entitlements during initialization',
    () async {
      SharedPreferences.setMockInitialValues({
        'ownedPremiumSkinProductIds': ['doggylog.skin.soft_wellness'],
      });
      final prefs = await SharedPreferences.getInstance();
      final service = SkinPurchaseService(
        _FakeInAppPurchase(),
        prefs,
        loadVerifiedOwnedProductIds: (productIds) async => const [],
      );

      final state = await service.initialize();

      expect(state.didLoad, isTrue);
      expect(state.ownedProductIds, isEmpty);
      expect(prefs.getStringList('ownedPremiumSkinProductIds'), isEmpty);

      await service.dispose();
    },
  );
}

class _FakeInAppPurchase implements InAppPurchase {
  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    throw UnimplementedError();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      const Stream<List<PurchaseDetails>>.empty();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: identifiers
          .map(
            (id) => ProductDetails(
              id: id,
              title: id,
              description: id,
              price: '¥3',
              rawPrice: 3,
              currencyCode: 'CNY',
            ),
          )
          .toList(),
      notFoundIDs: const <String>[],
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      false;

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async => false;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  @override
  Future<String> countryCode() async => 'CN';
}
