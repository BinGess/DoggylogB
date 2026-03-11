import 'dart:math' as math;

import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('Pet breeds map to stable app skin themes', () {
    expect(appSkinThemeForBreed(PetBreed.shiba), AppSkinTheme.shibaJoy);
    expect(
      appSkinThemeForBreed(PetBreed.goldenRetriever),
      AppSkinTheme.goldenBloom,
    );
    expect(appSkinThemeForBreed(PetBreed.beagle), AppSkinTheme.beagleBreeze);
    expect(appSkinThemeForBreed(PetBreed.husky), AppSkinTheme.huskyFrost);
  });

  test('AppTheme uses different primary colors for different skins', () {
    final shiba = AppTheme.light(
      fontScale: 1.0,
      skinTheme: AppSkinTheme.shibaJoy,
    );
    final husky = AppTheme.light(
      fontScale: 1.0,
      skinTheme: AppSkinTheme.huskyFrost,
    );

    expect(shiba.colorScheme.primary, isNot(husky.colorScheme.primary));
    expect(shiba.extension<AppThemeSurfaceStyle>(), isNotNull);
    expect(husky.extension<AppThemeSurfaceStyle>(), isNotNull);
    expect(shiba.extension<AppThemeSurfaceStyle>()!.actionColor, isNotNull);
    expect(
      shiba.extension<AppThemeSurfaceStyle>()!.cardBorderWidth,
      isNot(husky.extension<AppThemeSurfaceStyle>()!.cardBorderWidth),
    );
  });

  test('AppTheme increases text sizes when font scale grows', () {
    final small = AppTheme.light(
      fontScale: 1.0,
      skinTheme: AppSkinTheme.shibaJoy,
    );
    final large = AppTheme.light(
      fontScale: 1.2,
      skinTheme: AppSkinTheme.shibaJoy,
    );

    expect(
      large.textTheme.bodyMedium!.fontSize!,
      greaterThan(small.textTheme.bodyMedium!.fontSize!),
    );
    expect(
      large.textTheme.titleLarge!.fontSize!,
      greaterThan(small.textTheme.titleLarge!.fontSize!),
    );
  });

  test('Light themes keep card surfaces airy and low saturation', () {
    for (final skinTheme in AppSkinTheme.values) {
      final theme = AppTheme.light(fontScale: 1.0, skinTheme: skinTheme);
      final surfaceStyle = theme.extension<AppThemeSurfaceStyle>()!;

      for (final color in surfaceStyle.cardGradientColors) {
        final darkestChannel = math.min(
          color.red,
          math.min(color.green, color.blue),
        );
        final channelSpread =
            math.max(color.red, math.max(color.green, color.blue)) -
            darkestChannel;

        expect(
          color.computeLuminance(),
          greaterThan(0.94),
          reason: '$skinTheme card color should stay bright: $color',
        );
        expect(
          darkestChannel,
          greaterThanOrEqualTo(242),
          reason:
              '$skinTheme card color should stay near-white instead of muddy: $color',
        );
        expect(
          channelSpread,
          lessThanOrEqualTo(12),
          reason:
              '$skinTheme card color should stay neutral instead of over-tinted: $color',
        );
      }

      expect(
        surfaceStyle.cardBorderColor.alpha,
        lessThanOrEqualTo(96),
        reason: '$skinTheme card border should stay subtle in light mode.',
      );
      expect(
        surfaceStyle.cardShadowColor.alpha,
        lessThanOrEqualTo(24),
        reason: '$skinTheme card shadow should stay restrained in light mode.',
      );
    }
  });
}
