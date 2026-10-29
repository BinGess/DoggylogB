import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/growth/presentation/growth_actions.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'support/app_state_test_harness.dart';

Widget app(AppStateTestHarness h, Widget home) => UncontrolledProviderScope(
  container: h.container,
  child: MaterialApp(
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  ),
);
CalendarItem task(String id) {
  final now = DateTime.now();
  return CalendarItem(
    id: id,
    title: id,
    description: '',
    startAt: now,
    endAt: now.add(const Duration(hours: 1)),
    category: CalendarCategory.daily,
    petId: null,
    reminders: const [],
    source: SyncSource.localOnly,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> finish(WidgetTester tester, AppStateTestHarness h) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() => h.dispose());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });
  testWidgets(
    'merged card exposes independent dress and growth targets with 44px minimum',
    (tester) async {
      final h = (await tester.runAsync(() => AppStateTestHarness.create()))!;
      await tester.pumpWidget(app(h, const SettingsScreen()));
      await tester.pumpAndSettle();
      final dress = find.byKey(const Key('growth-dress-up'));
      final details = find.byKey(const Key('growth-details'));
      expect(tester.getSize(dress).height, greaterThanOrEqualTo(44));
      expect(tester.getSize(dress).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(details).height, greaterThanOrEqualTo(44));
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(find.text('陪伴成长'), findsOneWidget);
      expect(find.text('经验明细'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await tester.tap(dress);
      await tester.pumpAndSettle();
      expect(find.text('现在这套'), findsWidgets);
      await finish(tester, h);
    },
  );
  testWidgets('canceling removal preview does not change task or XP', (
    tester,
  ) async {
    final h = (await tester.runAsync(() async {
      final h = await AppStateTestHarness.create(
        initialCalendarItems: [task('a')],
      );
      await h.repository.toggleCalendarItemCompletion('a', true);
      await h.settle();
      return h;
    }))!;
    await tester.pumpWidget(
      app(
        h,
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => performGrowthAction(context, ref, 'a'),
              child: const Text('undo'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('undo'));
    await tester.runAsync(() => h.settle());
    await tester.pumpAndSettle();
    expect(find.textContaining('10 → 0'), findsOneWidget);
    await tester.tap(find.text('保留原状'));
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(() => h.repository.loadGrowth()))!.totalXp,
      10,
    );
    await tester.tap(find.text('undo'));
    await tester.runAsync(() => h.settle());
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.runAsync(() => h.settle());
    await tester.pumpAndSettle();
    expect(
      (await tester.runAsync(() => h.repository.loadGrowth()))!.totalXp,
      0,
    );
    await finish(tester, h);
  });
  testWidgets(
    'level and badge share one celebration; dismissal keeps awarded XP',
    (tester) async {
      final h = (await tester.runAsync(() async {
        final h = await AppStateTestHarness.create();
        for (var i = 0; i < 19; i++) {
          await h.repository.upsertCalendarItem(task('$i'));
          await h.repository.toggleCalendarItemCompletion('$i', true);
        }
        await h.repository.upsertCalendarItem(task('last'));
        await h.settle();
        return h;
      }))!;
      await tester.pumpWidget(
        app(
          h,
          GrowthFeedbackHost(
            child: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: TextButton(
                  onPressed: () => performGrowthAction(
                    context,
                    ref,
                    'last',
                    completing: true,
                  ),
                  child: const Text('complete'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('complete'));
      await tester.runAsync(() => h.settle());
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('升级到 Lv3'), findsOneWidget);
      expect(find.text('认真陪跑员'), findsOneWidget);
      await tester.tap(find.text('继续安排'));
      await tester.runAsync(() => h.settle());
      await tester.pumpAndSettle();
      final growth = (await tester.runAsync(() => h.repository.loadGrowth()))!;
      expect(growth.totalXp, 200);
      expect(growth.seenBadgeIds, contains('lv3'));
      await finish(tester, h);
    },
  );
}
