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
}

class _FakeDoggylogPlatform extends DoggylogPlatform {
  CalendarItem? lastUpsertedItem;

  @override
  Future<String?> upsertCalendarItem(CalendarItem item) async {
    lastUpsertedItem = item;
    return 'event-1';
  }
}
