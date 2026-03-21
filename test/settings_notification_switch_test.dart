import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'NotificationPermissionSwitchTile requests permission when toggled on',
    (tester) async {
      var requestCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: NotificationPermissionSwitchTile(
              isGranted: false,
              onRequestPermission: () {
                requestCount += 1;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.widgetWithText(SwitchListTile, '通知提醒'), findsOneWidget);
      expect(find.text('还没有通知权限'), findsOneWidget);

      await tester.tap(find.widgetWithText(SwitchListTile, '通知提醒'));
      await tester.pump();

      expect(requestCount, 1);
    },
  );

  testWidgets(
    'NotificationPermissionSwitchTile shows the granted subtitle when enabled',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: NotificationPermissionSwitchTile(
              isGranted: true,
              onRequestPermission: _noop,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('保存任务后会自动安排提醒。'), findsOneWidget);
    },
  );
}

void _noop() {}
