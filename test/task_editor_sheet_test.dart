import 'package:doggylog/features/calendar/presentation/task_editor_sheet.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskEditorSheet shows delete action when editing an item', (
    tester,
  ) async {
    final now = DateTime(2026, 3, 9, 10);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TaskEditorSheet(
              item: CalendarItem(
                id: 'task-1',
                title: '疫苗提醒',
                description: '旧备注',
                startAt: now,
                endAt: now.add(const Duration(minutes: 30)),
                category: CalendarCategory.pet,
                petId: null,
                reminders: const [
                  ReminderPolicy(offsetMinutes: 15),
                ],
                source: SyncSource.localOnly,
                createdAt: now,
                updatedAt: now,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('删除'), findsOneWidget);
    expect(find.text('保存日程'), findsOneWidget);
  });

  testWidgets('TaskEditorSheet hides removed fields and only shows selected reminder', (
    tester,
  ) async {
    final now = DateTime(2026, 3, 9, 10);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TaskEditorSheet(
              item: CalendarItem(
                id: 'task-1',
                title: '疫苗提醒',
                description: '旧备注',
                startAt: now,
                endAt: now.add(const Duration(minutes: 30)),
                category: CalendarCategory.pet,
                petId: null,
                reminders: const [
                  ReminderPolicy(offsetMinutes: 15),
                ],
                source: SyncSource.localOnly,
                createdAt: now,
                updatedAt: now,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('备注'), findsNothing);
    expect(find.text('关联宠物'), findsNothing);
    expect(find.text('日常'), findsNothing);
    expect(find.text('工作'), findsNothing);
    expect(find.text('纪念日'), findsNothing);
    expect(find.text('毛孩子'), findsNothing);
    expect(find.text('提醒时间'), findsOneWidget);
    expect(find.text('提前 15 分钟'), findsOneWidget);
    expect(find.text('5 分钟前'), findsNothing);
    expect(find.text('30 分钟前'), findsNothing);
    expect(find.text('60 分钟前'), findsNothing);
  });
}
