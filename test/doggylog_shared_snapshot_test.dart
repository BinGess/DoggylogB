import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/snapshots/doggylog_shared_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  late String? originalLocale;

  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
    await initializeDateFormatting('en_US');
  });

  setUp(() {
    originalLocale = Intl.defaultLocale;
    Intl.defaultLocale = 'zh_CN';
  });

  tearDown(() {
    Intl.defaultLocale = originalLocale;
  });

  test('DoggylogSharedSnapshot builds expected summary from app state', () {
    final now = DateTime(2026, 3, 8, 9, 0);
    final pet = PetProfile(
      id: 'pet-1',
      name: 'Mochi',
      breed: PetBreed.shiba,
      loyaltyPoints: 230,
      selectedSkinId: 'amber-shiba',
      unlockedSkinIds: const ['amber-shiba'],
      createdAt: now,
      isSelected: true,
    );

    final state = AppState(
      preferences: const UserPreference.defaults(),
      selectedDate: now,
      calendarView: CalendarViewMode.day,
      calendarItems: [
        CalendarItem(
          id: 'task-1',
          title: '晨间遛弯',
          description: '',
          startAt: DateTime(2026, 3, 8, 10),
          endAt: DateTime(2026, 3, 8, 10, 30),
          category: CalendarCategory.pet,
          petId: 'pet-1',
          reminders: const [],
          source: SyncSource.localOnly,
          createdAt: now,
          updatedAt: now,
        ),
        CalendarItem(
          id: 'task-2',
          title: '喂食',
          description: '',
          startAt: DateTime(2026, 3, 8, 12),
          endAt: DateTime(2026, 3, 8, 12, 15),
          category: CalendarCategory.pet,
          petId: 'pet-1',
          reminders: const [],
          source: SyncSource.localOnly,
          createdAt: now,
          updatedAt: now,
          isCompleted: true,
        ),
      ],
      pets: [pet],
      countdowns: [
        CountdownItem(
          id: 'count-1',
          title: 'Mochi 生日',
          dueAt: DateTime(2026, 3, 20),
          createdAt: DateTime(2026, 3, 1),
          petId: 'pet-1',
          isPinned: true,
        ),
      ],
      templates: const [],
      geofences: const [],
      recentSuggestions: const [],
    );

    final snapshot = DoggylogSharedSnapshot.fromAppState(
      state,
      mood: PetMood.calm,
    );

    expect(snapshot.pet.name, 'Mochi');
    expect(snapshot.pet.loyaltyLevel, 3);
    expect(snapshot.today.pendingCount, 1);
    expect(snapshot.today.completedCount, 1);
    expect(snapshot.recentTasks.length, 2);
    expect(snapshot.countdown?.title, 'Mochi 生日');
  });

  test('DoggylogSharedSnapshot localizes seeded content for English locale', () {
    Intl.defaultLocale = 'en_US';
    final now = DateTime(2026, 3, 8, 9, 0);
    final pet = PetProfile(
      id: 'pet-1',
      name: 'Mochi',
      breed: PetBreed.shiba,
      loyaltyPoints: 230,
      selectedSkinId: 'amber-shiba',
      unlockedSkinIds: const ['amber-shiba'],
      createdAt: now,
      isSelected: true,
    );

    final state = AppState(
      preferences: const UserPreference.defaults(),
      selectedDate: now,
      calendarView: CalendarViewMode.day,
      calendarItems: [
        CalendarItem(
          id: 'task-1',
          title: '晨间遛弯',
          description: '',
          startAt: DateTime(2026, 3, 8, 10),
          endAt: DateTime(2026, 3, 8, 10, 30),
          category: CalendarCategory.pet,
          petId: 'pet-1',
          reminders: const [],
          source: SyncSource.localOnly,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      pets: [pet],
      countdowns: [
        CountdownItem(
          id: 'count-1',
          title: 'Mochi 生日',
          dueAt: DateTime(2026, 3, 20),
          createdAt: DateTime(2026, 3, 1),
          petId: 'pet-1',
          isPinned: true,
        ),
      ],
      templates: const [],
      geofences: const [],
      recentSuggestions: const [],
    );

    final snapshot = DoggylogSharedSnapshot.fromAppState(
      state,
      mood: PetMood.calm,
    );

    expect(snapshot.pet.breed, 'Shiba Inu');
    expect(snapshot.recentTasks.single.title, 'Morning stroll');
    expect(snapshot.countdown?.title, 'Mochi’s birthday');
  });
}
