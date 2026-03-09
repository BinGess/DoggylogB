import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SoftBackdrop does not block taps on descendants', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SoftBackdrop(
              child: Center(
                child: FilledButton(
                  onPressed: () => tapped = true,
                  child: const Text('tap me'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('tap me'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('LiquidGlassCard does not block taps on descendants', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidGlassCard(
              child: FilledButton(
                onPressed: () => tapped = true,
                child: const Text('press'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('press'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
