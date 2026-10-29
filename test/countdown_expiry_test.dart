import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/snapshots/doggylog_shared_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('zh_CN'));

  test(
    'a countdown completes at its exact due time and can reopen after rescheduling',
    () {
      final dueAt = DateTime(2026, 11, 1, 12);
      final countdown = CountdownItem(
        id: 'birthday',
        title: '生日',
        dueAt: dueAt,
        createdAt: DateTime(2026, 10, 1),
      );
      expect(
        countdown.isCompletedAt(dueAt.subtract(const Duration(seconds: 1))),
        isFalse,
      );
      expect(countdown.isCompletedAt(dueAt), isTrue);
      expect(
        countdown.isCompletedAt(dueAt.add(const Duration(days: 1))),
        isTrue,
      );
      expect(
        countdown
            .copyWith(dueAt: dueAt.add(const Duration(days: 7)))
            .isCompletedAt(dueAt),
        isFalse,
      );
    },
  );

  test(
    'snapshot skips expired and manually completed countdowns, even when the calendar shows an old date',
    () {
      final now = DateTime(2026, 11, 1, 14);
      CountdownItem item(
        String id,
        DateTime dueAt, {
        bool completed = false,
        bool pinned = false,
      }) => CountdownItem(
        id: id,
        title: id,
        dueAt: dueAt,
        createdAt: DateTime(2026, 10, 1),
        hasCelebrated: completed,
        isPinned: pinned,
      );
      final state = AppState(
        preferences: const UserPreference.defaults(),
        selectedDate: DateTime(2020, 1, 1),
        calendarView: CalendarViewMode.month,
        calendarItems: const [],
        pets: const [],
        countdowns: [
          item('expired', now.subtract(const Duration(hours: 1)), pinned: true),
          item(
            'manual',
            now.add(const Duration(days: 2)),
            completed: true,
            pinned: true,
          ),
          item('next', now.add(const Duration(days: 1))),
        ],
        templates: const [],
        geofences: const [],
        recentSuggestions: const [],
      );
      final snapshot = DoggylogSharedSnapshot.fromAppState(
        state,
        mood: PetMood.calm,
        now: now,
      );
      expect(snapshot.countdown?.title, 'next');
      expect(snapshot.countdown?.daysRemaining, 2);

      final afterAll = DoggylogSharedSnapshot.fromAppState(
        state,
        mood: PetMood.calm,
        now: now.add(const Duration(days: 3)),
      );
      expect(afterAll.countdown, isNull);
    },
  );

  testWidgets(
    'expired countdown tile is completed and cannot be restored by swiping',
    (tester) async {
      final now = DateTime(2026, 11, 1, 14);
      final item = CountdownItem(
        id: 'expired',
        title: '旧纪念日',
        dueAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 30)),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTile(
              item: item,
              now: now,
              onToggleCelebrated: (_) =>
                  fail('expired countdown must stay completed'),
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('已完成'), findsWidgets);
      expect(find.textContaining('已经晚了'), findsNothing);
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.endToStart,
      );
    },
  );
}
