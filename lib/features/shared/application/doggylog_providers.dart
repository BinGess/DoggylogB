import 'dart:async';

import 'package:collection/collection.dart';
import 'package:doggylog/app/localization/app_localizations.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final eventBusProvider = Provider<DomainEventBus>((ref) {
  final bus = DomainEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final repositoryProvider = FutureProvider<AppRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final repository = AppRepository(
    ref.watch(databaseProvider),
    prefs,
    ref.watch(eventBusProvider),
  );
  return repository;
});

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  await repository.seedIfNeeded();
});

final appPlatformProvider = Provider<DoggylogPlatform>((ref) {
  return DoggylogPlatform();
});

final notificationServiceProvider = FutureProvider<DoggylogNotificationService>(
  (ref) async {
    final service = DoggylogNotificationService(
      FlutterLocalNotificationsPlugin(),
    );
    try {
      await service.initialize();
    } catch (_) {
      // Widget tests and unsupported hosts may not register the plugin.
    }
    return service;
  },
);

final iosCalendarSyncServiceProvider = Provider<IosCalendarSyncService>((ref) {
  return IosCalendarSyncService(ref.watch(appPlatformProvider));
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(LocalAuthentication());
});

final geofenceMonitorServiceProvider = Provider<GeofenceMonitorService>((ref) {
  final service = GeofenceMonitorService();
  ref.onDispose(service.stopMonitoring);
  return service;
});

final snapshotPublisherProvider = FutureProvider<DoggylogSnapshotPublisher>((
  ref,
) async {
  final repository = await ref.watch(repositoryProvider.future);
  return DoggylogSnapshotPublisher(ref.watch(appPlatformProvider), repository);
});

final appStateProvider = StateNotifierProvider<AppStateController, AppState>((
  ref,
) {
  return AppStateController(ref);
});

class AppStateController extends StateNotifier<AppState> {
  AppStateController(this._ref)
    : super(
        AppState(
          preferences: const UserPreference.defaults(),
          selectedDate: DateTime.now(),
          calendarView: CalendarViewMode.month,
          calendarItems: const [],
          pets: const [],
          countdowns: const [],
          templates: const [],
          geofences: const [],
          recentSuggestions: const [],
          lastSyncMessage: null,
        ),
      ) {
    _init();
  }

  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription<List<CalendarItem>>? _itemsSub;
  StreamSubscription<List<PetProfile>>? _petsSub;
  StreamSubscription<List<CountdownItem>>? _countdownSub;
  StreamSubscription<List<GeofencePlace>>? _geofenceSub;
  StreamSubscription<DomainEvent>? _eventSub;
  StreamSubscription<String>? _platformEventSub;
  StreamSubscription<MotionSample>? _sensorSub;
  StreamSubscription<String>? _widgetCompleteTaskSub;

