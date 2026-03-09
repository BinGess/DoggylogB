import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AppRepository(database, prefs, DomainEventBus());
  });

  tearDown(() async {
    await database.close();
  });

  test('calculateStats aggregates totals and streak', () {
    final now = DateTime.now();
    final items = [
      CalendarItem(
        id: '1',
        title: 'walk',
        description: '',
        startAt: DateTime(now.year, now.month, now.day, 9),
        endAt: DateTime(now.year, now.month, now.day, 9, 30),
        category: CalendarCategory.pet,
        petId: 'pet-1',
        reminders: const [],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
        isCompleted: true,
      ),
      CalendarItem(
        id: '2',
        title: 'work',
        description: '',
        startAt: DateTime(now.year, now.month, now.day - 1, 11),
        endAt: DateTime(now.year, now.month, now.day - 1, 12),
        category: CalendarCategory.work,
        petId: 'pet-1',
        reminders: const [],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
        isCompleted: true,
      ),
    ];
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: now,
        isSelected: true,
      ),
    ];

    final stats = repository.calculateStats(items, pets);

    expect(stats.totalTasks, 2);
    expect(stats.completedTasks, 2);
    expect(stats.streakDays, 2);
    expect(stats.loyaltyPoints, 120);
    expect(stats.categoryCounts[CalendarCategory.pet], 1);
  });

  test('deriveMood becomes sad when overdue incomplete items exist', () {
    final now = DateTime.now();
    final pet = PetProfile(
      id: 'pet-1',
      name: 'Mochi',
      breed: PetBreed.shiba,
      loyaltyPoints: 10,
      selectedSkinId: 'amber-shiba',
      unlockedSkinIds: const ['amber-shiba'],
      createdAt: now,
      isSelected: true,
    );

    final mood = repository.deriveMood(pet, [
      CalendarItem(
        id: 'late',
        title: 'late',
        description: '',
        startAt: now.subtract(const Duration(hours: 2)),
        endAt: now.subtract(const Duration(hours: 1)),
        category: CalendarCategory.pet,
        petId: pet.id,
        reminders: const [],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    expect(mood, PetMood.sad);
  });

  test('toggleCalendarItemCompletion grants loyalty points', () async {
    final now = DateTime.now();
    await database
        .into(database.petProfilesTable)
        .insert(
          PetProfile(
            id: 'pet-1',
            name: 'Mochi',
            breed: PetBreed.shiba,
            loyaltyPoints: 0,
            selectedSkinId: 'amber-shiba',
            unlockedSkinIds: const ['amber-shiba'],
            createdAt: now,
            isSelected: true,
          ).toCompanion(),
        );
    await database
        .into(database.calendarEntriesTable)
        .insert(
          CalendarItem(
            id: 'task-1',
            title: 'walk',
            description: '',
            startAt: now,
            endAt: now.add(const Duration(minutes: 30)),
            category: CalendarCategory.pet,
            petId: 'pet-1',
            reminders: const [],
            source: SyncSource.localOnly,
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );

    await repository.toggleCalendarItemCompletion('task-1', true);
    final petRow = await (database.select(
      database.petProfilesTable,
    )..where((tbl) => tbl.id.equals('pet-1'))).getSingle();

    expect(petRow.loyaltyPoints, greaterThanOrEqualTo(10));
  });

  test(
    'reconcileCalendarDelta marks missing system events as deleted',
    () async {
      final now = DateTime.now();
      await repository.upsertCalendarItem(
        CalendarItem(
          id: 'local-1',
          title: 'Synced task',
          description: '',
          startAt: now,
          endAt: now.add(const Duration(hours: 1)),
          category: CalendarCategory.work,
          petId: null,
          reminders: const [],
          source: SyncSource.localOnly,
          createdAt: now,
          updatedAt: now,
          systemEntryId: 'ek-1',
        ),
      );

      await repository.reconcileCalendarDelta(
        CalendarSyncDelta(
          items: const [],
          visibleSystemEntryIds: const [],
          syncedAt: now.add(const Duration(minutes: 5)),
        ),
      );

      final row = await (database.select(
        database.calendarEntriesTable,
      )..where((tbl) => tbl.id.equals('local-1'))).getSingle();
      expect(row.isDeleted, isTrue);
    },
  );
}
