import 'dart:ui';

import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';

enum AppSkinTheme { shibaJoy, goldenBloom, beagleBreeze, huskyFrost }

AppSkinTheme appSkinThemeForBreed(PetBreed breed) {
  return switch (breed) {
    PetBreed.shiba => AppSkinTheme.shibaJoy,
    PetBreed.goldenRetriever => AppSkinTheme.goldenBloom,
    PetBreed.beagle => AppSkinTheme.beagleBreeze,
    PetBreed.husky => AppSkinTheme.huskyFrost,
  };
}

class AppSkinSpec {
  const AppSkinSpec({
    required this.styleName,
    required this.styleDescription,
    required this.primaryLight,
    required this.secondaryLight,
    required this.tertiaryLight,
    required this.surfaceLight,
    required this.backgroundLight,
    required this.onPrimaryLight,
    required this.onTertiaryLight,
    required this.onSurfaceLight,
    required this.primaryDark,
    required this.secondaryDark,
    required this.tertiaryDark,
    required this.surfaceDark,
    required this.backgroundDark,
    required this.onPrimaryDark,
    required this.onTertiaryDark,
    required this.onSurfaceDark,
    required this.outlineLight,
    required this.outlineDark,
    required this.surfaceHighLight,
    required this.surfaceHighDark,
    required this.onSurfaceVariantLight,
    required this.onSurfaceVariantDark,
    required this.backdropLight,
    required this.backdropDark,
    required this.orbLight,
    required this.orbDark,
    required this.cardLight,
    required this.cardDark,
    required this.shadowLight,
    required this.shadowDark,
    required this.cardRadius,
    required this.cardBorderWidth,
  });

  final String styleName;
  final String styleDescription;
  final Color primaryLight;
  final Color secondaryLight;
  final Color tertiaryLight;
  final Color surfaceLight;
  final Color backgroundLight;
  final Color onPrimaryLight;
  final Color onTertiaryLight;
  final Color onSurfaceLight;
  final Color primaryDark;
  final Color secondaryDark;
  final Color tertiaryDark;
  final Color surfaceDark;
  final Color backgroundDark;
  final Color onPrimaryDark;
  final Color onTertiaryDark;
  final Color onSurfaceDark;
  final Color outlineLight;
  final Color outlineDark;
  final Color surfaceHighLight;
  final Color surfaceHighDark;
  final Color onSurfaceVariantLight;
  final Color onSurfaceVariantDark;
  final List<Color> backdropLight;
  final List<Color> backdropDark;
  final Color orbLight;
  final Color orbDark;
  final List<Color> cardLight;
  final List<Color> cardDark;
  final Color shadowLight;
  final Color shadowDark;
  final double cardRadius;
  final double cardBorderWidth;
}

