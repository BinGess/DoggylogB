import 'dart:async';

import 'package:doggylog/features/pets/data/skin_purchase_service.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/biometrics/biometric_auth_service.dart';
import 'package:doggylog/platform/calendar/ios_calendar_sync_service.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:doggylog/platform/geofence/geofence_monitor_service.dart';
import 'package:doggylog/platform/notifications/doggylog_notification_service.dart';
import 'package:doggylog/platform/snapshots/doggylog_snapshot_publisher.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateTestHarness {
  AppStateTestHarness._({
    required this.container,
    required this.database,
    required this.repository,
    required this.notifications,
  });

  final ProviderContainer container;
  final AppDatabase database;
  final AppRepository repository;
  final FakeNotificationService notifications;

  static Future<AppStateTestHarness> create({
    bool initialNotificationPermissionGranted = false,
    bool notificationPermissionRequestResult = true,
    List<CalendarItem> initialCalendarItems = const [],
    Map<String, Object> sharedPreferences = const {},
    List<Override> overrides = const [],
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues(sharedPreferences);
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = AppRepository(database, prefs, DomainEventBus());
    for (final item in initialCalendarItems) {
      await repository.upsertCalendarItem(item);
    }

    final platform = FakeDoggylogPlatform();
    final notifications = FakeNotificationService(
      initialPermissionGranted: initialNotificationPermissionGranted,
      requestPermissionResult: notificationPermissionRequestResult,
    );
    final iosCalendar = FakeIosCalendarSyncService(platform);
    final snapshotPublisher = FakeSnapshotPublisher(repository, platform);
    final biometric = FakeBiometricAuthService();
    final geofence = FakeGeofenceMonitorService();
    final skinPurchaseService = _HarnessSkinPurchaseService(prefs);
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWith((ref) async => repository),
        notificationServiceProvider.overrideWith((ref) async => notifications),
        iosCalendarSyncServiceProvider.overrideWith((ref) => iosCalendar),
        snapshotPublisherProvider.overrideWith(
          (ref) async => snapshotPublisher,
        ),
        biometricAuthServiceProvider.overrideWith((ref) => biometric),
        geofenceMonitorServiceProvider.overrideWith((ref) => geofence),
        appPlatformProvider.overrideWith((ref) => platform),
        skinPurchaseServiceProvider.overrideWith(
          (ref) async => skinPurchaseService,
        ),
        ...overrides,
      ],
    );

    final harness = AppStateTestHarness._(
      container: container,
      database: database,
      repository: repository,
      notifications: notifications,
    );
    container.read(appStateProvider);
    await harness.settle();
    return harness;
  }

  Future<void> settle() async {
    for (var index = 0; index < 8; index++) {
      await Future<void>.delayed(Duration.zero);
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

class FakeNotificationService extends DoggylogNotificationService {
  FakeNotificationService({
    required bool initialPermissionGranted,
    required this.requestPermissionResult,
  }) : currentPermissionGranted = initialPermissionGranted,
       super(FlutterLocalNotificationsPlugin());

  bool currentPermissionGranted;
  bool requestPermissionResult;
  int requestPermissionsCallCount = 0;
  int permissionStatusCheckCallCount = 0;
  int scheduleTaskCallCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> arePermissionsGranted() async {
    permissionStatusCheckCallCount += 1;
    return currentPermissionGranted;
  }

  @override
  Future<bool> requestPermissions() async {
    requestPermissionsCallCount += 1;
    currentPermissionGranted = requestPermissionResult;
    return requestPermissionResult;
  }

  @override
  Future<void> scheduleTask(
    CalendarItem item, {
    bool fireNowForDebug = false,
  }) async {
    scheduleTaskCallCount += 1;
  }

  @override
  Future<void> syncTaskReminders(Iterable<CalendarItem> items) async {}

  @override
  Future<void> cancelTask(String taskId) async {}
}

class FakeIosCalendarSyncService extends IosCalendarSyncService {
  FakeIosCalendarSyncService(super.platform);

  @override
  Future<bool> requestAccess() async => false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<List<SystemCalendar>> loadSystemCalendars() async => const [];

  @override
  Future<List<CalendarItem>> importItems({
    List<String>? selectedCalendarIds,
  }) async {
    return const [];
  }

  @override
  Future<CalendarSyncDelta?> syncDelta({
    DateTime? updatedAfter,
    List<String>? selectedCalendarIds,
  }) async {
    return null;
  }

  @override
  Future<String?> upsertItem(CalendarItem item) async => null;

  @override
  Future<bool> deleteItem(CalendarItem item) async => true;

  @override
  Stream<String> get platformEvents => const Stream<String>.empty();
}

class FakeSnapshotPublisher extends DoggylogSnapshotPublisher {
  FakeSnapshotPublisher(AppRepository repository, DoggylogPlatform platform)
    : super(platform, repository);

  @override
  Future<void> publish(AppState state) async {}
}

class FakeGeofenceMonitorService extends GeofenceMonitorService {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> isPermissionGranted() async => false;

  @override
  Future<void> startMonitoring(
    List<GeofencePlace> places,
    void Function(GeofenceSceneUpdate update) onUpdate,
  ) async {}

  @override
  Future<void> stopMonitoring() async {}
}

class FakeBiometricAuthService extends BiometricAuthService {
  FakeBiometricAuthService() : super(LocalAuthentication());

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate() async => false;
}

class FakeDoggylogPlatform extends DoggylogPlatform {
  @override
  Stream<String> get platformEvents => const Stream<String>.empty();

  @override
  Stream<MotionSample> get sensorEvents => const Stream<MotionSample>.empty();

  @override
  Stream<String> get widgetCompleteTaskEvents => const Stream<String>.empty();

  @override
  Future<bool> publishWidgetSnapshot(String payloadJson) async => true;

  @override
  Future<bool> updateDynamicIsland(String payloadJson) async => true;

  @override
  Future<bool> endDynamicIsland() async => true;

  @override
  Future<void> stopSensors() async {}
}

class _HarnessSkinPurchaseService extends SkinPurchaseService {
  _HarnessSkinPurchaseService(SharedPreferences prefs)
    : super(_HarnessInAppPurchase(), prefs);

  @override
  Future<PremiumSkinStoreState> initialize() async {
    return const PremiumSkinStoreState(didLoad: true, storeAvailable: false);
  }

  @override
  Future<PremiumSkinPurchaseLaunchResult> purchase(String productId) async {
    return PremiumSkinPurchaseLaunchResult.storeUnavailable;
  }
}

class _HarnessInAppPurchase implements InAppPurchase {
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
