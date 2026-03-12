import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/settings/presentation/widgets/language_picker_bottom_sheet.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(fontScale: 1, skinTheme: AppSkinTheme.shibaJoy),
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('LanguagePickerBottomSheet renders all language choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanguagePickerBottomSheet(selectedMode: AppLanguageMode.system),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('language-picker-sheet')), findsOneWidget);
    expect(find.text('切换界面语言'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('日语'), findsOneWidget);
  });

  testWidgets('LanguagePickerBottomSheet returns tapped language mode', (
    tester,
  ) async {
    AppLanguageMode? result;

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showLanguagePickerBottomSheet(
                    context,
                    selectedMode: AppLanguageMode.system,
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));

    await tester.tap(find.byKey(const Key('language-option-en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));

    expect(result, AppLanguageMode.en);
    expect(find.byKey(const Key('language-picker-sheet')), findsNothing);
  });
}
