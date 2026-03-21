import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/pets/data/skin_purchase_service.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/app_state_test_harness.dart';

void main() {
  Future<void> saveTask(
    AppStateTestHarness harness, {
    String? id,
    required String title,
  }) {
    final now = DateTime(2026, 3, 12, 9);
    return harness.container
        .read(appStateProvider.notifier)
        .saveTask(
          id: id,
          title: title,
          description: '',
          startAt: now,
          endAt: now.add(const Duration(minutes: 30)),
          category: CalendarCategory.pet,
          petId: null,
          reminders: const [ReminderPolicy(offsetMinutes: 15)],
        );
  }

  CalendarItem existingItem(String id) {
    final now = DateTime(2026, 3, 12, 8);
    return CalendarItem(
      id: id,
      title: '已存在日程',
      description: '',
      startAt: now,
      endAt: now.add(const Duration(minutes: 30)),
      category: CalendarCategory.pet,
      petId: null,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
      source: SyncSource.localOnly,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'AppStateController hydrates notification permission status on init',
    () async {
      final harness = await AppStateTestHarness.create(
        initialNotificationPermissionGranted: true,
      );
      addTearDown(harness.dispose);

      expect(
        harness.container.read(appStateProvider).notificationPermissionGranted,
        isTrue,
      );
      expect(harness.notifications.permissionStatusCheckCallCount, 1);
    },
  );

  test(
    'AppStateController requests notification permission after the first user-created task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('seeded-task')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, title: '第一次手动新建');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 1);
      expect(
        harness.container.read(appStateProvider).notificationPermissionGranted,
        isTrue,
      );
    },
  );

  test(
    'AppStateController does not request notification permission after the second user-created task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('seeded-task')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, title: '第一次手动新建');
      await harness.settle();
      harness.notifications.requestPermissionsCallCount = 0;

      await saveTask(harness, title: '第二次手动新建');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 0);
    },
  );

  test(
    'AppStateController does not request notification permission when editing a task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('task-1')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, id: 'task-1', title: '编辑后的标题');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 0);
    },
  );

  test(
    'AppStateController does not allow premium skin access from cached ownership alone',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeService = _FakeSkinPurchaseService(
        prefs,
        initialState: const PremiumSkinStoreState(
          didLoad: false,
          storeAvailable: true,
          ownedProductIds: ['doggylog.skin.soft_wellness'],
        ),
      );
      final harness = await AppStateTestHarness.create(
        overrides: [
          skinPurchaseServiceProvider.overrideWith((ref) async => fakeService),
        ],
      );
      addTearDown(harness.dispose);

      final husky = harness.container
          .read(appStateProvider)
          .pets
          .firstWhere((pet) => pet.breed == PetBreed.husky);

      await harness.container
          .read(appStateProvider.notifier)
          .selectPet(husky.id);
      await harness.settle();

      expect(
        harness.container.read(appStateProvider).selectedPet?.breed,
        isNot(PetBreed.husky),
      );
    },
  );
}

class _FakeSkinPurchaseService extends SkinPurchaseService {
  _FakeSkinPurchaseService(
    SharedPreferences prefs, {
    required PremiumSkinStoreState initialState,
  }) : _initialState = initialState,
       super(_NoopInAppPurchase(), prefs);

  final PremiumSkinStoreState _initialState;

  @override
  Future<PremiumSkinStoreState> initialize() async => _initialState;

  @override
  Future<PremiumSkinPurchaseLaunchResult> purchase(String productId) async {
    return PremiumSkinPurchaseLaunchResult.storeUnavailable;
  }
}

class _NoopInAppPurchase implements InAppPurchase {
  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    throw UnimplementedError();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      const Stream<List<PurchaseDetails>>.empty();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: const <ProductDetails>[],
      notFoundIDs: identifiers.toList(),
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
