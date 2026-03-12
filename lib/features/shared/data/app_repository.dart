import 'dart:async';

import 'package:collection/collection.dart';
import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/sample_data.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppRepository {
  AppRepository(this._database, this._prefs, this._bus);

  static const _seededKey = 'seeded';
  static const _notificationPermissionPromptedKey =
      'notificationPermissionPrompted';

  final AppDatabase _database;
  final SharedPreferences _prefs;
  final DomainEventBus _bus;
  final _uuid = const Uuid();

  Future<void> seedIfNeeded() async {
    final seeded = _prefs.getBool(_seededKey) ?? false;
    if (seeded) {
      return;
    }
    final now = DateTime.now();
    final pets = _buildDefaultPetRoster(now);
    final selectedPet = pets.firstWhere((pet) => pet.isSelected);

    final tasks = [
      CalendarItem(
        id: _uuid.v4(),
        title: SeedCopyKey.taskMorningWalkTitle,
        description: SeedCopyKey.taskMorningWalkDescription,
        startAt: DateTime(now.year, now.month, now.day, 7, 30),
        endAt: DateTime(now.year, now.month, now.day, 8, 0),
        category: CalendarCategory.pet,
        petId: selectedPet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 15)],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarItem(
        id: _uuid.v4(),
        title: SeedCopyKey.taskProductReviewTitle,
        description: SeedCopyKey.taskProductReviewDescription,
        startAt: DateTime(now.year, now.month, now.day, 10, 0),
        endAt: DateTime(now.year, now.month, now.day, 11, 0),
        category: CalendarCategory.work,
        petId: selectedPet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 30)],
        source: SyncSource.localOnly,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarItem(
        id: _uuid.v4(),
        title: SeedCopyKey.taskVaccineDueTitle,
        description: SeedCopyKey.taskVaccineDueDescription,
        startAt: now.add(const Duration(days: 5, hours: 9)),
        endAt: now.add(const Duration(days: 5, hours: 10)),
        category: CalendarCategory.anniversary,
        petId: selectedPet.id,
        reminders: const [ReminderPolicy(offsetMinutes: 60)],
        source: SyncSource.imported,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await _database.batch((batch) {
      batch.insertAll(
        _database.petProfilesTable,
        pets.map((pet) => pet.toCompanion()).toList(),
      );
      batch.insertAll(
        _database.calendarEntriesTable,
        tasks.map((item) => item.toCompanion()).toList(),
      );
      batch.insertAll(_database.countdownItemsTable, [
        CountdownItem(
          id: _uuid.v4(),
          title: SeedCopyKey.countdownMochiBirthdayTitle,
          dueAt: now.add(const Duration(days: 28)),
          createdAt: now.subtract(const Duration(days: 2)),
          petId: selectedPet.id,
          isPinned: true,
        ).toCompanion(),
        CountdownItem(
          id: _uuid.v4(),
          title: SeedCopyKey.countdownAnnualCheckupTitle,
          dueAt: now.add(const Duration(days: 41)),
          createdAt: now,
          petId: selectedPet.id,
        ).toCompanion(),
      ]);
      batch.insertAll(
        _database.geofencePlacesTable,
        defaultGeofences().map((item) => item.toCompanion()).toList(),
      );
    });
    await savePreferences(const UserPreference.defaults());
    await _prefs.setBool(_seededKey, true);
  }

  Future<bool> hasPromptedNotificationPermission() async {
    return _prefs.getBool(_notificationPermissionPromptedKey) ?? false;
  }

  Future<void> markNotificationPermissionPrompted() async {
    await _prefs.setBool(_notificationPermissionPromptedKey, true);
  }

  Future<void> ensureDefaultPetRoster() async {
    final pets = await (_database.select(
      _database.petProfilesTable,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)])).get();
    final existingBreeds = pets
        .map((pet) => PetBreed.values.byName(pet.breed))
        .toSet();
    final hasSelected = pets.any((pet) => pet.isSelected);
    final missingCompanions = defaultPetCompanions.where(
      (companion) => !existingBreeds.contains(companion.breed),
    );
    if (missingCompanions.isEmpty && (hasSelected || pets.isEmpty)) {
      return;
    }

    await _database.transaction(() async {
      var insertedSelection = false;
      for (final companion in missingCompanions) {
        final profile = _buildPetProfile(
          companion: companion,
          createdAt: DateTime.now(),
          isSelected: !hasSelected && !insertedSelection,
        );
        await _database
            .into(_database.petProfilesTable)
            .insertOnConflictUpdate(profile.toCompanion());
        insertedSelection = insertedSelection || profile.isSelected;
      }

      if (!hasSelected && !insertedSelection && pets.isNotEmpty) {
        await (_database.update(_database.petProfilesTable)
              ..where((tbl) => tbl.id.equals(pets.first.id)))
            .write(const PetProfilesTableCompanion(isSelected: Value(true)));
      }
    });
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
      hasCompletedOnboarding: true,
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
      debugImmediateReminders: values['debugImmediateReminders'] == 'true',
      languageMode: AppLanguageMode.values.firstWhere(
        (item) => item.name == values['languageMode'],
        orElse: () => AppLanguageMode.system,
      ),
      useSystemCalendarFilter: values['useSystemCalendarFilter'] == 'true',
      visibleSystemCalendarIds: decodeJsonList(
        values['visibleSystemCalendarIds'],
      ).map((item) => item['id'].toString()).toList(),
    );
  }

  Future<void> savePreferences(UserPreference preference) async {
    final values = {
      'hasCompletedOnboarding': 'true',
      'weekStartsOnMonday': preference.weekStartsOnMonday.toString(),
      'fontScale': preference.fontScale.toString(),
      'hapticsEnabled': preference.hapticsEnabled.toString(),
      'animationSpeed': preference.animationSpeed.toString(),
      'performanceTier': preference.performanceTier.name,
      'selectedCalendarView': preference.selectedCalendarView.name,
      'faceIdEnabled': preference.faceIdEnabled.toString(),
      'debugImmediateReminders': preference.debugImmediateReminders.toString(),
      'languageMode': preference.languageMode.name,
      'useSystemCalendarFilter': preference.useSystemCalendarFilter.toString(),
      'visibleSystemCalendarIds': encodeJsonList(
        preference.visibleSystemCalendarIds
            .map((id) => <String, dynamic>{'id': id})
            .toList(),
      ),
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
    final l10n = AppLocalizations.current();
    final query = _database.select(_database.calendarEntriesTable)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
      ..limit(5);
    final rows = await query.get();
    return rows
        .map((item) => l10n.localizedStoredText(item.title))
        .toSet()
        .toList();
  }

  Future<void> upsertCalendarItem(CalendarItem item) async {
    await _database
        .into(_database.calendarEntriesTable)
        .insertOnConflictUpdate(item.toCompanion());
    _bus.fire(TaskChangedEvent(item));
  }

  Future<void> mergeImportedCalendarItems(List<CalendarItem> items) async {
    final existing =
        await (_database.select(_database.calendarEntriesTable)..where(
              (tbl) =>
                  tbl.systemEntryId.isNotNull() |
                  tbl.source.equals(SyncSource.iosCalendar.name),
            ))
            .get();
    final bySystemId = {
      for (final row in existing)
        if (row.systemEntryId != null) row.systemEntryId!: row.toDomain(),
    };
    final byContentSignature = {
      for (final row in existing)
        _calendarImportSignature(row.toDomain()): row.toDomain(),
    };

    for (final item in items) {
      final local =
          bySystemId[item.systemEntryId] ??
          byContentSignature[_calendarImportSignature(item)];
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
            systemEntryId: item.systemEntryId,
            isDeleted: false,
          ) ??
          item.copyWith(
            id: _uuid.v4(),
            source: SyncSource.iosCalendar,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          );
      await upsertCalendarItem(merged);
      if (merged.systemEntryId != null) {
        bySystemId[merged.systemEntryId!] = merged;
      }
      byContentSignature[_calendarImportSignature(merged)] = merged;
    }
  }

  Future<void> reconcileCalendarDelta(CalendarSyncDelta delta) async {
    await mergeImportedCalendarItems(delta.items);

    final windowStart = DateTime.now().subtract(const Duration(days: 93));
    final windowEnd = DateTime.now().add(const Duration(days: 366));
    final tracked =
        await (_database.select(_database.calendarEntriesTable)..where(
              (tbl) =>
                  tbl.source.equals(SyncSource.iosCalendar.name) &
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

  Future<void> toggleCountdownCelebrated(String id, bool value) async {
    final row = await (_database.select(
      _database.countdownItemsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return;
    }
    await upsertCountdown(row.toDomain().copyWith(hasCelebrated: value));
  }

  Future<void> deleteCountdown(String id) async {
    await (_database.delete(
      _database.countdownItemsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
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

  List<PetProfile> _buildDefaultPetRoster(DateTime now) {
    return [
      for (var index = 0; index < defaultPetCompanions.length; index++)
        _buildPetProfile(
          companion: defaultPetCompanions[index],
          createdAt: now.add(Duration(milliseconds: index)),
          isSelected: index == 0,
        ),
    ];
  }

  PetProfile _buildPetProfile({
    required DefaultPetCompanion companion,
    required DateTime createdAt,
    required bool isSelected,
  }) {
    final defaultSkin = defaultSkins[companion.breed]!.first;
    return PetProfile(
      id: _uuid.v4(),
      name: companion.name,
      breed: companion.breed,
      loyaltyPoints: companion.loyaltyPoints,
      selectedSkinId: defaultSkin.id,
      unlockedSkinIds: [defaultSkin.id],
      createdAt: createdAt,
      isSelected: isSelected,
    );
  }

  List<TaskTemplate> templates() {
    final l10n = AppLocalizations.current();
    return defaultTemplates
        .map(
          (template) => TaskTemplate(
            id: template.id,
            title: l10n.localizedStoredText(template.title),
            category: template.category,
            durationMinutes: template.durationMinutes,
          ),
        )
        .toList(growable: false);
  }

  int _calculateStreak(List<CalendarItem> items) {
    if (items.isEmpty) return 0;
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
    if (completedDays.isEmpty) return 0;
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (completedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

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

  String _calendarImportSignature(CalendarItem item) {
    return [
      item.title.trim(),
      item.description.trim(),
      item.startAt.millisecondsSinceEpoch,
      item.endAt.millisecondsSinceEpoch,
    ].join('|');
  }

  SceneMode inferScene(List<GeofencePlace> places) {
    return places
            .firstWhereOrNull((item) => item.sceneMode == SceneMode.walking)
            ?.sceneMode ??
        SceneMode.home;
  }
}
