import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskTile renders title and category label', (tester) async {
    final now = DateTime(2026, 3, 8, 9);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: TaskTile(
              item: CalendarItem(
                id: 'task',
                title: '晨间遛弯',
                description: '测试说明',
                startAt: now,
                endAt: now.add(const Duration(minutes: 30)),
                category: CalendarCategory.pet,
                petId: 'pet-1',
                reminders: const [],
                source: SyncSource.localOnly,
                createdAt: now,
                updatedAt: now,
              ),
              onToggle: (_) {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('晨间遛弯'), findsOneWidget);
    expect(find.text('宠物相关'), findsOneWidget);
  });
}
