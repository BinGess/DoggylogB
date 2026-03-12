import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppRepository repository;
  late String? originalLocale;

  setUp(() async {
    originalLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'zh_CN';
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AppRepository(database, prefs, DomainEventBus());
  });

  tearDown(() async {
    Intl.defaultLocale = originalLocale;
    await database.close();
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
          source: SyncSource.iosCalendar,
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

  test(
    'mergeImportedCalendarItems deduplicates identical iOS events with new system ids',
    () async {
      final now = DateTime(2026, 3, 10, 9);
      await repository.upsertCalendarItem(
        CalendarItem(
          id: 'local-1',
          title: '晨间遛弯',
          description: '带 Mochi 出门',
          startAt: now,
          endAt: now.add(const Duration(minutes: 30)),
          category: CalendarCategory.pet,
          petId: null,
          reminders: const [],
          source: SyncSource.iosCalendar,
          createdAt: now,
          updatedAt: now,
          systemEntryId: 'ek-old',
        ),
      );

      await repository.mergeImportedCalendarItems([
        CalendarItem(
          id: 'imported-1',
          title: '晨间遛弯',
          description: '带 Mochi 出门',
          startAt: now,
          endAt: now.add(const Duration(minutes: 30)),
          category: CalendarCategory.pet,
          petId: null,
          reminders: const [],
          source: SyncSource.iosCalendar,
          createdAt: now.add(const Duration(minutes: 1)),
          updatedAt: now.add(const Duration(minutes: 1)),
          systemEntryId: 'ek-new',
        ),
      ]);

      final rows = await (database.select(
        database.calendarEntriesTable,
      )..where((tbl) => tbl.title.equals('晨间遛弯'))).get();

      expect(rows, hasLength(1));
      expect(rows.single.id, 'local-1');
      expect(rows.single.systemEntryId, 'ek-new');
    },
  );

  test('savePreferences persists debug immediate reminder switch', () async {
    const preference = UserPreference(
      hasCompletedOnboarding: false,
      weekStartsOnMonday: true,
      fontScale: 1,
      hapticsEnabled: true,
      animationSpeed: 1,
      performanceTier: PerformanceTier.balanced,
      selectedCalendarView: CalendarViewMode.month,
      faceIdEnabled: false,
      debugImmediateReminders: true,
      useSystemCalendarFilter: true,
      visibleSystemCalendarIds: ['cal-1', 'cal-2'],
    );

    await repository.savePreferences(preference);
    final loaded = await repository.loadPreferences();

    expect(loaded.debugImmediateReminders, isTrue);
    expect(loaded.useSystemCalendarFilter, isTrue);
    expect(loaded.visibleSystemCalendarIds, ['cal-1', 'cal-2']);
  });

  test(
    'loadPreferences treats onboarding as already completed by default',
    () async {
      final loaded = await repository.loadPreferences();

      expect(loaded.hasCompletedOnboarding, isTrue);
    },
  );

  test(
    'loadPreferences ignores stale stored onboarding=false values',
    () async {
      await repository.savePreferences(
        const UserPreference(
          hasCompletedOnboarding: false,
          weekStartsOnMonday: false,
          fontScale: 1,
          hapticsEnabled: true,
          animationSpeed: 1,
          performanceTier: PerformanceTier.balanced,
          selectedCalendarView: CalendarViewMode.month,
          faceIdEnabled: false,
          debugImmediateReminders: false,
          useSystemCalendarFilter: false,
          visibleSystemCalendarIds: [],
        ),
      );

      final loaded = await repository.loadPreferences();

      expect(loaded.hasCompletedOnboarding, isTrue);
    },
  );

  test(
    'toggleCountdownCelebrated and deleteCountdown mutate stored item',
    () async {
      final now = DateTime(2026, 3, 9, 12);
      await repository.upsertCountdown(
        CountdownItem(
          id: 'countdown-1',
          title: '疫苗提醒',
          dueAt: now.add(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 3)),
          petId: 'pet-1',
        ),
      );

      await repository.toggleCountdownCelebrated('countdown-1', true);

      final celebratedRow = await (database.select(
        database.countdownItemsTable,
      )..where((tbl) => tbl.id.equals('countdown-1'))).getSingle();
      expect(celebratedRow.hasCelebrated, isTrue);

      await repository.deleteCountdown('countdown-1');

      final remaining = await (database.select(
        database.countdownItemsTable,
      )..where((tbl) => tbl.id.equals('countdown-1'))).get();
      expect(remaining, isEmpty);
    },
  );

  test('seedIfNeeded creates a pet roster covering all breeds', () async {
    await repository.seedIfNeeded();

    final pets = await (database.select(
      database.petProfilesTable,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)])).get();

    expect(pets.length, greaterThanOrEqualTo(PetBreed.values.length));
    for (final breed in PetBreed.values) {
      expect(
        pets.where((pet) => pet.breed == breed.name),
        isNotEmpty,
        reason: 'missing seeded pet for $breed',
      );
    }
    expect(pets.where((pet) => pet.isSelected), hasLength(1));
  });

  test(
    'seedIfNeeded stores locale-agnostic copy keys for seeded content',
    () async {
      Intl.defaultLocale = 'zh_CN';

      await repository.seedIfNeeded();

      final taskRows = await (database.select(
        database.calendarEntriesTable,
      )..orderBy([(tbl) => OrderingTerm(expression: tbl.startAt)])).get();
      final countdownRows = await database
          .select(database.countdownItemsTable)
          .get();

      expect(
        taskRows.map((row) => row.title),
        contains(SeedCopyKey.taskMorningWalkTitle),
      );
      expect(
        taskRows.map((row) => row.description),
        contains(SeedCopyKey.taskMorningWalkDescription),
      );
      expect(
        countdownRows.map((row) => row.title),
        contains(SeedCopyKey.countdownMochiBirthdayTitle),
      );

      Intl.defaultLocale = 'en_US';
      final suggestions = await repository.loadRecentSuggestions();

      expect(suggestions, contains('Morning stroll'));
      expect(
        AppLocalizations.current().localizedStoredText(
          SeedCopyKey.countdownMochiBirthdayTitle,
        ),
        'Mochi’s birthday',
      );
    },
  );
}
