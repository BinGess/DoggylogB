import 'package:doggylog/app/app.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active skin theme is unavailable until the selected pet is loaded', () {
    final unloadedState = AppState(
      preferences: const UserPreference.defaults(),
      selectedDate: DateTime(2026, 4, 28),
      calendarView: CalendarViewMode.month,
      calendarItems: const [],
      pets: const [],
      countdowns: const [],
      templates: const [],
      geofences: const [],
      recentSuggestions: const [],
    );

    expect(activeSkinThemeForState(unloadedState), isNull);
  });

  test('active skin theme follows the loaded selected pet', () {
    final loadedState = AppState(
      preferences: const UserPreference.defaults(),
      selectedDate: DateTime(2026, 4, 28),
      calendarView: CalendarViewMode.month,
      calendarItems: const [],
      pets: [
        PetProfile(
          id: 'skye',
          name: '小空',
          breed: PetBreed.husky,
          loyaltyPoints: 220,
          selectedSkinId: 'frost-husky',
          unlockedSkinIds: const ['frost-husky'],
          createdAt: DateTime(2026, 1, 1),
          isSelected: true,
        ),
      ],
      countdowns: const [],
      templates: const [],
      geofences: const [],
      recentSuggestions: const [],
    );

    expect(activeSkinThemeForState(loadedState), AppSkinTheme.huskyFrost);
  });
}