extension AppSkinThemeX on AppSkinTheme {
  AppSkinSpec get spec {
    return switch (this) {
      AppSkinTheme.shibaJoy => const AppSkinSpec(
        styleName: '柴犬暖陶',
        styleDescription: 'Claymorphism，暖杏橙搭配信任蓝 CTA，圆润、厚实、像宠物玩具一样有弹性。',
        primaryLight: Color(0xFFEA6A12),
        secondaryLight: Color(0xFFFDBA74),
        tertiaryLight: Color(0xFF2563EB),
        surfaceLight: Color(0xFFFFFDFC),
        backgroundLight: Color(0xFFFFF7ED),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF7C2D12),
        primaryDark: Color(0xFFFFB36B),
        secondaryDark: Color(0xFFF9A65A),
        tertiaryDark: Color(0xFF75A9FF),
        surfaceDark: Color(0xFF2A1A12),
        backgroundDark: Color(0xFF1B100A),
        onPrimaryDark: Color(0xFF3B1700),
        onTertiaryDark: Color(0xFF081732),
        onSurfaceDark: Color(0xFFF8D9C2),
        outlineLight: Color(0xFFF3C797),
        outlineDark: Color(0xFF70472D),
        surfaceHighLight: Color(0xFFFFE6C9),
        surfaceHighDark: Color(0xFF3B261B),
        onSurfaceVariantLight: Color(0xFFA24716),
        onSurfaceVariantDark: Color(0xFFEDB58D),
        backdropLight: [
          Color(0xFFFFFBF6),
          Color(0xFFFFF0DE),
          Color(0xFFFFDFC5),
        ],
        backdropDark: [Color(0xFF1D120C), Color(0xFF23160E), Color(0xFF140D09)],
        orbLight: Color(0x3DF59F68),
        orbDark: Color(0x40FFB46B),
        cardLight: [Color(0xFFFFFEFA), Color(0xFFFFF1E0), Color(0xFFFFDFC2)],
        cardDark: [Color(0xFF2F1F17), Color(0xFF251812), Color(0xFF3E291F)],
        shadowLight: Color(0x33D3834E),
        shadowDark: Color(0x66000000),
        cardRadius: 30,
        cardBorderWidth: 2.4,
      ),
      AppSkinTheme.goldenBloom => const AppSkinSpec(
        styleName: '金毛原野',
        styleDescription: 'Nature Distilled，蜂蜜金、沙米白和橄榄绿组合，更像温暖的手工日记而不是糖水配色。',
        primaryLight: Color(0xFFB5651D),
        secondaryLight: Color(0xFFD4C4A8),
        tertiaryLight: Color(0xFF6B7B3C),
        surfaceLight: Color(0xFFFFF9EE),
        backgroundLight: Color(0xFFF5F0E1),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF4F3A22),
        primaryDark: Color(0xFFE1B97A),
        secondaryDark: Color(0xFFD4C4A8),
        tertiaryDark: Color(0xFFA8C46B),
        surfaceDark: Color(0xFF221A13),
        backgroundDark: Color(0xFF15110D),
        onPrimaryDark: Color(0xFF2A1603),
        onTertiaryDark: Color(0xFF1B230C),
        onSurfaceDark: Color(0xFFF4E6CF),
        outlineLight: Color(0xFFDCCCAF),
        outlineDark: Color(0xFF695844),
        surfaceHighLight: Color(0xFFECE0C4),
        surfaceHighDark: Color(0xFF302519),
        onSurfaceVariantLight: Color(0xFF7B6545),
        onSurfaceVariantDark: Color(0xFFD5C09D),
        backdropLight: [
          Color(0xFFF8F3E7),
          Color(0xFFF1E8D5),
          Color(0xFFE7DABD),
        ],
        backdropDark: [Color(0xFF15110D), Color(0xFF1A150F), Color(0xFF110E0A)],
        orbLight: Color(0x33CBA86A),
        orbDark: Color(0x30BFD78A),
        cardLight: [Color(0xFFFFFCF4), Color(0xFFF3E8D3), Color(0xFFE6D7B7)],
        cardDark: [Color(0xFF291F17), Color(0xFF201911), Color(0xFF34291D)],
        shadowLight: Color(0x264E3A1F),
        shadowDark: Color(0x66000000),
        cardRadius: 28,
        cardBorderWidth: 1.6,
      ),
      AppSkinTheme.beagleBreeze => const AppSkinSpec(
        styleName: '比格海盐',
        styleDescription: 'Liquid Glass，清透青蓝搭配薄荷绿动作色，保留玻璃感，但让文字和按钮真正读得清。',
        primaryLight: Color(0xFF0891B2),
        secondaryLight: Color(0xFF7DE3F4),
        tertiaryLight: Color(0xFF059669),
        surfaceLight: Color(0xFFF7FDFF),
        backgroundLight: Color(0xFFECFEFF),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF114A5C),
        primaryDark: Color(0xFF67E8F9),
        secondaryDark: Color(0xFF22D3EE),
        tertiaryDark: Color(0xFF34D399),
        surfaceDark: Color(0xFF112124),
        backgroundDark: Color(0xFF081518),
        onPrimaryDark: Color(0xFF032733),
        onTertiaryDark: Color(0xFF032019),
        onSurfaceDark: Color(0xFFD5F7FA),
        outlineLight: Color(0xFFA8E6F0),
        outlineDark: Color(0xFF2D525A),
        surfaceHighLight: Color(0xFFD8F5FB),
        surfaceHighDark: Color(0xFF1C3137),
        onSurfaceVariantLight: Color(0xFF155E75),
        onSurfaceVariantDark: Color(0xFFB6EDF5),
        backdropLight: [
          Color(0xFFF6FEFF),
          Color(0xFFE8FAFE),
          Color(0xFFDDF5FC),
        ],
        backdropDark: [Color(0xFF0A171B), Color(0xFF102026), Color(0xFF081115)],
        orbLight: Color(0x3335CBE8),
        orbDark: Color(0x3348E4F9),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFF0FCFF), Color(0xFFDDF6FA)],
        cardDark: [Color(0xFF163037), Color(0xFF13262D), Color(0xFF1C3941)],
        shadowLight: Color(0x1F0E7490),
        shadowDark: Color(0x66000000),
        cardRadius: 26,
        cardBorderWidth: 1.0,
      ),
      AppSkinTheme.huskyFrost => const AppSkinSpec(
        styleName: '哈士奇极光',
        styleDescription: 'Aurora Glass，冰川蓝、雾紫和深海靛蓝做出更冷静的高级感，不是单纯加点蓝色。',
        primaryLight: Color(0xFF3B82F6),
        secondaryLight: Color(0xFFA5B4FC),
        tertiaryLight: Color(0xFF4F46E5),
        surfaceLight: Color(0xFFFBFDFF),
        backgroundLight: Color(0xFFF3F6FF),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF1D3D73),
        primaryDark: Color(0xFF93C5FD),
        secondaryDark: Color(0xFFC4B5FD),
        tertiaryDark: Color(0xFF818CF8),
        surfaceDark: Color(0xFF152033),
        backgroundDark: Color(0xFF0B1220),
        onPrimaryDark: Color(0xFF08203F),
        onTertiaryDark: Color(0xFF0F1435),
        onSurfaceDark: Color(0xFFDCE9FF),
        outlineLight: Color(0xFFC8D8F8),
        outlineDark: Color(0xFF33445D),
        surfaceHighLight: Color(0xFFE3EBFF),
        surfaceHighDark: Color(0xFF1D2A3D),
        onSurfaceVariantLight: Color(0xFF46679A),
        onSurfaceVariantDark: Color(0xFFB8CBF1),
        backdropLight: [
          Color(0xFFF8FAFF),
          Color(0xFFEEF3FF),
          Color(0xFFE3EAFD),
        ],
        backdropDark: [Color(0xFF0C1321), Color(0xFF10192B), Color(0xFF091019)],
        orbLight: Color(0x3394B7FF),
        orbDark: Color(0x33799AFF),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFF1F5FF), Color(0xFFE4EAFC)],
        cardDark: [Color(0xFF182438), Color(0xFF132031), Color(0xFF21314C)],
        shadowLight: Color(0x263C58A7),
        shadowDark: Color(0x66000000),
        cardRadius: 24,
        cardBorderWidth: 1.2,
      ),
    };
  }
}

