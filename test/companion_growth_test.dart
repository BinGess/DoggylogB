import 'package:doggylog/features/shared/domain/companion_growth.dart';
import 'package:flutter_test/flutter_test.dart';

GrowthLedgerEntry entry(String id, DateTime time) => GrowthLedgerEntry(
  id: id,
  taskId: id,
  title: id,
  completedAt: time,
  dateKey: growthDateKey(time),
);

void main() {
  test(
    'daily bonus thresholds cross year and only earliest entry carries bonus',
    () {
      final entries = [
        for (var i = 0; i < 8; i++)
          entry('d$i', DateTime(2025, 12, 29 + i, 12)),
        entry('later', DateTime(2025, 12, 31, 13)),
      ];
      final g = CompanionGrowth(
        entries: entries.reversed.toList(),
      ).recalculate();
      expect(
        g.entries.where((e) => e.taskId.startsWith('d')).map((e) => e.bonusXp),
        [12, 12, 8, 8, 5, 5, 0, 0],
      );
      expect(g.entries.first.bonusXp, 0);
      expect(g.longestStreak, 8);
      expect(g.currentStreak(DateTime(2026, 1, 6)), 8);
      expect(g.currentStreak(DateTime(2026, 1, 7)), 0);
    },
  );
  test('stable identifier breaks identical completion timestamps', () {
    final time = DateTime(2026, 2, 3, 12);
    final g = CompanionGrowth(
      entries: [
        entry('z', time),
        entry('a', time),
        entry('day1', DateTime(2026, 2, 1)),
        entry('day2', DateTime(2026, 2, 2)),
      ],
    ).recalculate();
    expect(g.entries.first.bonusXp, 0);
    expect(g.entries[1].bonusXp, 5);
  });
  test('removing middle day recalculates later bonuses, levels and badges', () {
    final g = CompanionGrowth(
      entries: [
        for (var i = 1; i <= 7; i++) entry('$i', DateTime(2026, 1, i, 12)),
      ],
    ).recalculate();
    expect(g.totalXp, 108);
    expect(g.level, 2);
    expect(g.badgeIds, containsAll(['s3', 's7']));
    final after = g
        .copyWith(
          entries: g.entries
              .map((e) => e.id == '3' ? e.copyWith(active: false) : e)
              .toList(),
        )
        .recalculate();
    expect(after.totalXp, 70);
    expect(after.level, 1);
    expect(after.longestStreak, 4);
    expect(after.badgeIds, isNot(contains('s7')));
    expect(after.currentStreak(DateTime(2026, 1, 7)), 4);
  });
  test('month boundary and leap day are consecutive calendar dates', () {
    final g = CompanionGrowth(
      entries: [
        entry('1', DateTime(2024, 2, 28)),
        entry('2', DateTime(2024, 2, 29)),
        entry('3', DateTime(2024, 3, 1)),
      ],
    ).recalculate();
    expect(g.totalXp, 35);
    expect(g.currentStreak(DateTime(2024, 3, 2)), 3);
    expect(g.currentStreak(DateTime(2024, 3, 3)), 0);
  });
  test('level thresholds, title and default badge', () {
    expect(const CompanionGrowth().badgeIds, ['lv1']);
    for (final xp in [0, 99, 100, 199, 200, 400, 600, 900]) {
      final g = CompanionGrowth(baseXp: xp);
      expect(g.level, xp ~/ 100 + 1);
      expect(g.levelXp, xp % 100);
      expect(g.nextLevelXp, 100 - xp % 100);
    }
    expect(const CompanionGrowth(baseXp: 900).titleBadgeId, 'lv10');
  });
}
