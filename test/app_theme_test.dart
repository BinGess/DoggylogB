import 'dart:math' as math;

import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
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
    expect(
      appSkinThemeForBreed(PetBreed.borderCollie),
      AppSkinTheme.collieGarden,
    );
    expect(
      appSkinThemeForBreed(PetBreed.dachshund),
      AppSkinTheme.dachshundCocoa,
    );
    expect(appSkinThemeForBreed(PetBreed.dalmatian), AppSkinTheme.dalmatianInk);
  });

  test('new skins each use a distinct paid product and visual palette', () {
    final breeds = [
      PetBreed.borderCollie,
      PetBreed.dachshund,
      PetBreed.dalmatian,
    ];
    expect(breeds.map(premiumProductIdForPetBreed).toSet(), hasLength(3));
    for (final breed in breeds) {
      expect(isPremiumPetSkin(breed), isTrue);
      expect(isPetSkinVisibleInManagement(breed), isTrue);
    }
    expect(
      breeds
          .map((breed) => appSkinThemeForBreed(breed).spec.primaryLight)
          .toSet(),
      hasLength(3),
    );
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

  test('English skin fonts follow the theme in light and dark modes', () {
    const en = Locale('en');
    const zh = Locale('zh');
    const ja = Locale('ja');
    expect(fontFamilyForSkin(AppSkinTheme.collieGarden, en), 'Quicksand');
    expect(fontFamilyForSkin(AppSkinTheme.dachshundCocoa, en), 'Fredoka');
    expect(fontFamilyForSkin(AppSkinTheme.dalmatianInk, en), 'Nunito');
    for (final theme in AppSkinTheme.values) {
      final family = fontFamilyForSkin(theme, en);
      expect(
        AppTheme.light(
          skinTheme: theme,
          locale: en,
        ).textTheme.bodyMedium?.fontFamily,
        family,
      );
      expect(
        AppTheme.dark(
          skinTheme: theme,
          locale: en,
        ).textTheme.titleLarge?.fontFamily,
        family,
      );
    }
    expect(fontFamilyForSkin(AppSkinTheme.collieGarden, zh), 'ZCOOLXiaoWei');
    expect(fontFamilyForSkin(AppSkinTheme.dachshundCocoa, zh), 'Xiaolai');
    expect(fontFamilyForSkin(AppSkinTheme.dalmatianInk, zh), 'LXGWWenKai');
    expect(
      headingFontFamilyForSkin(AppSkinTheme.dachshundCocoa, zh),
      'ZCOOLKuaiLe',
    );
    expect(headingFontFamilyForSkin(AppSkinTheme.dalmatianInk, zh), 'Xiaolai');
    expect(fontFamilyForSkin(AppSkinTheme.collieGarden, ja), 'RoundedMplus1c');
    expect(fontFamilyForSkin(AppSkinTheme.dachshundCocoa, ja), 'ZenMaruGothic');
    expect(
      headingFontFamilyForSkin(AppSkinTheme.dachshundCocoa, ja),
      'HachiMaruPop',
    );
    for (final locale in [zh, ja]) {
      for (final theme in AppSkinTheme.values) {
        final light = AppTheme.light(skinTheme: theme, locale: locale);
        final dark = AppTheme.dark(skinTheme: theme, locale: locale);
        expect(
          light.textTheme.bodyMedium?.fontFamily,
          fontFamilyForSkin(theme, locale),
        );
        expect(
          dark.textTheme.titleLarge?.fontFamily,
          headingFontFamilyForSkin(theme, locale),
        );
        expect(
          light.textTheme.titleLarge?.fontFamilyFallback,
          contains('LXGWWenKai'),
        );
      }
    }
  });

  test('Light themes keep card surfaces airy and low saturation', () {
    for (final skinTheme in AppSkinTheme.values) {
      final theme = AppTheme.light(fontScale: 1.0, skinTheme: skinTheme);
      final surfaceStyle = theme.extension<AppThemeSurfaceStyle>()!;

      for (final color in surfaceStyle.cardGradientColors) {
        final red = (color.r * 255).round();
        final green = (color.g * 255).round();
        final blue = (color.b * 255).round();
        final darkestChannel = math.min(red, math.min(green, blue));
        final channelSpread =
            math.max(red, math.max(green, blue)) - darkestChannel;

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
        (surfaceStyle.cardBorderColor.a * 255).round(),
        lessThanOrEqualTo(96),
        reason: '$skinTheme card border should stay subtle in light mode.',
      );
      expect(
        (surfaceStyle.cardShadowColor.a * 255).round(),
        lessThanOrEqualTo(24),
        reason: '$skinTheme card shadow should stay restrained in light mode.',
      );
    }
  });
}
