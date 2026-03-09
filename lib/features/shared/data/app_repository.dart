import 'dart:async';

import 'package:collection/collection.dart';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/sample_data.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppRepository {
  AppRepository(this._database, this._prefs, this._bus);

  final AppDatabase _database;
  final SharedPreferences _prefs;
  final DomainEventBus _bus;
  final _uuid = const Uuid();

  Future<void> seedIfNeeded() async {
    final seeded = _prefs.getBool('seeded') ?? false;
    if (seeded) {
      return;
    }
    final now = DateTime.now();
    final pet = PetProfile(
      id: _uuid.v4(),
      name: 'Mochi',
      breed: PetBreed.shiba,
      loyaltyPoints: 120,
      selectedSkinId: defaultSkins[PetBreed.shiba]!.first.id,
      unlockedSkinIds: defaultSkins[PetBreed.shiba]!
          .map((item) => item.id)
          .toList(),
      createdAt: now,
      isSelected: true,
    );
    await _database.into(_database.petProfilesTable).insert(pet.toCompanion());

    final tasks = [
      CalendarItem(
        id: _uuid.v4(),
        title: '晨间遛弯',
        description: '带 Mochi 出门散步，顺手补充饮水。',
        startAt: DateTime(now.year, now.month, now.day, 7, 30),
        endAt: DateTime(now.year, now.month, now.day, 8, 0),
        category: CalendarCategory.pet,
        petId: pet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 15)],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarItem(
        id: _uuid.v4(),
        title: '产品评审',
        description: '确认 DoggyLog 首屏交互和 Widget 数据源。',
        startAt: DateTime(now.year, now.month, now.day, 10, 0),
        endAt: DateTime(now.year, now.month, now.day, 11, 0),
        category: CalendarCategory.work,
        petId: pet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 30)],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarItem(
        id: _uuid.v4(),
        title: '疫苗到期提醒',
        description: '确认宠物医院预约时间。',
        startAt: now.add(const Duration(days: 5, hours: 9)),
        endAt: now.add(const Duration(days: 5, hours: 10)),
        category: CalendarCategory.anniversary,
        petId: pet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 60)],
        source: SyncSource.imported,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await _database.batch((batch) {
      batch.insertAll(
        _database.calendarEntriesTable,
        tasks.map((item) => item.toCompanion()).toList(),
      );
      batch.insertAll(_database.countdownItemsTable, [
        CountdownItem(
          id: _uuid.v4(),
          title: 'Mochi 生日',
          dueAt: now.add(const Duration(days: 28)),
          createdAt: now.subtract(const Duration(days: 2)),
          petId: pet.id,
          isPinned: true,
        ).toCompanion(),
        CountdownItem(
          id: _uuid.v4(),
          title: '年度体检',
          dueAt: now.add(const Duration(days: 41)),
          createdAt: now,
          petId: pet.id,
        ).toCompanion(),
      ]);
      batch.insertAll(
        _database.geofencePlacesTable,
        defaultGeofences().map((item) => item.toCompanion()).toList(),
      );
    });
    await savePreferences(const UserPreference.defaults());
    await _prefs.setBool('seeded', true);
  }

  Stream<List<CalendarItem>> watchCalendarItems() {
    final query = (_database.select(_database.calendarEntriesTable)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.startAt)]));
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  Stream<List<PetProfile>> watchPets() {
    final query = (_database.select(_database.petProfilesTable)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)]));
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  Stream<List<CountdownItem>> watchCountdowns() {
    final query = (_database.select(_database.countdownItemsTable)
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.isPinned),
        (tbl) => OrderingTerm(expression: tbl.dueAt),
      ]));
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  Stream<List<GeofencePlace>> watchGeofences() {
    final query = _database.select(_database.geofencePlacesTable);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  Future<UserPreference> loadPreferences() async {
    final query = _database.select(_database.preferencesTable);
    final rows = await query.get();
    final values = {for (final row in rows) row.key: row.value};
    return UserPreference(
      hasCompletedOnboarding: values['hasCompletedOnboarding'] == 'true',
      weekStartsOnMonday: values['weekStartsOnMonday'] == 'true',
      fontScale: double.tryParse(values['fontScale'] ?? '1') ?? 1,
      hapticsEnabled: values['hapticsEnabled'] != 'false',
      animationSpeed: double.tryParse(values['animationSpeed'] ?? '1') ?? 1,
      performanceTier: PerformanceTier.values.firstWhere(
        (item) => item.name == values['performanceTier'],
        orElse: () => PerformanceTier.balanced,
      ),
      selectedCalendarView: CalendarViewMode.values.firstWhere(
        (item) => item.name == values['selectedCalendarView'],
        orElse: () => CalendarViewMode.month,
      ),
      faceIdEnabled: values['faceIdEnabled'] == 'true',
    );
  }

  Future<void> savePreferences(UserPreference preference) async {
    final values = {
      'hasCompletedOnboarding': preference.hasCompletedOnboarding.toString(),
      'weekStartsOnMonday': preference.weekStartsOnMonday.toString(),
      'fontScale': preference.fontScale.toString(),
      'hapticsEnabled': preference.hapticsEnabled.toString(),
      'animationSpeed': preference.animationSpeed.toString(),
      'performanceTier': preference.performanceTier.name,
      'selectedCalendarView': preference.selectedCalendarView.name,
      'faceIdEnabled': preference.faceIdEnabled.toString(),
    };
    await _database.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _database.preferencesTable,
          PreferencesTableCompanion.insert(key: entry.key, value: entry.value),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<DateTime?> loadCalendarSyncCursor() async {
    final row = await (_database.select(
      _database.preferencesTable,
    )..where((tbl) => tbl.key.equals('calendarSyncCursor'))).getSingleOrNull();
    final millis = int.tryParse(row?.value ?? '');
    if (millis == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> saveCalendarSyncCursor(DateTime value) async {
    await _database
        .into(_database.preferencesTable)
        .insert(
          PreferencesTableCompanion.insert(
            key: 'calendarSyncCursor',
            value: value.millisecondsSinceEpoch.toString(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<List<String>> loadRecentSuggestions() async {
    final query = _database.select(_database.calendarEntriesTable)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
      ..limit(5);
    final rows = await query.get();
    return rows.map((item) => item.title).toSet().toList();
  }

  Future<void> upsertCalendarItem(CalendarItem item) async {
    await _database
        .into(_database.calendarEntriesTable)
        .insertOnConflictUpdate(item.toCompanion());
    _bus.fire(TaskChangedEvent(item));
  }

  Future<void> mergeImportedCalendarItems(List<CalendarItem> items) async {
    final existing = await (_database.select(
      _database.calendarEntriesTable,
    )..where((tbl) => tbl.systemEntryId.isNotNull())).get();
    final bySystemId = {
      for (final row in existing)
        if (row.systemEntryId != null) row.systemEntryId!: row.toDomain(),
    };

    for (final item in items) {
      final local = bySystemId[item.systemEntryId];
      final merged =
          local?.copyWith(
            title: item.title,
            description: item.description,
            startAt: item.startAt,
            endAt: item.endAt,
            category: item.category,
            reminders: item.reminders,
            source: local.source,
            updatedAt: item.updatedAt,
            isDeleted: false,
          ) ??
          item.copyWith(
            id: _uuid.v4(),
            source: SyncSource.iosCalendar,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          );
      await upsertCalendarItem(merged);
    }
  }

  Future<void> reconcileCalendarDelta(CalendarSyncDelta delta) async {
    await mergeImportedCalendarItems(delta.items);

    final windowStart = DateTime.now().subtract(const Duration(days: 93));
    final windowEnd = DateTime.now().add(const Duration(days: 366));
    final tracked =
        await (_database.select(_database.calendarEntriesTable)..where(
              (tbl) =>
                  tbl.systemEntryId.isNotNull() &
                  tbl.startAt.isBiggerOrEqualValue(
                    windowStart.millisecondsSinceEpoch,
                  ) &
                  tbl.startAt.isSmallerOrEqualValue(
                    windowEnd.millisecondsSinceEpoch,
                  ),
            ))
            .get();
    final visibleIds = delta.visibleSystemEntryIds.toSet();
    for (final row in tracked) {
      if (row.systemEntryId == null || visibleIds.contains(row.systemEntryId)) {
        continue;
      }
      final local = row.toDomain();
      if (local.isDeleted) {
        continue;
      }
      await upsertCalendarItem(
        local.copyWith(isDeleted: true, updatedAt: delta.syncedAt),
      );
    }
  }

  Future<void> deleteCalendarItem(String id) async {
    final current = await (_database.select(
      _database.calendarEntriesTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (current == null) {
      return;
    }
    final updated = current.toDomain().copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    await upsertCalendarItem(updated);
  }

  Future<void> toggleCalendarItemCompletion(String id, bool value) async {
    final current = await (_database.select(
      _database.calendarEntriesTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (current == null) {
      return;
    }
    final item = current.toDomain().copyWith(
      isCompleted: value,
      updatedAt: DateTime.now(),
    );
    await upsertCalendarItem(item);
    if (value && item.petId != null) {
      await _grantLoyalty(item.petId!, item);
      _bus.fire(TaskCompletedEvent(item));
    }
  }

  Future<void> upsertCountdown(CountdownItem item) async {
    await _database
        .into(_database.countdownItemsTable)
        .insertOnConflictUpdate(item.toCompanion());
  }

  Future<void> completeOnboarding(PetBreed breed, String petName) async {
    final skin = defaultSkins[breed]!.first;
    final pet = PetProfile(
      id: _uuid.v4(),
      name: petName,
      breed: breed,
      loyaltyPoints: 0,
      selectedSkinId: skin.id,
      unlockedSkinIds: [skin.id],
      createdAt: DateTime.now(),
      isSelected: true,
    );
    await _database.transaction(() async {
      await _database
          .update(_database.petProfilesTable)
          .write(const PetProfilesTableCompanion(isSelected: Value(false)));
      await _database
          .into(_database.petProfilesTable)
          .insertOnConflictUpdate(pet.toCompanion());
    });
    final current = await loadPreferences();
    await savePreferences(current.copyWith(hasCompletedOnboarding: true));
  }

  Future<void> selectPet(String petId) async {
    await _database.transaction(() async {
      await _database
          .update(_database.petProfilesTable)
          .write(const PetProfilesTableCompanion(isSelected: Value(false)));
      await (_database.update(_database.petProfilesTable)
            ..where((tbl) => tbl.id.equals(petId)))
          .write(const PetProfilesTableCompanion(isSelected: Value(true)));
    });
    _bus.fire(PetStateChangedEvent(petId));
  }

  Future<void> updatePetSkin(String petId, String skinId) async {
    await (_database.update(_database.petProfilesTable)
          ..where((tbl) => tbl.id.equals(petId)))
        .write(PetProfilesTableCompanion(selectedSkinId: Value(skinId)));
    _bus.fire(PetStateChangedEvent(petId));
  }

  List<TaskTemplate> templates() => defaultTemplates;

  Future<void> _grantLoyalty(String petId, CalendarItem item) async {
    final rows =
        await (_database.select(_database.calendarEntriesTable)..where(
              (tbl) => tbl.petId.equals(petId) & tbl.isCompleted.equals(true),
            ))
            .get();
    final completedItems = rows.map((row) => row.toDomain()).toList();
    final streak = _calculateStreak(completedItems);
    final bonus = switch (streak) {
      >= 7 => 12,
      >= 5 => 8,
      >= 3 => 5,
      _ => 0,
    };
    final awarded = 10 + bonus;
    await _database.transaction(() async {
      final currentPet = await (_database.select(
        _database.petProfilesTable,
      )..where((tbl) => tbl.id.equals(petId))).getSingleOrNull();
      if (currentPet == null) {
        return;
      }
      await (_database.update(
        _database.petProfilesTable,
      )..where((tbl) => tbl.id.equals(petId))).write(
        PetProfilesTableCompanion(
          loyaltyPoints: Value(currentPet.loyaltyPoints + awarded),
        ),
      );
      await _database
          .into(_database.loyaltyLedgersTable)
          .insert(
            LoyaltyLedger(
              id: _uuid.v4(),
              petId: petId,
              calendarItemId: item.id,
              points: awarded,
              createdAt: DateTime.now(),
              reason: streak >= 3 ? 'streak_bonus' : 'task_complete',
            ).toCompanion(),
          );
    });
  }

  int _calculateStreak(List<CalendarItem> items) {
    if (items.isEmpty) {
      return 0;
    }
    final completedDays =
        items
            .where((item) => item.isCompleted)
            .map(
              (item) => DateTime(
                item.startAt.year,
                item.startAt.month,
                item.startAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    if (completedDays.isEmpty) {
      return 0;
    }
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (completedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  DashboardStats calculateStats(
    List<CalendarItem> items,
    List<PetProfile> pets,
  ) {
    final total = items.length;
    final completed = items.where((item) => item.isCompleted).length;
    final streak = _calculateStreak(items);
    final points = pets.fold<int>(0, (sum, item) => sum + item.loyaltyPoints);
    final counts = <CalendarCategory, int>{};
    for (final category in CalendarCategory.values) {
      counts[category] = items
          .where((item) => item.category == category)
          .length;
    }
    return DashboardStats(
      totalTasks: total,
      completedTasks: completed,
      streakDays: streak,
      loyaltyPoints: points,
      categoryCounts: counts,
    );
  }

  PetMood deriveMood(PetProfile pet, List<CalendarItem> items) {
    final relevant = items.where((item) => item.petId == pet.id).toList();
    if (relevant.any(
      (item) => !item.isCompleted && item.endAt.isBefore(DateTime.now()),
    )) {
      return PetMood.sad;
    }
    final today = DateTime.now();
    final todays = relevant
        .where(
          (item) =>
              item.startAt.year == today.year &&
              item.startAt.month == today.month &&
              item.startAt.day == today.day,
        )
        .toList();
    if (todays.isNotEmpty && todays.every((item) => item.isCompleted)) {
      return PetMood.excited;
    }
    final rate = todays.isEmpty
        ? 0
        : todays.where((item) => item.isCompleted).length / todays.length;
    if (rate >= 0.5) {
      return PetMood.calm;
    }
    return PetMood.lazy;
  }

  SceneMode inferScene(List<GeofencePlace> places) {
    return places
            .firstWhereOrNull((item) => item.sceneMode == SceneMode.walking)
            ?.sceneMode ??
        SceneMode.home;
  }
}
