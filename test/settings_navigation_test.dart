import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/app_state_test_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

  testWidgets('HomeShell keeps selected settings tab after widget recreation', (
    tester,
  ) async {
    final harness = await tester.runAsync(() => AppStateTestHarness.create());
    final container = harness!.container;
    addTearDown(harness.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: HomeShell(key: UniqueKey())),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-tab-settings-selected')), findsOneWidget);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: HomeShell(key: UniqueKey())),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-tab-settings-selected')), findsOneWidget);
  });
}
