import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('agenda items are sorted by reminder trigger time descending', () {
    final day = DateTime(2026, 3, 9);
    final items = [
      CalendarItem(
        id: 'walk',
        title: '下午遛狗',
        description: '',
        startAt: DateTime(day.year, day.month, day.day, 18),
        endAt: DateTime(day.year, day.month, day.day, 18, 30),
        category: CalendarCategory.pet,
        petId: null,
        reminders: const [ReminderPolicy(offsetMinutes: 180)],
        source: SyncSource.localOnly,
        createdAt: day,
        updatedAt: day,
      ),
      CalendarItem(
        id: 'meal',
        title: '下午喂食',
        description: '',
        startAt: DateTime(day.year, day.month, day.day, 14),
        endAt: DateTime(day.year, day.month, day.day, 14, 30),
        category: CalendarCategory.pet,
        petId: null,
        reminders: const [ReminderPolicy(offsetMinutes: 15)],
        source: SyncSource.localOnly,
        createdAt: day,
        updatedAt: day,
      ),
      CalendarItem(
        id: 'vet',
        title: '晚上看诊',
        description: '',
        startAt: DateTime(day.year, day.month, day.day, 20),
        endAt: DateTime(day.year, day.month, day.day, 20, 30),
        category: CalendarCategory.pet,
        petId: null,
        reminders: const [ReminderPolicy(offsetMinutes: 600)],
        source: SyncSource.localOnly,
        createdAt: day,
        updatedAt: day,
      ),
    ];

    final sorted = sortAgendaItemsByReminderTime(items);

    expect(sorted.map((item) => item.id).toList(), ['walk', 'meal', 'vet']);
  });
}
