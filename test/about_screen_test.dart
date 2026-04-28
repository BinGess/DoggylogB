import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/settings/presentation/about_screen.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AboutScreen shows app version from platform loader', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(
          fontScale: 1.0,
          skinTheme: AppSkinTheme.shibaJoy,
        ),
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AboutScreen(
          loadAppVersionInfo: () async => const AppVersionInfo(
            version: '1.1.0',
            buildNumber: '3',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('版本号: 1.1 (3)'), findsOneWidget);
  });
}
