import 'dart:convert';
import 'dart:io';

import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class CalendarEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get startAt => integer()();
  IntColumn get endAt => integer()();
  TextColumn get category => text()();
  TextColumn get petId => text().nullable()();
  TextColumn get remindersJson => text().withDefault(const Constant('[]'))();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get systemEntryId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PetProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get breed => text()();
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();
  TextColumn get selectedSkinId => text()();
  TextColumn get unlockedSkinIdsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get createdAt => integer()();
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CountdownItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get dueAt => integer()();
  IntColumn get createdAt => integer()();
  TextColumn get petId => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get hasCelebrated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LoyaltyLedgersTable extends Table {
  TextColumn get id => text()();
  TextColumn get petId => text()();
  TextColumn get calendarItemId => text()();
  IntColumn get points => integer()();
  IntColumn get createdAt => integer()();
  TextColumn get reason => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GeofencePlacesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get radiusMeters => real()();
  TextColumn get sceneMode => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PreferencesTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    CalendarEntriesTable,
    PetProfilesTable,
    CountdownItemsTable,
    LoyaltyLedgersTable,
    GeofencePlacesTable,
    PreferencesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'doggylog.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

extension CalendarItemsRowX on CalendarItem {
  CalendarEntriesTableCompanion toCompanion() {
    return CalendarEntriesTableCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      startAt: startAt.millisecondsSinceEpoch,
      endAt: endAt.millisecondsSinceEpoch,
      category: category.name,
      petId: Value(petId),
      remindersJson: Value(
        jsonEncode(reminders.map((item) => item.toJson()).toList()),
      ),
      source: source.name,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
      systemEntryId: Value(systemEntryId),
      isCompleted: Value(isCompleted),
      isDeleted: Value(isDeleted),
    );
  }
}

extension CalendarItemDataX on CalendarEntriesTableData {
  CalendarItem toDomain() {
    final reminders = (jsonDecode(remindersJson) as List<dynamic>)
        .map((item) => ReminderPolicy.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return CalendarItem(
      id: id,
      title: title,
      description: description,
      startAt: DateTime.fromMillisecondsSinceEpoch(startAt),
      endAt: DateTime.fromMillisecondsSinceEpoch(endAt),
      category: CalendarCategory.values.byName(category),
      petId: petId,
      reminders: reminders,
      source: SyncSource.values.byName(source),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      systemEntryId: systemEntryId,
      isCompleted: isCompleted,
      isDeleted: isDeleted,
    );
  }
}

extension PetProfileDataX on PetProfilesTableData {
  PetProfile toDomain() {
    final unlockedIds = (jsonDecode(unlockedSkinIdsJson) as List<dynamic>)
        .map((item) => item.toString())
        .toList();
    return PetProfile(
      id: id,
      name: name,
      breed: PetBreed.values.byName(breed),
      loyaltyPoints: loyaltyPoints,
      selectedSkinId: selectedSkinId,
      unlockedSkinIds: unlockedIds,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      isSelected: isSelected,
    );
  }
}

extension PetProfileX on PetProfile {
  PetProfilesTableCompanion toCompanion() {
    return PetProfilesTableCompanion.insert(
      id: id,
      name: name,
      breed: breed.name,
      loyaltyPoints: Value(loyaltyPoints),
      selectedSkinId: selectedSkinId,
      unlockedSkinIdsJson: Value(jsonEncode(unlockedSkinIds)),
      createdAt: createdAt.millisecondsSinceEpoch,
      isSelected: Value(isSelected),
    );
  }
}

extension CountdownItemDataX on CountdownItemsTableData {
  CountdownItem toDomain() {
    return CountdownItem(
      id: id,
      title: title,
      dueAt: DateTime.fromMillisecondsSinceEpoch(dueAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      petId: petId,
      isPinned: isPinned,
      hasCelebrated: hasCelebrated,
    );
  }
}

extension CountdownItemX on CountdownItem {
  CountdownItemsTableCompanion toCompanion() {
    return CountdownItemsTableCompanion.insert(
      id: id,
      title: title,
      dueAt: dueAt.millisecondsSinceEpoch,
      createdAt: createdAt.millisecondsSinceEpoch,
      petId: Value(petId),
      isPinned: Value(isPinned),
      hasCelebrated: Value(hasCelebrated),
    );
  }
}

extension LoyaltyLedgerX on LoyaltyLedger {
  LoyaltyLedgersTableCompanion toCompanion() {
    return LoyaltyLedgersTableCompanion.insert(
      id: id,
      petId: petId,
      calendarItemId: calendarItemId,
      points: points,
      createdAt: createdAt.millisecondsSinceEpoch,
      reason: reason,
    );
  }
}

extension LoyaltyLedgerDataX on LoyaltyLedgersTableData {
  LoyaltyLedger toDomain() {
    return LoyaltyLedger(
      id: id,
      petId: petId,
      calendarItemId: calendarItemId,
      points: points,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      reason: reason,
    );
  }
}

extension GeofencePlaceX on GeofencePlace {
  GeofencePlacesTableCompanion toCompanion() {
    return GeofencePlacesTableCompanion.insert(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      sceneMode: sceneMode.name,
    );
  }
}

extension GeofencePlaceDataX on GeofencePlacesTableData {
  GeofencePlace toDomain() {
    return GeofencePlace(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      sceneMode: SceneMode.values.byName(sceneMode),
    );
  }
}
