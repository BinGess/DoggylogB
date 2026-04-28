import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef VerifiedOwnedProductIdsLoader =
    Future<List<String>> Function(Set<String> productIds);

enum PremiumSkinPurchaseLaunchResult {
  launched,
  storeUnavailable,
  missingProduct,
  failed,
}

class SkinPurchaseService {
  SkinPurchaseService(
    this._iap,
    this._prefs, {
    VerifiedOwnedProductIdsLoader? loadVerifiedOwnedProductIds,
  }) : _loadVerifiedOwnedProductIds =
           loadVerifiedOwnedProductIds ?? _defaultVerifiedOwnedProductIdsLoader;

  static const _ownedProductsKey = 'ownedPremiumSkinProductIds';
  static Future<List<String>> _defaultVerifiedOwnedProductIdsLoader(
    Set<String> productIds,
  ) async {
    return const <String>[];
  }

  final InAppPurchase _iap;
  final SharedPreferences _prefs;
  final VerifiedOwnedProductIdsLoader _loadVerifiedOwnedProductIds;
  final _stateController = StreamController<PremiumSkinStoreState>.broadcast();
  final Set<String> _productIds = {
    for (final config in managedPetSkinConfigs)
      if (config.premiumProductId != null) config.premiumProductId!,
  };

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, ProductDetails> _productsById = {};
  PremiumSkinStoreState _state = const PremiumSkinStoreState();

  Stream<PremiumSkinStoreState> get stateStream => _stateController.stream;

  Future<PremiumSkinStoreState> initialize() async {
    _state = _state.copyWith(ownedProductIds: _readOwnedProductIds());
    _emitState();

    _purchaseSub ??= _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) => _emitState(clearPendingProductId: true),
    );

    final verifiedOwnedProductIds = await _loadVerifiedOwnedProductIds(
      _productIds,
    );
    // Only overwrite cached IDs when the verifier returns a non-empty result.
    // An empty result could mean verification was unavailable (e.g. iOS < 15)
    // rather than "nothing is owned", so we preserve the cached set to avoid
    // stripping valid purchases on every cold start.
    final List<String> sanitizedOwnedProductIds;
    if (verifiedOwnedProductIds.isNotEmpty) {
      sanitizedOwnedProductIds =
          verifiedOwnedProductIds.where(_productIds.contains).toSet().toList()
            ..sort();
      await _prefs.setStringList(_ownedProductsKey, sanitizedOwnedProductIds);
    } else {
      sanitizedOwnedProductIds = _state.ownedProductIds;
    }

    final storeAvailable = await _iap.isAvailable();
    if (!storeAvailable) {
      _emitState(
        didLoad: true,
        storeAvailable: false,
        ownedProductIds: sanitizedOwnedProductIds,
      );
      return _state;
    }

    final response = await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'SkinPurchaseService: products not found in store: ${response.notFoundIDs}',
      );
    }
    _productsById
      ..clear()
      ..addEntries(
        response.productDetails.map((item) => MapEntry(item.id, item)),
      );

    _emitState(
      didLoad: true,
      storeAvailable: true,
      ownedProductIds: sanitizedOwnedProductIds,
      priceLabels: {
        for (final product in response.productDetails)
          product.id: product.price,
      },
    );
    return _state;
  }

  Future<PremiumSkinPurchaseLaunchResult> purchase(String productId) async {
    if (!_state.storeAvailable) {
      return PremiumSkinPurchaseLaunchResult.storeUnavailable;
    }
    final product =
        _productsById[productId] ?? await _refreshProduct(productId);
    if (product == null) {
      return PremiumSkinPurchaseLaunchResult.missingProduct;
    }
    _emitState(purchasePendingProductId: productId);
    final launched = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!launched) {
      _emitState(clearPendingProductId: true);
      return PremiumSkinPurchaseLaunchResult.failed;
    }
    return PremiumSkinPurchaseLaunchResult.launched;
  }

  Future<ProductDetails?> _refreshProduct(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'SkinPurchaseService: product still not found in store: '
        '${response.notFoundIDs}',
      );
    }
    for (final product in response.productDetails) {
      _productsById[product.id] = product;
    }
    if (response.productDetails.isNotEmpty) {
      _emitState(
        priceLabels: {
          ..._state.priceLabels,
          for (final product in response.productDetails)
            product.id: product.price,
        },
      );
    }
    return _productsById[productId];
  }

  Future<bool> restorePurchases() async {
    if (!_state.storeAvailable) {
      return false;
    }
    await _iap.restorePurchases();
    return true;
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    await _stateController.close();
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _emitState(purchasePendingProductId: purchase.productID);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final owned = {..._state.ownedProductIds, purchase.productID}.toList()
            ..sort();
          await _prefs.setStringList(_ownedProductsKey, owned);
          _emitState(ownedProductIds: owned, clearPendingProductId: true);
          break;
        case PurchaseStatus.error:
          debugPrint(
            'SkinPurchaseService: purchase error for ${purchase.productID}: '
            'code=${purchase.error?.code} message=${purchase.error?.message}',
          );
          _emitState(clearPendingProductId: true);
          break;
        case PurchaseStatus.canceled:
          _emitState(clearPendingProductId: true);
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  List<String> _readOwnedProductIds() {
    return List<String>.from(
      _prefs.getStringList(_ownedProductsKey) ?? const [],
    );
  }

  void _emitState({
    bool? didLoad,
    bool? storeAvailable,
    List<String>? ownedProductIds,
    Map<String, String>? priceLabels,
    String? purchasePendingProductId,
    bool clearPendingProductId = false,
  }) {
    _state = _state.copyWith(
      didLoad: didLoad,
      storeAvailable: storeAvailable,
      ownedProductIds: ownedProductIds,
      priceLabels: priceLabels,
      purchasePendingProductId: purchasePendingProductId,
      clearPendingProductId: clearPendingProductId,
    );
    _stateController.add(_state);
  }
}
