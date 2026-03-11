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

  test(
    'appRouterProvider does not recreate router on unrelated settings changes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final routerBefore = container.read(appRouterProvider);

      final routerAfter = container.read(appRouterProvider);

      expect(identical(routerAfter, routerBefore), isTrue);
    },
  );

  test('appRouterProvider starts at home by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    expect(router.routeInformationProvider.value.uri.path, '/');
  });
}