class AppThemeSurfaceStyle extends ThemeExtension<AppThemeSurfaceStyle> {
  const AppThemeSurfaceStyle({
    required this.backdropColors,
    required this.orbColor,
    required this.cardGradientColors,
    required this.cardBorderColor,
    required this.cardShadowColor,
    required this.cardRadius,
    required this.cardBorderWidth,
    required this.actionColor,
    required this.onActionColor,
  });

  final List<Color> backdropColors;
  final Color orbColor;
  final List<Color> cardGradientColors;
  final Color cardBorderColor;
  final Color cardShadowColor;
  final double cardRadius;
  final double cardBorderWidth;
  final Color actionColor;
  final Color onActionColor;

  @override
  AppThemeSurfaceStyle copyWith({
    List<Color>? backdropColors,
    Color? orbColor,
    List<Color>? cardGradientColors,
    Color? cardBorderColor,
    Color? cardShadowColor,
    double? cardRadius,
    double? cardBorderWidth,
    Color? actionColor,
    Color? onActionColor,
  }) {
    return AppThemeSurfaceStyle(
      backdropColors: backdropColors ?? this.backdropColors,
      orbColor: orbColor ?? this.orbColor,
      cardGradientColors: cardGradientColors ?? this.cardGradientColors,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      cardRadius: cardRadius ?? this.cardRadius,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      actionColor: actionColor ?? this.actionColor,
      onActionColor: onActionColor ?? this.onActionColor,
    );
  }

  @override
  AppThemeSurfaceStyle lerp(
    covariant ThemeExtension<AppThemeSurfaceStyle>? other,
    double t,
  ) {
    if (other is! AppThemeSurfaceStyle) {
      return this;
    }
    return AppThemeSurfaceStyle(
      backdropColors: List<Color>.generate(backdropColors.length, (index) {
        return Color.lerp(
          backdropColors[index],
          other.backdropColors[index],
          t,
        )!;
      }),
      orbColor: Color.lerp(orbColor, other.orbColor, t)!,
      cardGradientColors: List<Color>.generate(cardGradientColors.length, (
        index,
      ) {
        return Color.lerp(
          cardGradientColors[index],
          other.cardGradientColors[index],
          t,
        )!;
      }),
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      cardBorderWidth: lerpDouble(cardBorderWidth, other.cardBorderWidth, t)!,
      actionColor: Color.lerp(actionColor, other.actionColor, t)!,
      onActionColor: Color.lerp(onActionColor, other.onActionColor, t)!,
    );
  }
}
