import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/calendar/presentation/calendar_theme_assets.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:doggylog/features/countdown/presentation/countdown_detail_sheet.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/compact_date_time_field.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_circle_icon_button.dart';
import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/task_tile.dart';
import 'package:doggylog/platform/purchases/doggylog_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('ja_JP');
  });

  Future<void> pumpSettingsScreen(
    WidgetTester tester, {
    Locale? locale,
    ThemeData? theme,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme:
              theme ??
              AppTheme.light(fontScale: 1.0, skinTheme: AppSkinTheme.shibaJoy),
          locale: locale ?? const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

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
    expect(find.text('毛孩子'), findsOneWidget);
  });

  testWidgets('CalendarScreen empty agenda shows dog image and new copy', (
    tester,
  ) async {
    final expectedAsset = calendarTimelineAssetsForTheme(
      AppSkinTheme.shibaJoy,
    ).pngAssetPath;
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CalendarScreen())),
    );

    expect(find.text('今天还空空的，点右上角记一件吧'), findsOneWidget);

    final image = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == expectedAsset,
      ),
    );

    expect(image.fit, BoxFit.contain);
  });

  testWidgets('CalendarScreen compact selected paw badge stays restrained', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CalendarScreen())),
    );
    await tester.pumpAndSettle();

    final pawImages = tester
        .widgetList<Image>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    'assets/images/calendar/paw_badge_selected.png',
          ),
        )
        .toList();

    expect(pawImages, isNotEmpty);
    expect(pawImages.every((image) => (image.width ?? 0) <= 58), isTrue);
  });

  testWidgets('CalendarScreen month selected paw badge stays restrained', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CalendarScreen())),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.text('下拉展开月历'), const Offset(0, 300), 1200);
    await tester.pumpAndSettle();

    final pawImages = tester
        .widgetList<Image>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    'assets/images/calendar/paw_badge_selected.png',
          ),
        )
        .toList();

    expect(find.text('上滑收起月历'), findsOneWidget);
    expect(pawImages, isNotEmpty);
    expect(pawImages.every((image) => (image.width ?? 0) <= 58), isTrue);
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

    expect(find.text('选个时间'), findsOneWidget);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('年').first);
    await tester.pumpAndSettle();

    expect(find.text('选个日期'), findsOneWidget);
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

  testWidgets('SoftCircleIconButton keeps calendar add button size and fill', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: SoftCircleIconButton(
              onTap: () => tapped = true,
              icon: Icons.add_rounded,
              tooltip: '添加',
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(SoftCircleIconButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(container.constraints?.maxWidth, 58);
    expect(container.constraints?.maxHeight, 58);
    expect(
      decoration.color,
      ThemeData(useMaterial3: true).colorScheme.surface.withValues(alpha: 0.86),
    );

    await tester.tap(find.byType(SoftCircleIconButton));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('LiquidGlassCard keeps borders and highlights restrained', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(fontScale: 1.0, skinTheme: AppSkinTheme.shibaJoy),
        home: const Scaffold(
          body: Center(child: LiquidGlassCard(child: Text('清爽卡片'))),
        ),
      ),
    );

    final decorations = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(LiquidGlassCard),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .toList();
    final outer = decorations.firstWhere(
      (decoration) => (decoration.boxShadow?.isNotEmpty ?? false),
    );
    final inner = decorations.firstWhere(
      (decoration) =>
          decoration.gradient != null &&
          !(decoration.boxShadow?.isNotEmpty ?? false) &&
          decoration.border == null,
    );
    final outerGradient = outer.gradient! as LinearGradient;
    final innerGradient = inner.gradient! as LinearGradient;
    final border = outer.border! as Border;

    expect(outerGradient.colors.last.computeLuminance(), greaterThan(0.94));
    expect((border.top.color.a * 255).round(), lessThanOrEqualTo(96));
    expect(
      (outer.boxShadow!.first.color.a * 255).round(),
      lessThanOrEqualTo(24),
    );
    expect((innerGradient.colors.first.a * 255).round(), lessThanOrEqualTo(28));
  });

  testWidgets('CountdownScreen renders title inline without AppBar', (
    tester,
  ) async {
    final theme = AppTheme.light(
      fontScale: 1.0,
      skinTheme: AppSkinTheme.shibaJoy,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: theme, home: const CountdownScreen()),
      ),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('陪伴式倒计时'), findsNothing);
    expect(find.text('倒计时'), findsOneWidget);
    expect(find.byType(SoftCircleIconButton), findsOneWidget);

    final title = tester.widget<Text>(find.text('倒计时'));
    expect(title.style?.fontSize, theme.textTheme.headlineMedium?.fontSize);
  });

  testWidgets('SettingsScreen renders title inline without AppBar', (
    tester,
  ) async {
    final theme = AppTheme.light(
      fontScale: 1.0,
      skinTheme: AppSkinTheme.shibaJoy,
    );

    await pumpSettingsScreen(tester, theme: theme);

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('我的'), findsOneWidget);

    final title = tester.widget<Text>(find.text('我的'));
    expect(title.style?.fontSize, theme.textTheme.headlineMedium?.fontSize);
  });

  testWidgets('SettingsScreen defaults font size selection to medium', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    final mediumChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '中'),
    );
    final smallChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '小'),
    );

    expect(mediumChip.selected, isTrue);
    expect(smallChip.selected, isFalse);
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

      expect(
        find.byKey(const Key('home-tab-calendar-selected')),
        findsOneWidget,
      );
    },
  );

  testWidgets('HomeShell can start on countdown tab from deep link target', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeShell(initialTabId: 'countdown')),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('home-tab-countdown-selected')),
      findsOneWidget,
    );
  });

  testWidgets('HomeShell uses compact bottom navigation height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeShell())),
    );
    await tester.pump();

    final padding = tester
        .widgetList<Padding>(find.byType(Padding))
        .firstWhere(
          (widget) =>
              widget.padding == const EdgeInsets.fromLTRB(16, 0, 16, 12),
        );
    final barRect = tester.getRect(
      find.byKey(const Key('home-bottom-tab-bar')),
    );
    final labelRect = tester.getRect(find.text('日历'));

    expect(barRect.height, 64);
    expect(barRect.bottom - labelRect.bottom, lessThanOrEqualTo(12));
    expect(padding.padding, const EdgeInsets.fromLTRB(16, 0, 16, 12));
  });

  testWidgets('SettingsScreen shows settings section', (tester) async {
    await pumpSettingsScreen(tester);

    expect(find.text('我的'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('字体大小'), findsOneWidget);
    expect(find.text('小'), findsOneWidget);
    expect(find.text('中'), findsOneWidget);
    expect(find.text('大'), findsOneWidget);
    expect(find.text('开发调试'), findsOneWidget);
    expect(find.text('动效强度'), findsNothing);
    expect(find.text('iOS 增强能力'), findsNothing);
  });

  testWidgets('SettingsScreen shows a dedicated restore purchases entry', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    expect(
      find.byKey(const Key('settings-restore-purchases-tile')),
      findsOneWidget,
    );
  });

  testWidgets('SettingsScreen restore purchases button triggers restore flow', (
    tester,
  ) async {
    final purchaseService = _FakePurchaseService(
      RestorePurchasesResult.requested,
    );
    await pumpSettingsScreen(
      tester,
      overrides: [purchaseServiceProvider.overrideWithValue(purchaseService)],
    );

    final restoreButton = find.byKey(
      const Key('settings-restore-purchases-tile'),
    );
    await tester.ensureVisible(restoreButton);
    await tester.pump();
    await tester.tap(restoreButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(purchaseService.restoreCallCount, 1);
    expect(
      find.text('已经向 App Store 发起恢复购买请求啦，如有可恢复项目，系统会继续同步。'),
      findsOneWidget,
    );
  });

  testWidgets('SettingsScreen opens language picker modal and updates choice', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    expect(find.byKey(const Key('settings-language-tile')), findsOneWidget);
    expect(find.byKey(const Key('language-picker-sheet')), findsNothing);

    await tester.tap(find.byKey(const Key('settings-language-tile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('language-picker-sheet')), findsOneWidget);
    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('中文'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('日语'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-option-en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('language-picker-sheet')), findsNothing);
    expect(find.byKey(const Key('settings-language-tile')), findsOneWidget);
  });

  testWidgets('SettingsScreen localizes the biometric toggle label', (
    tester,
  ) async {
    await pumpSettingsScreen(tester, locale: const Locale('en'));
    await tester.pump();

    expect(find.text('Biometric unlock'), findsOneWidget);
    expect(find.text('Face ID / Touch ID'), findsNothing);
  });

  testWidgets(
    'SettingsScreen opens development debug page from settings footer',
    (tester) async {
      await pumpSettingsScreen(tester);

      final debugTile = find.widgetWithText(ListTile, '开发调试');
      await tester.ensureVisible(debugTile);
      await tester.pump();
      await tester.tap(debugTile, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('开发调试'), findsWidgets);
      expect(find.text('动效强度'), findsOneWidget);
      expect(find.text('iOS 增强能力'), findsOneWidget);
    },
  );
}

class _FakePurchaseService implements DoggylogPurchaseService {
  _FakePurchaseService(this.result);

  final RestorePurchasesResult result;
  int restoreCallCount = 0;

  @override
  Future<RestorePurchasesResult> restorePurchases() async {
    restoreCallCount += 1;
    return result;
  }
}
