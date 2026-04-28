import 'dart:async';

import 'package:doggylog/features/pets/data/skin_purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'SkinPurchaseService preserves cached ownership when verification is unavailable during initialization',
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
      expect(state.ownedProductIds, ['doggylog.skin.soft_wellness']);
      expect(prefs.getStringList('ownedPremiumSkinProductIds'), [
        'doggylog.skin.soft_wellness',
      ]);

      await service.dispose();
    },
  );

  test(
    'SkinPurchaseService refreshes a missing product before launching purchase',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final iap = _FakeInAppPurchase(
        initialMissingProductIds: {'doggylog.skin.soft_wellness'},
      );
      final service = SkinPurchaseService(
        iap,
        prefs,
        loadVerifiedOwnedProductIds: (productIds) async => const [],
      );
      await service.initialize();

      final result = await service.purchase('doggylog.skin.soft_wellness');

      expect(result, PremiumSkinPurchaseLaunchResult.launched);
      expect(iap.queryProductDetailsCallCount, 2);
      expect(iap.purchasedProductIds, ['doggylog.skin.soft_wellness']);

      await service.dispose();
    },
  );
}

class _FakeInAppPurchase implements InAppPurchase {
  _FakeInAppPurchase({Set<String> initialMissingProductIds = const {}})
    : _initialMissingProductIds = initialMissingProductIds;

  final Set<String> _initialMissingProductIds;
  final List<String> purchasedProductIds = [];
  int queryProductDetailsCallCount = 0;

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
    queryProductDetailsCallCount += 1;
    final missingProductIds = queryProductDetailsCallCount == 1
        ? _initialMissingProductIds
        : const <String>{};
    final foundProductIds = identifiers.difference(missingProductIds);
    return ProductDetailsResponse(
      productDetails: foundProductIds
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
      notFoundIDs: missingProductIds.toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    purchasedProductIds.add(purchaseParam.productDetails.id);
    return true;
  }

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
