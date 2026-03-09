import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:doggylog/features/countdown/presentation/countdown_detail_sheet.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/compact_date_time_field.dart';
import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

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

  testWidgets('CreateEntryScreen uses lightweight date and time sheets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CreateEntryScreen())),
    );

    expect(find.text('全天事项'), findsNothing);

    await tester.tap(find.text('12:00').first);
    await tester.pumpAndSettle();

    expect(find.text('选择时间'), findsOneWidget);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('年').first);
    await tester.pumpAndSettle();

    expect(find.text('选择日期'), findsOneWidget);
  });

  testWidgets('CompactDateTimeField renders split date and time chips', (
    tester,
  ) async {
    final value = DateTime(2026, 3, 9, 10, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactDateTimeField(
            label: '开始时间',
            value: value,
            datePattern: 'yyyy/MM/dd',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('2026/03/09'), findsOneWidget);
    expect(find.text('10:15'), findsOneWidget);
  });

  testWidgets('CompactDateTimeField hides leading icons when disabled', (
    tester,
  ) async {
    final value = DateTime(2026, 3, 9, 10, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactDateTimeField(
            label: '倒计时目标时间',
            value: value,
            showIcons: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.calendar_today_rounded), findsNothing);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
  });

  testWidgets('CountdownTile supports swipe actions and tap details', (
    tester,
  ) async {
    final now = DateTime(2026, 3, 9, 10);
    var celebrated = false;
    var deleted = false;
    var openedDetail = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: CountdownTile(
              item: CountdownItem(
                id: 'countdown-1',
                title: '驱虫提醒',
                dueAt: now.add(const Duration(days: 5)),
                createdAt: now.subtract(const Duration(days: 2)),
              ),
              now: now,
              onToggleCelebrated: (value) => celebrated = value,
              onDelete: () => deleted = true,
              onTap: () => openedDetail = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('驱虫提醒'), findsOneWidget);

    await tester.tap(find.text('驱虫提醒'));
    await tester.pumpAndSettle();
    expect(openedDetail, isTrue);

    await tester.drag(find.byType(CountdownTile), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(celebrated, isTrue);

    await tester.drag(find.byType(CountdownTile), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });

  testWidgets('CountdownDetailSheet hides summary text and target icons', (
    tester,
  ) async {
    final now = DateTime(2026, 3, 9, 10);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: CountdownDetailSheet(
              item: CountdownItem(
                id: 'countdown-1',
                title: '驱虫提醒',
                dueAt: now.add(const Duration(days: 5)),
                createdAt: now.subtract(const Duration(days: 2)),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('目标日期：'), findsNothing);
    expect(find.byIcon(Icons.calendar_today_rounded), findsNothing);
    expect(find.byIcon(Icons.schedule_rounded), findsNothing);
  });

  testWidgets(
    'HomeShell shows countdown calendar mine tabs and defaults to calendar',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeShell())),
      );
      await tester.pump();

      expect(find.text('倒计时'), findsOneWidget);
      expect(find.text('日历'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
      expect(find.text('复盘'), findsNothing);
      expect(find.text('设置'), findsNothing);

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 1);
    },
  );

  testWidgets('HomeShell uses compact bottom navigation height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeShell())),
    );
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    final padding = tester
        .widgetList<Padding>(find.byType(Padding))
        .firstWhere(
          (widget) =>
              widget.padding == const EdgeInsets.fromLTRB(16, 0, 16, 12),
        );

    expect(navigationBar.height, 64);
    expect(padding.padding, const EdgeInsets.fromLTRB(16, 0, 16, 12));
  });

  testWidgets('SettingsScreen shows task review card at the top', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );
    await tester.pump();

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('任务复盘'), findsOneWidget);
    expect(find.text('完成率'), findsOneWidget);
    expect(find.text('分类分布'), findsOneWidget);
  });
}
