import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/calendar/presentation/calendar_theme_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar timeline assets follow the visible theme mapping', () {
    expect(
      calendarTimelineAssetsForTheme(AppSkinTheme.shibaJoy),
      const CalendarThemeAssets(
        gifAssetPath: 'assets/images/calendar/calendar_dog_timeline.gif',
        pngAssetPath: 'assets/images/calendar/calendar_dog_timeline.png',
      ),
    );
    expect(
      calendarTimelineAssetsForTheme(AppSkinTheme.beagleBreeze),
      const CalendarThemeAssets(
        gifAssetPath: 'assets/images/calendar/calendar_dog1_timeline.gif',
        pngAssetPath: 'assets/images/calendar/calendar_dog1_timeline.png',
      ),
    );
    expect(
      calendarTimelineAssetsForTheme(AppSkinTheme.huskyFrost),
      const CalendarThemeAssets(
        gifAssetPath: 'assets/images/calendar/calendar_dog2_timeline.gif',
        pngAssetPath: 'assets/images/calendar/calendar_dog2_timeline.png',
      ),
    );
    expect(
      calendarTimelineAssetsForTheme(AppSkinTheme.samoyedSpa),
      const CalendarThemeAssets(
        gifAssetPath: 'assets/images/calendar/calendar_dog3_timeline.gif',
        pngAssetPath: 'assets/images/calendar/calendar_dog3_timeline.png',
      ),
    );
  });
}
