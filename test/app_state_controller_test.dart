import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_state_test_harness.dart';

void main() {
  Future<void> saveTask(
    AppStateTestHarness harness, {
    String? id,
    required String title,
  }) {
    final now = DateTime(2026, 3, 12, 9);
    return harness.container.read(appStateProvider.notifier).saveTask(
      id: id,
      title: title,
      description: '',
      startAt: now,
      endAt: now.add(const Duration(minutes: 30)),
      category: CalendarCategory.pet,
      petId: null,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
    );
  }

  CalendarItem existingItem(String id) {
    final now = DateTime(2026, 3, 12, 8);
    return CalendarItem(
      id: id,
      title: '已存在日程',
      description: '',
      startAt: now,
      endAt: now.add(const Duration(minutes: 30)),
      category: CalendarCategory.pet,
      petId: null,
      reminders: const [ReminderPolicy(offsetMinutes: 15)],
      source: SyncSource.localOnly,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('AppStateController hydrates notification permission status on init', () async {
    final harness = await AppStateTestHarness.create(
      initialNotificationPermissionGranted: true,
    );
    addTearDown(harness.dispose);

    expect(
      harness.container.read(appStateProvider).notificationPermissionGranted,
      isTrue,
    );
    expect(harness.notifications.permissionStatusCheckCallCount, 1);
  });

  test(
    'AppStateController requests notification permission after the first user-created task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('seeded-task')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, title: '第一次手动新建');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 1);
      expect(
        harness.container.read(appStateProvider).notificationPermissionGranted,
        isTrue,
      );
    },
  );

  test(
    'AppStateController does not request notification permission after the second user-created task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('seeded-task')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, title: '第一次手动新建');
      await harness.settle();
      harness.notifications.requestPermissionsCallCount = 0;

      await saveTask(harness, title: '第二次手动新建');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 0);
    },
  );

  test(
    'AppStateController does not request notification permission when editing a task',
    () async {
      final harness = await AppStateTestHarness.create(
        initialCalendarItems: [existingItem('task-1')],
      );
      addTearDown(harness.dispose);

      await saveTask(harness, id: 'task-1', title: '编辑后的标题');
      await harness.settle();

      expect(harness.notifications.requestPermissionsCallCount, 0);
    },
  );
}
