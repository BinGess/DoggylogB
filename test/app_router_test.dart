import 'package:doggylog/app/router/app_router.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppStateController extends StateNotifier<AppState> {
  _FakeAppStateController(super.state);

  void updatePreferences(UserPreference preferences) {
    state = state.copyWith(preferences: preferences);
  }
}

void main() {
  test('appRouterProvider does not recreate router on unrelated settings changes', () {
    final controller = _FakeAppStateController(
      AppState(
        preferences: const UserPreference.defaults().copyWith(
          hasCompletedOnboarding: true,
        ),
        selectedDate: DateTime(2026, 3, 9),
        calendarView: CalendarViewMode.month,
        calendarItems: const [],
        pets: const [],
        countdowns: const [],
        templates: const [],
        geofences: const [],
        recentSuggestions: const [],
        stats: const DashboardStats(
          totalTasks: 0,
          completedTasks: 0,
          streakDays: 0,
          loyaltyPoints: 0,
          categoryCounts: {},
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        appStateProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);

    final routerBefore = container.read(appRouterProvider);

    controller.updatePreferences(
      controller.state.preferences.copyWith(hapticsEnabled: false),
    );

    final routerAfter = container.read(appRouterProvider);

    expect(identical(routerAfter, routerBefore), isTrue);
  });
}
