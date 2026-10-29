import 'dart:convert';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/data/app_database.dart';
import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late AppRepository repo;
  late DomainEventBus bus;
  late DateTime now;
  late SharedPreferences prefs;
  CalendarItem task(
    String id, {
    bool completed = false,
    SyncSource source = SyncSource.localOnly,
  }) => CalendarItem(
    id: id,
    title: id,
    description: '',
    startAt: DateTime(2020, 1, 1),
    endAt: DateTime(2020, 1, 1, 1),
    category: CalendarCategory.daily,
    petId: null,
    reminders: const [],
    source: source,
    createdAt: now,
    updatedAt: now,
    isCompleted: completed,
  );
  Future<void> complete(String id) async {
    await repo.upsertCalendarItem(task(id));
    await repo.toggleCalendarItemCompletion(id, true);
  }

  Future<void> consecutive(int days) async {
    for (var i = 1; i <= days; i++) {
      now = DateTime(2026, 1, i, 12);
      await complete('d$i');
    }
  }

  Future<CalendarItem> stored(String id) async => (await (db.select(
    db.calendarEntriesTable,
  )..where((t) => t.id.equals(id))).getSingle()).toDomain();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    bus = DomainEventBus();
    now = DateTime(2026, 1, 1, 12);
    repo = AppRepository(db, prefs, bus, now: () => now);
  });
  tearDown(() async {
    await db.close();
    await bus.dispose();
  });

  test(
    'fresh account ignores all legacy points, old growth and completed tasks',
    () async {
      await db
          .into(db.petProfilesTable)
          .insert(
            PetProfile(
              id: 'pet',
              name: 'old',
              breed: PetBreed.shiba,
              loyaltyPoints: 900,
              selectedSkinId: 'old',
              unlockedSkinIds: const [],
              createdAt: now,
              isSelected: true,
            ).toCompanion(),
          );
      await db
          .into(db.calendarEntriesTable)
          .insert(task('old', completed: true).toCompanion());
      await db
          .into(db.loyaltyLedgersTable)
          .insert(
            LoyaltyLedger(
              id: 'old',
              petId: 'pet',
              calendarItemId: 'old',
              points: 22,
              createdAt: now,
              reason: 'old',
            ).toCompanion(),
          );
      await db.customStatement(
        'INSERT INTO preferences_table (key, value) VALUES (?, ?)',
        [
          'companionGrowth.v1',
          jsonEncode(const CompanionGrowth(baseXp: 900).toJson()),
        ],
      );
      expect((await repo.loadGrowth()).totalXp, 0);
      await repo.toggleCalendarItemCompletion('old', true);
      await repo.toggleCalendarItemCompletion('old', false);
      expect((await repo.loadGrowth()).totalXp, 0);
      now = DateTime(2026, 1, 2, 12);
      await repo.toggleCalendarItemCompletion('old', true);
      expect((await repo.loadGrowth()).entries.single.dateKey, '2026-01-02');
      final reopened = AppRepository(db, prefs, bus);
      expect((await reopened.loadGrowth()).totalXp, 10);
      expect(
        (await db.select(db.petProfilesTable).getSingle()).loyaltyPoints,
        900,
      );
    },
  );
  test(
    'concurrent true and repeated false are idempotent without petId',
    () async {
      await repo.upsertCalendarItem(task('a'));
      await Future.wait(
        List.generate(8, (_) => repo.toggleCalendarItemCompletion('a', true)),
      );
      expect((await repo.loadGrowth()).totalXp, 10);
      expect(
        (await repo.loadGrowth()).entries.where((e) => e.active),
        hasLength(1),
      );
      await Future.wait(
        List.generate(8, (_) => repo.toggleCalendarItemCompletion('a', false)),
      );
      expect((await repo.loadGrowth()).totalXp, 0);
    },
  );
  test(
    'daily bonus transfers and audit preserves net changes and original title',
    () async {
      await consecutive(3);
      now = now.add(const Duration(minutes: 1));
      await complete('b');
      expect((await repo.loadGrowth()).totalXp, 45);
      final preview = await repo.previewGrowthRemoval('d3');
      expect(preview.delta, -10);
      expect(
        (await repo.loadGrowth()).totalXp,
        45,
      ); // Canceling preview does nothing.
      await repo.toggleCalendarItemCompletion(
        'd3',
        false,
        expectedRevision: preview.before.revision,
      );
      var g = await repo.loadGrowth();
      expect(g.totalXp, 35);
      expect(g.entries.firstWhere((e) => e.taskId == 'b').bonusXp, 5);
      expect(g.audit.last.delta, -10);
      expect(g.audit.last.adjustments.values.toList()..sort(), [-15, 5]);
      await repo.upsertCalendarItem(
        (await stored('b')).copyWith(title: 'renamed', startAt: DateTime(2030)),
      );
      g = await repo.loadGrowth();
      expect(g.entries.firstWhere((e) => e.taskId == 'b').title, 'b');
      expect(g.totalXp, 35);
      expect(
        g.entries.firstWhere((e) => e.taskId == 'b').dateKey,
        '2026-01-03',
      );
      await repo.deleteCalendarItem('b');
      g = await repo.loadGrowth();
      expect(g.totalXp, 20);
      expect(g.audit.last.delta, -15);
    },
  );
  test(
    'deleting middle day revokes downstream bonus and badge then redoing uses new day',
    () async {
      await consecutive(7);
      final preview = await repo.previewGrowthRemoval('d3', deleting: true);
      expect(preview.delta, -38);
      expect(preview.revokedBadgeIds, contains('s7'));
      await repo.deleteCalendarItem(
        'd3',
        expectedRevision: preview.before.revision,
      );
      expect((await repo.loadGrowth()).totalXp, 70);
      expect((await stored('d3')).isDeleted, true);
      await repo.toggleCalendarItemCompletion('d7', false);
      now = DateTime(2026, 1, 10, 12);
      await repo.toggleCalendarItemCompletion('d7', true);
      final g = await repo.loadGrowth();
      expect(g.entries.where((e) => e.taskId == 'd7'), hasLength(2));
      expect(
        g.entries.singleWhere((e) => e.taskId == 'd7' && e.active).dateKey,
        '2026-01-10',
      );
      expect(
        g.entries.singleWhere((e) => e.taskId == 'd7' && !e.active).reason,
        'undo',
      );
    },
  );
  test('stale preview rejected without changing task', () async {
    await complete('a');
    final preview = await repo.previewGrowthRemoval('a');
    await complete('b');
    await expectLater(
      repo.deleteCalendarItem('a', expectedRevision: preview.before.revision),
      throwsA(isA<GrowthPreviewChanged>()),
    );
    expect((await stored('a')).isDeleted, false);
    expect((await repo.loadGrowth()).totalXp, 20);
  });
  test('system sources and countdown never award XP', () async {
    for (final source in SyncSource.values.where(
      (e) => e != SyncSource.localOnly,
    )) {
      await repo.upsertCalendarItem(task(source.name, source: source));
      await repo.toggleCalendarItemCompletion(source.name, true);
    }
    await repo.upsertCountdown(
      CountdownItem(id: 'count', title: 'count', dueAt: now, createdAt: now),
    );
    await repo.toggleCountdownCelebrated('count', true);
    expect((await repo.loadGrowth()).totalXp, 0);
  });
  test(
    'badge celebration history survives revocation and restoration',
    () async {
      final events = <GrowthUpdatedEvent>[];
      final sub = bus.stream
          .where((e) => e is GrowthUpdatedEvent)
          .cast<GrowthUpdatedEvent>()
          .listen(events.add);
      await consecutive(3);
      await Future<void>.delayed(Duration.zero);
      expect(events.last.change.newBadgeIds, contains('s3'));
      await repo.acknowledgeGrowthBadges(['s3']);
      await repo.toggleCalendarItemCompletion('d3', false);
      await repo.toggleCalendarItemCompletion('d3', true);
      await Future<void>.delayed(Duration.zero);
      expect(events.last.change.after.badgeIds, contains('s3'));
      expect(events.last.change.newBadgeIds, isEmpty);
      await sub.cancel();
    },
  );
  test(
    'SQLite growth write failure rolls back task, ledger, XP and emits no reward',
    () async {
      await repo.upsertCalendarItem(task('a'));
      final before = await repo.loadGrowth();
      final events = <DomainEvent>[];
      final sub = bus.stream.listen(events.add);
      await db.customStatement(
        "CREATE TRIGGER fail_growth BEFORE INSERT ON preferences_table WHEN NEW.key = 'companionGrowth.fresh.v2' BEGIN SELECT RAISE(ABORT, 'injected fault'); END",
      );
      await expectLater(
        repo.toggleCalendarItemCompletion('a', true),
        throwsA(anything),
      );
      expect((await stored('a')).isCompleted, false);
      expect((await repo.loadGrowth()).toJson(), before.toJson());
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      await db.customStatement('DROP TRIGGER fail_growth');
      await repo.toggleCalendarItemCompletion('a', true);
      expect((await repo.loadGrowth()).totalXp, 10);
      await sub.cancel();
    },
  );
  test(
    'initialization failure preserves legacy data and retry starts once at zero',
    () async {
      await db.into(db.calendarEntriesTable).insert(task('a').toCompanion());
      await db.customStatement(
        "CREATE TRIGGER fail_init BEFORE INSERT ON preferences_table BEGIN SELECT RAISE(ABORT, 'init fault'); END",
      );
      await expectLater(
        repo.toggleCalendarItemCompletion('a', true),
        throwsA(anything),
      );
      expect((await stored('a')).isCompleted, false);
      await db.customStatement('DROP TRIGGER fail_init');
      await repo.toggleCalendarItemCompletion('a', true);
      expect((await repo.loadGrowth()).totalXp, 10);
    },
  );
  test(
    'corrupt initialized account fails closed without completing task',
    () async {
      await repo.upsertCalendarItem(task('a'));
      await db.customStatement(
        "UPDATE preferences_table SET value = 'corrupt' WHERE key = 'companionGrowth.fresh.v2'",
      );
      await expectLater(
        repo.toggleCalendarItemCompletion('a', true),
        throwsA(anything),
      );
      expect((await stored('a')).isCompleted, false);
    },
  );
}
