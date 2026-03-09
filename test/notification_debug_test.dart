import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/notifications/doggylog_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug reminder preview only fires for active tasks with reminders', () {
    final now = DateTime(2026, 3, 9, 20);
    final item = CalendarItem(
      id: 'task-1',
      title: '晚饭',
      description: '',
      startAt: now.add(const Duration(hours: 1)),
      endAt: now.add(const Duration(hours: 2)),
      category: CalendarCategory.pet,
      petId: null,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
      source: SyncSource.localOnly,
      createdAt: now,
      updatedAt: now,
    );

    expect(
      shouldFireDebugReminderPreview(
        debugImmediateReminders: true,
        item: item,
      ),
      isTrue,
    );
    expect(
      shouldFireDebugReminderPreview(
        debugImmediateReminders: false,
        item: item,
      ),
      isFalse,
    );
    expect(
      shouldFireDebugReminderPreview(
        debugImmediateReminders: true,
        item: item.copyWith(reminders: const []),
      ),
      isFalse,
    );
    expect(
      shouldFireDebugReminderPreview(
        debugImmediateReminders: true,
        item: item.copyWith(isCompleted: true),
      ),
      isFalse,
    );
  });
}
