import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

  testWidgets('HomeShell keeps selected settings tab after widget recreation', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: HomeShell(key: UniqueKey())),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    var navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigationBar.selectedIndex, 2);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: HomeShell(key: UniqueKey())),
      ),
    );
    await tester.pump();

    navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigationBar.selectedIndex, 2);
  });
}