  Future<void> _init() async {
    final repository = await _ref.read(repositoryProvider.future);
    final notificationService = await _ref.read(
      notificationServiceProvider.future,
    );
    await repository.ensureDefaultPetRoster();
    final preferences = await repository.loadPreferences();
    syncGlobalLocale(preferences.languageMode);
    final suggestions = await repository.loadRecentSuggestions();
    final notificationPermissionGranted = await notificationService
        .arePermissionsGranted();
    final calendarAvailable = await _ref
        .read(iosCalendarSyncServiceProvider)
        .isAvailable();
    final biometricAvailable = await _ref
        .read(biometricAuthServiceProvider)
        .isAvailable();
    final locationPermissionGranted = await _ref
        .read(geofenceMonitorServiceProvider)
        .isPermissionGranted();
    state = state.copyWith(
      preferences: preferences,
      calendarView: preferences.selectedCalendarView,
      templates: repository.templates(),
      recentSuggestions: suggestions,
      notificationPermissionGranted: notificationPermissionGranted,
      calendarPermissionGranted: calendarAvailable,
      biometricAvailable: biometricAvailable,
      locationPermissionGranted: locationPermissionGranted,
      // Keep the initial session interactive, and never lock on devices
      // that cannot actually complete biometric auth.
      appUnlocked: true,
      lastSyncMessage: preferences.faceIdEnabled && !biometricAvailable
          ? AppLocalizations.current(
              mode: preferences.languageMode,
            ).messageBiometricUnsupportedSkipped
          : state.lastSyncMessage,
    );
    if (calendarAvailable) {
      unawaited(_performIncrementalCalendarSync());
    }

    _itemsSub = repository.watchCalendarItems().listen((items) {
      unawaited(_syncNotifications(items));
      final nextState = state.copyWith(calendarItems: items);
      state = nextState;
      unawaited(_publishSnapshot(nextState));
    });
    _petsSub = repository.watchPets().listen((pets) {
      final nextState = state.copyWith(pets: pets);
      state = nextState;
      unawaited(_publishSnapshot(nextState));
    });
    _countdownSub = repository.watchCountdowns().listen((items) {
      final nextState = state.copyWith(countdowns: items);
      state = nextState;
      unawaited(_publishSnapshot(nextState));
    });
    _geofenceSub = repository.watchGeofences().listen((places) {
      final nextState = state.copyWith(
        geofences: places,
        activeScene: repository.inferScene(places),
      );
      state = nextState;
      unawaited(_publishSnapshot(nextState));
      if (state.locationPermissionGranted) {
        unawaited(_startGeofenceMonitoring(places));
      }
    });
    _eventSub = _ref.read(eventBusProvider).stream.listen((event) async {
      if (event is TaskChangedEvent || event is TaskCompletedEvent) {
        final suggestions = await repository.loadRecentSuggestions();
        state = state.copyWith(recentSuggestions: suggestions);
      }
    });
    _platformEventSub = _ref
        .read(iosCalendarSyncServiceProvider)
        .platformEvents
        .listen((event) async {
          if (event == 'eventStoreDidChange') {
            await _performIncrementalCalendarSync(updateMessage: true);
          }
        });
    _sensorSub = _ref.read(appPlatformProvider).sensorEvents.listen((sample) {
      state = state.copyWith(motion: sample, sensorStreamActive: true);
    });
    _widgetCompleteTaskSub = _ref
        .read(appPlatformProvider)
        .widgetCompleteTaskEvents
        .listen((taskId) async {
          await toggleTaskCompletion(taskId, true);
        });
    await _configureSensorStream(preferences.performanceTier);
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> setCalendarView(CalendarViewMode mode) async {
    final repository = await _ref.read(repositoryProvider.future);
    final updated = state.preferences.copyWith(selectedCalendarView: mode);
    await repository.savePreferences(updated);
    state = state.copyWith(preferences: updated, calendarView: mode);
  }

  Future<void> setFetchingBall(bool value) async {
    state = state.copyWith(fetchingBall: value);
  }

  Future<void> setFaceIdEnabled(bool enabled) async {
    final biometricService = _ref.read(biometricAuthServiceProvider);
    final available = await biometricService.isAvailable();
    if (!available) {
      state = state.copyWith(
        biometricAvailable: false,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageBiometricUnsupported,
      );
      return;
    }
    var authenticated = false;
    if (enabled) {
      authenticated = await biometricService.authenticate();
      if (!authenticated) {
        state = state.copyWith(
          biometricAvailable: true,
          lastSyncMessage: AppLocalizations.current(
            mode: state.preferences.languageMode,
          ).messageBiometricFailed,
        );
        return;
      }
    }
    final preferences = state.preferences.copyWith(faceIdEnabled: enabled);
    await updatePreferences(preferences);
    state = state.copyWith(
      biometricAvailable: true,
      appUnlocked: !enabled || authenticated,
      lastSyncMessage: enabled
          ? AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageBiometricEnabled
          : AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageBiometricDisabled,
    );
  }

  Future<void> lockAppIfNeeded() async {
    if (!state.preferences.faceIdEnabled || !state.biometricAvailable) {
      return;
    }
    state = state.copyWith(appUnlocked: false);
  }

  Future<void> unlockApp() async {
    if (!state.preferences.faceIdEnabled) {
      state = state.copyWith(appUnlocked: true);
      return;
    }
    if (!state.biometricAvailable) {
      state = state.copyWith(
        appUnlocked: true,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageBiometricUnsupportedSkipped,
      );
      return;
    }
    final authenticated = await _ref
        .read(biometricAuthServiceProvider)
        .authenticate();
    state = state.copyWith(
      appUnlocked: authenticated,
      lastSyncMessage: authenticated
          ? AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageUnlocked
          : AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageUnlockFailed,
    );
  }

  Future<void> enableGeofenceMonitoring() async {
    final service = _ref.read(geofenceMonitorServiceProvider);
    final granted = await service.requestPermission();
    state = state.copyWith(
      locationPermissionGranted: granted,
      lastSyncMessage: granted
          ? AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageLocationPermissionEnabled
          : AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageLocationPermissionDenied,
    );
    if (granted) {
      await _startGeofenceMonitoring(state.geofences);
    } else {
      await service.stopMonitoring();
      state = state.copyWith(
        activeScene: SceneMode.home,
        activeGeofenceName: null,
      );
    }
  }

  Future<void> saveTask({
    String? id,
    required String title,
    required String description,
    required DateTime startAt,
    required DateTime endAt,
    required CalendarCategory category,
    required String? petId,
    required List<ReminderPolicy> reminders,
  }) async {
    final repository = await _ref.read(repositoryProvider.future);
    final notificationService = await _ref.read(
      notificationServiceProvider.future,
    );
    final shouldRequestNotificationPermission =
        id == null &&
        !state.notificationPermissionGranted &&
        !await repository.hasPromptedNotificationPermission();
    final existing = state.calendarItems.firstWhere(
      (item) => item.id == id,
      orElse: () => CalendarItem(
        id: _uuid.v4(),
        title: '',
        description: '',
        startAt: startAt,
        endAt: endAt,
        category: category,
        petId: petId,
        reminders: reminders,
        source: SyncSource.localOnly,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    var updated = existing.copyWith(
      title: title,
      description: description,
      startAt: startAt,
      endAt: endAt,
      category: category,
      petId: petId,
      reminders: reminders,
      updatedAt: DateTime.now(),
    );
    await repository.upsertCalendarItem(updated);
    if (shouldRequestNotificationPermission) {
      await requestNotificationPermissions();
    }
    await notificationService.scheduleTask(
      updated,
      fireNowForDebug: state.preferences.debugImmediateReminders,
    );
    final systemEntryId = await _ref
        .read(iosCalendarSyncServiceProvider)
        .upsertItem(updated);
    if (systemEntryId != null && systemEntryId != updated.systemEntryId) {
      updated = updated.copyWith(systemEntryId: systemEntryId);
      await repository.upsertCalendarItem(updated);
      state = state.copyWith(
        calendarPermissionGranted: true,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageSyncedToIosCalendar,
      );
    }
  }

  Future<void> toggleTaskCompletion(String id, bool value) async {
    final repository = await _ref.read(repositoryProvider.future);
    await repository.toggleCalendarItemCompletion(id, value);
    if (value) {
      final notifications = await _ref.read(notificationServiceProvider.future);
      await notifications.cancelTask(id);
    }
  }

  Future<void> deleteTask(String id) async {
    final repository = await _ref.read(repositoryProvider.future);
    final item = state.calendarItems.where((task) => task.id == id).firstOrNull;
    if (item != null) {
      final notifications = await _ref.read(notificationServiceProvider.future);
      await notifications.cancelTask(id);
      await _ref.read(iosCalendarSyncServiceProvider).deleteItem(item);
    }
    await repository.deleteCalendarItem(id);
  }

  Future<void> requestNotificationPermissions() async {
    final repository = await _ref.read(repositoryProvider.future);
    final granted = await _ref
        .read(notificationServiceProvider.future)
        .then((service) => service.requestPermissions());
    await repository.markNotificationPermissionPrompted();
    state = state.copyWith(
      notificationPermissionGranted: granted,
      lastSyncMessage: granted
          ? AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageNotificationPermissionOn
          : AppLocalizations.current(
              mode: state.preferences.languageMode,
            ).messageNotificationPermissionOff,
    );
  }

  Future<void> importIosCalendarEvents() async {
    await _performIncrementalCalendarSync(
      forceFull: true,
      updateMessage: true,
      messagePrefix: AppLocalizations.current(
        mode: state.preferences.languageMode,
      ).messagePrefixImportedSystemCalendarSnapshot(),
    );
  }

  Future<void> syncAllToIosCalendar() async {
    final service = _ref.read(iosCalendarSyncServiceProvider);
    final granted = await service.requestAccess();
    if (!granted) {
      state = state.copyWith(
        calendarPermissionGranted: false,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageCalendarPermissionDenied,
      );
      return;
    }
    final repository = await _ref.read(repositoryProvider.future);
    var synced = 0;
    for (final item in state.calendarItems.where((item) => !item.isDeleted)) {
      final systemEntryId = await service.upsertItem(item);
      if (systemEntryId != null && systemEntryId != item.systemEntryId) {
        await repository.upsertCalendarItem(
          item.copyWith(systemEntryId: systemEntryId),
        );
      }
      if (systemEntryId != null) {
        synced += 1;
      }
    }
    state = state.copyWith(
      calendarPermissionGranted: true,
      lastSyncMessage: AppLocalizations.current(
        mode: state.preferences.languageMode,
      ).messageSyncedTasksToIosCalendar(synced),
    );
    await _performIncrementalCalendarSync();
  }

  Future<List<SystemCalendar>> loadSystemCalendars() async {
    final service = _ref.read(iosCalendarSyncServiceProvider);
    final granted = await service.requestAccess();
    if (!granted) {
      state = state.copyWith(
        calendarPermissionGranted: false,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageCalendarPermissionDenied,
      );
      return const [];
    }
    final calendars = await service.loadSystemCalendars();
    state = state.copyWith(calendarPermissionGranted: true);
    return calendars;
  }

  Future<void> updateVisibleSystemCalendars(
    List<String> selectedCalendarIds, {
    required int totalCalendarCount,
  }) async {
    final useFilter = selectedCalendarIds.length != totalCalendarCount;
    final preferences = state.preferences.copyWith(
      useSystemCalendarFilter: useFilter,
      visibleSystemCalendarIds: useFilter ? selectedCalendarIds : const [],
    );
    await updatePreferences(preferences);
    await _performIncrementalCalendarSync(
      forceFull: true,
      updateMessage: true,
      messagePrefix: AppLocalizations.current(
        mode: state.preferences.languageMode,
      ).messagePrefixSystemCalendarScopeUpdated(),
    );
  }

  Future<void> createFromTemplate(TaskTemplate template) async {
    final startAt = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
      9,
    );
    await saveTask(
      title: template.title,
      description: '',
      startAt: startAt,
      endAt: startAt.add(Duration(minutes: template.durationMinutes)),
      category: template.category,
      petId: state.selectedPet?.id,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
    );
  }

  Future<void> createFromDraft(QuickEntryDraft draft) async {
    await saveTask(
      title: draft.title,
      description: '',
      startAt: draft.startAt,
      endAt: draft.endAt,
      category: draft.category,
      petId: draft.petId ?? state.selectedPet?.id,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
    );
  }

  Future<void> saveCountdown(CountdownItem countdown) async {
    final repository = await _ref.read(repositoryProvider.future);
    await repository.upsertCountdown(countdown);
  }

  Future<void> toggleCountdownCelebrated(String id, bool value) async {
    final repository = await _ref.read(repositoryProvider.future);
    await repository.toggleCountdownCelebrated(id, value);
  }

  Future<void> deleteCountdown(String id) async {
    final repository = await _ref.read(repositoryProvider.future);
    await repository.deleteCountdown(id);
  }

  Future<void> selectPet(String petId) async {
    state = state.copyWith(
      pets: [
        for (final pet in state.pets) pet.copyWith(isSelected: pet.id == petId),
      ],
    );
    final repository = await _ref.read(repositoryProvider.future);
    await repository.selectPet(petId);
  }

  Future<void> updatePetSkin(String petId, String skinId) async {
    final repository = await _ref.read(repositoryProvider.future);
    await repository.updatePetSkin(petId, skinId);
  }

  Future<void> updatePreferences(UserPreference preferences) async {
    final repository = await _ref.read(repositoryProvider.future);
    final previousTier = state.preferences.performanceTier;
    await repository.savePreferences(preferences);
    syncGlobalLocale(preferences.languageMode);
    final suggestions = await repository.loadRecentSuggestions();
    state = state.copyWith(
      preferences: preferences,
      calendarView: preferences.selectedCalendarView,
      templates: repository.templates(),
      recentSuggestions: suggestions,
    );
    if (previousTier != preferences.performanceTier) {
      await _configureSensorStream(preferences.performanceTier);
    }
  }

  Future<void> _configureSensorStream(PerformanceTier tier) async {
    final platform = _ref.read(appPlatformProvider);
    // Disable device-motion driven rebuilds for now. They were destabilizing
    // interaction on iOS and are non-essential compared with core usability.
    await platform.stopSensors();
    state = state.copyWith(
      motion: const MotionSample.zero(),
      sensorStreamActive: false,
    );
  }

  Future<void> _syncNotifications(List<CalendarItem> items) async {
    final service = await _ref.read(notificationServiceProvider.future);
    await service.syncTaskReminders(items);
  }

  Future<void> _publishSnapshot(AppState nextState) async {
    final publisher = await _ref.read(snapshotPublisherProvider.future);
    await publisher.publish(nextState);
  }

  Future<void> _startGeofenceMonitoring(List<GeofencePlace> places) async {
    final service = _ref.read(geofenceMonitorServiceProvider);
    if (places.isEmpty) {
      await service.stopMonitoring();
      final nextState = state.copyWith(
        activeScene: SceneMode.home,
        activeGeofenceName: null,
      );
      state = nextState;
      await _publishSnapshot(nextState);
      return;
    }
    await service.startMonitoring(places, (update) {
      final nextState = state.copyWith(
        activeScene: update.sceneMode,
        activeGeofenceName: update.placeName,
        lastSyncMessage: update.placeName == null
            ? AppLocalizations.current(
                mode: state.preferences.languageMode,
              ).messageLocationOutsideGeofence
            : AppLocalizations.current(
                mode: state.preferences.languageMode,
              ).messageEnteredGeofence(update.placeName!, update.sceneMode),
      );
      state = nextState;
      unawaited(_publishSnapshot(nextState));
    });
  }

  Future<void> _performIncrementalCalendarSync({
    bool forceFull = false,
    bool updateMessage = false,
    String? messagePrefix,
  }) async {
    final service = _ref.read(iosCalendarSyncServiceProvider);
    final granted = await service.requestAccess();
    if (!granted) {
      state = state.copyWith(
        calendarPermissionGranted: false,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageCalendarPermissionDenied,
      );
      return;
    }

    final repository = await _ref.read(repositoryProvider.future);
    final cursor = forceFull ? null : await repository.loadCalendarSyncCursor();
    final delta = await service.syncDelta(
      updatedAfter: cursor,
      selectedCalendarIds: _selectedSystemCalendarIdsOrNull(),
    );
    if (delta == null) {
      state = state.copyWith(
        calendarPermissionGranted: true,
        lastSyncMessage: AppLocalizations.current(
          mode: state.preferences.languageMode,
        ).messageIncrementalCalendarSyncFailed,
      );
      return;
    }

    await repository.reconcileCalendarDelta(delta);
    await repository.saveCalendarSyncCursor(delta.syncedAt);
    if (updateMessage) {
      final l10n = AppLocalizations.current(
        mode: state.preferences.languageMode,
      );
      final prefix = messagePrefix ?? l10n.messageIncrementalCalendarSyncPrefix;
      state = state.copyWith(
        calendarPermissionGranted: true,
        lastSyncMessage: l10n.messageIncrementalCalendarSyncResult(
          prefix,
          delta.items.length,
          delta.visibleSystemEntryIds.length,
        ),
      );
    } else {
      state = state.copyWith(calendarPermissionGranted: true);
    }
  }

  List<String>? _selectedSystemCalendarIdsOrNull() {
    if (!state.preferences.useSystemCalendarFilter) {
      return null;
    }
    return state.preferences.visibleSystemCalendarIds;
  }

  @override
  void dispose() {
    _itemsSub?.cancel();
    _petsSub?.cancel();
    _countdownSub?.cancel();
    _geofenceSub?.cancel();
    _eventSub?.cancel();
    _platformEventSub?.cancel();
    _sensorSub?.cancel();
    _widgetCompleteTaskSub?.cancel();
    try {
      unawaited(_ref.read(appPlatformProvider).stopSensors());
    } on StateError {
      // ProviderContainer may already be torn down in widget tests.
    }
    super.dispose();
  }
}
