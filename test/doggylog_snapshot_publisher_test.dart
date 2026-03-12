import 'dart:convert';

import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:doggylog/platform/snapshots/doggylog_snapshot_publisher.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late AppRepository repository;
  late _RecordingDoggylogPlatform platform;
  late DoggylogSnapshotPublisher publisher;
  late String? originalLocale;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('zh_CN');
  });

  setUp(() async {
    originalLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'zh_CN';
    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AppRepository(database, preferences, DomainEventBus());
    platform = _RecordingDoggylogPlatform();
    publisher = DoggylogSnapshotPublisher(platform, repository);
  });

  tearDown(() async {
    Intl.defaultLocale = originalLocale;
    await database.close();
  });

  test('publishes live activity update only when countdown exists', () async {
    final state = _buildState(
      countdowns: [
        CountdownItem(
          id: 'count-1',
          title: 'Mochi 生日',
          dueAt: DateTime(2026, 4, 5),
          createdAt: DateTime(2026, 3, 1),
          petId: 'pet-1',
          isPinned: true,
        ),
      ],
    );

    await publisher.publish(state);

    expect(platform.publishedWidgetSnapshots, hasLength(1));
    expect(platform.updatedDynamicIslandPayloads, hasLength(1));
    expect(platform.endDynamicIslandCallCount, 0);

    final payload =
        jsonDecode(platform.updatedDynamicIslandPayloads.single)
            as Map<String, dynamic>;
    expect(payload['countdown'], isNotNull);
  });

  test('ends live activity when snapshot has no countdown', () async {
    final state = _buildState();

    await publisher.publish(state);

    expect(platform.publishedWidgetSnapshots, hasLength(1));
    expect(platform.updatedDynamicIslandPayloads, isEmpty);
    expect(platform.endDynamicIslandCallCount, 1);
  });
}

AppState _buildState({List<CountdownItem> countdowns = const []}) {
  final now = DateTime(2026, 3, 8, 9);
  return AppState(
    preferences: const UserPreference.defaults(),
    selectedDate: now,
    calendarView: CalendarViewMode.day,
    calendarItems: [
      CalendarItem(
        id: 'task-1',
        title: '疫苗到期提醒',
        description: '',
        startAt: DateTime(2026, 3, 8, 12),
        endAt: DateTime(2026, 3, 8, 12, 30),
        category: CalendarCategory.pet,
        petId: 'pet-1',
        reminders: const [],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    pets: [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 230,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: now,
        isSelected: true,
      ),
    ],
    countdowns: countdowns,
    templates: const [],
    geofences: const [],
    recentSuggestions: const [],
  );
}

class _RecordingDoggylogPlatform extends DoggylogPlatform {
  final List<String> publishedWidgetSnapshots = [];
  final List<String> updatedDynamicIslandPayloads = [];
  int endDynamicIslandCallCount = 0;

  @override
  Future<bool> publishWidgetSnapshot(String payloadJson) async {
    publishedWidgetSnapshots.add(payloadJson);
    return true;
  }

  @override
  Future<bool> updateDynamicIsland(String payloadJson) async {
    updatedDynamicIslandPayloads.add(payloadJson);
    return true;
  }

  @override
  Future<bool> endDynamicIsland() async {
    endDynamicIslandCallCount += 1;
    return true;
  }
}
