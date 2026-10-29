import 'dart:async';

import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/pets/data/skin_purchase_service.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'purchase completion, cancellation and error clear the overlay state',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final updates = StreamController<List<PurchaseDetails>>();
      final service = SkinPurchaseService(
        _FakeInAppPurchase(updates: updates.stream),
        prefs,
        loadVerifiedOwnedProductIds: (_) async => const [],
      );
      await service.initialize();
      final states = <PremiumSkinStoreState>[];
      final subscription = service.stateStream.listen(states.add);
      const productId = 'doggylog.skin.soft_wellness';

      for (final status in [
        PurchaseStatus.purchased,
        PurchaseStatus.canceled,
        PurchaseStatus.error,
      ]) {
        await service.purchase(productId);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.purchasePendingProductId, productId);
        updates.add([
          PurchaseDetails(
            productID: productId,
            verificationData: PurchaseVerificationData(
              localVerificationData: '',
              serverVerificationData: '',
              source: 'test',
            ),
            transactionDate: null,
            status: status,
          ),
        ]);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.purchasePendingProductId, isNull, reason: '$status');
      }

      await subscription.cancel();
      await service.dispose();
      await updates.close();
    },
  );

  test(
    'the three new paid skins query and launch separate purchases',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final iap = _FakeInAppPurchase();
      final service = SkinPurchaseService(
        iap,
        prefs,
        loadVerifiedOwnedProductIds: (_) async => const [],
      );
      await service.initialize();
      final productIds = [
        PetBreed.borderCollie,
        PetBreed.dachshund,
        PetBreed.dalmatian,
      ].map((breed) => premiumProductIdForPetBreed(breed)!).toList();
      expect(productIds.toSet(), hasLength(3));

      for (final id in productIds) {
        expect(
          await service.purchase(id),
          PremiumSkinPurchaseLaunchResult.launched,
        );
      }
      expect(iap.purchasedProductIds, productIds);
      await service.dispose();
    },
  );

  test(
    'SkinPurchaseService clears pending state when the system purchase call throws',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SkinPurchaseService(
        _FakeInAppPurchase(throwOnPurchase: true),
        prefs,
        loadVerifiedOwnedProductIds: (_) async => const [],
      );
      await service.initialize();
      final states = <PremiumSkinStoreState>[];
      final subscription = service.stateStream.listen(states.add);

      expect(
        await service.purchase('doggylog.skin.soft_wellness'),
        PremiumSkinPurchaseLaunchResult.failed,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        states.first.purchasePendingProductId,
        'doggylog.skin.soft_wellness',
      );
      expect(states.last.purchasePendingProductId, isNull);

      await subscription.cancel();
      await service.dispose();
    },
  );

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
        loadVerifiedOwnedProductIds: (productIds) async => null,
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
  _FakeInAppPurchase({
    Set<String> initialMissingProductIds = const {},
    this.throwOnPurchase = false,
    this.updates = const Stream<List<PurchaseDetails>>.empty(),
  }) : _initialMissingProductIds = initialMissingProductIds;

  final bool throwOnPurchase;
  final Stream<List<PurchaseDetails>> updates;
  final Set<String> _initialMissingProductIds;
  final List<String> purchasedProductIds = [];
  int queryProductDetailsCallCount = 0;

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    throw UnimplementedError();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates;

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
    if (throwOnPurchase) {
      throw StateError('System purchase unavailable');
    }
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
