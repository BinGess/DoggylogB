import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/calendar/ios_calendar_sync_service.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('upsertItem strips reminders before syncing to iOS calendar', () async {
    final platform = _FakeDoggylogPlatform();
    final service = IosCalendarSyncService(platform);
    final now = DateTime(2026, 3, 9, 18, 0);
    final item = CalendarItem(
      id: 'task-1',
      title: '打疫苗',
      description: 'App 内提醒即可',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      category: CalendarCategory.pet,
      petId: null,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
      source: SyncSource.localOnly,
      createdAt: now,
      updatedAt: now,
    );

    await service.upsertItem(item);

    expect(platform.lastUpsertedItem, isNotNull);
    expect(platform.lastUpsertedItem!.reminders, isEmpty);
    expect(platform.lastUpsertedItem!.title, item.title);
    expect(platform.lastUpsertedItem!.startAt, item.startAt);
  });

  test('loadSystemCalendars delegates to platform', () async {
    final platform = _FakeDoggylogPlatform();
    final service = IosCalendarSyncService(platform);

    final calendars = await service.loadSystemCalendars();

    expect(calendars, hasLength(1));
    expect(calendars.single.title, 'DoggyLog');
    expect(calendars.single.sourceTitle, '本机');
  });

  test('syncDelta forwards selected calendar ids', () async {
    final platform = _FakeDoggylogPlatform();
    final service = IosCalendarSyncService(platform);
    final updatedAfter = DateTime(2026, 3, 10, 9);

    await service.syncDelta(
      updatedAfter: updatedAfter,
      selectedCalendarIds: const ['cal-1', 'cal-2'],
    );

    expect(platform.lastUpdatedAfter, updatedAfter);
    expect(platform.lastSelectedCalendarIds, const ['cal-1', 'cal-2']);
  });
}

class _FakeDoggylogPlatform extends DoggylogPlatform {
  CalendarItem? lastUpsertedItem;
  DateTime? lastUpdatedAfter;
  List<String>? lastSelectedCalendarIds;

  @override
  Future<String?> upsertCalendarItem(CalendarItem item) async {
    lastUpsertedItem = item;
    return 'event-1';
  }

  @override
  Future<List<SystemCalendar>> getSystemCalendars() async {
    return const [
      SystemCalendar(
        id: 'cal-1',
        title: 'DoggyLog',
        sourceTitle: '本机',
        colorHex: '#FF9500',
      ),
    ];
  }

  @override
  Future<CalendarSyncDelta?> syncCalendarDelta({
    DateTime? updatedAfter,
    List<String>? selectedCalendarIds,
  }) async {
    lastUpdatedAfter = updatedAfter;
    lastSelectedCalendarIds = selectedCalendarIds;
    return CalendarSyncDelta(
      items: const [],
      visibleSystemEntryIds: const [],
      syncedAt: DateTime(2026, 3, 10, 9, 5),
    );
  }
}
