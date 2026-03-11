import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';

class CalendarThemeAssets {
  const CalendarThemeAssets({
    required this.gifAssetPath,
    required this.pngAssetPath,
  });

  final String gifAssetPath;
  final String pngAssetPath;

  @override
  bool operator ==(Object other) {
    return other is CalendarThemeAssets &&
        other.gifAssetPath == gifAssetPath &&
        other.pngAssetPath == pngAssetPath;
  }

  @override
  int get hashCode => Object.hash(gifAssetPath, pngAssetPath);
}

const _calendarThemeAssetsGroup1 = CalendarThemeAssets(
  gifAssetPath: 'assets/images/calendar/calendar_dog_timeline.gif',
  pngAssetPath: 'assets/images/calendar/calendar_dog_timeline.png',
);

const _calendarThemeAssetsGroup2 = CalendarThemeAssets(
  gifAssetPath: 'assets/images/calendar/calendar_dog1_timeline.gif',
  pngAssetPath: 'assets/images/calendar/calendar_dog1_timeline.png',
);

const _calendarThemeAssetsGroup3 = CalendarThemeAssets(
  gifAssetPath: 'assets/images/calendar/calendar_dog2_timeline.gif',
  pngAssetPath: 'assets/images/calendar/calendar_dog2_timeline.png',
);

const _calendarThemeAssetsGroup4 = CalendarThemeAssets(
  gifAssetPath: 'assets/images/calendar/calendar_dog3_timeline.gif',
  pngAssetPath: 'assets/images/calendar/calendar_dog3_timeline.png',
);

CalendarThemeAssets calendarTimelineAssetsForTheme(AppSkinTheme theme) {
  return switch (theme) {
    AppSkinTheme.shibaJoy => _calendarThemeAssetsGroup1,
    AppSkinTheme.beagleBreeze => _calendarThemeAssetsGroup2,
    AppSkinTheme.huskyFrost => _calendarThemeAssetsGroup3,
    AppSkinTheme.samoyedSpa => _calendarThemeAssetsGroup4,
    AppSkinTheme.goldenBloom => _calendarThemeAssetsGroup1,
  };
}

CalendarThemeAssets calendarTimelineAssetsForBreed(PetBreed? breed) {
  return calendarTimelineAssetsForTheme(
    appSkinThemeForBreed(breed ?? PetBreed.shiba),
  );
}
