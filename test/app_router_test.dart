import 'package:doggylog/app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps widget deep link to in-app countdown tab route', () {
    expect(
      normalizeExternalLocation(Uri.parse('doggylog://tab/countdown')),
      '/tab/countdown',
    );
  });

  test('maps widget deep link to in-app calendar tab route', () {
    expect(
      normalizeExternalLocation(Uri.parse('doggylog://tab/calendar')),
      '/tab/calendar',
    );
  });

  test('appRouterProvider does not recreate router on unrelated settings changes', () {
    final container = ProviderContainer(
      overrides: [
        hasCompletedOnboardingProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    final routerBefore = container.read(appRouterProvider);

    final routerAfter = container.read(appRouterProvider);

    expect(identical(routerAfter, routerBefore), isTrue);
  });
}
