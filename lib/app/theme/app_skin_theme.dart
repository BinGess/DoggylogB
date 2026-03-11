import 'dart:ui';

import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';

enum AppSkinTheme {
  shibaJoy,
  goldenBloom,
  beagleBreeze,
  huskyFrost,
  samoyedSpa,
}

AppSkinTheme appSkinThemeForBreed(PetBreed breed) {
  return switch (breed) {
    PetBreed.shiba => AppSkinTheme.shibaJoy,
    PetBreed.goldenRetriever => AppSkinTheme.goldenBloom,
    PetBreed.beagle => AppSkinTheme.beagleBreeze,
    PetBreed.husky => AppSkinTheme.huskyFrost,
    PetBreed.samoyed => AppSkinTheme.samoyedSpa,
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
      // ─────────────────────────────────────────────────────────────────────
      // Skin 1 · 积木学堂 — Claymorphism + Vibrant & Block-based
      // Educational Platform：厚实边框、双层阴影、饱和跳色、玩具弹性感
      // ─────────────────────────────────────────────────────────────────────
      AppSkinTheme.shibaJoy => const AppSkinSpec(
        styleName: '积木学堂',
        styleDescription:
            'Claymorphism + Vibrant Block-based — 饱和珊瑚橙 × 婴儿蓝 × 薄荷绿，'
            '厚实描边（3.2px）、超圆角（28px）、双层阴影，像宠物玩具一样有弹性。',
        // Light ─────────────────────
        primaryLight: Color(0xFFF05D56), // Vibrant Coral
        secondaryLight: Color(0xFF72B8E8), // Baby Blue
        tertiaryLight: Color(0xFF3DBA89), // Vibrant Mint (CTA)
        surfaceLight: Color(0xFFFFFCFB),
        backgroundLight: Color(0xFFFFF5F3),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF3D1010),
        outlineLight: Color(0xFFF9CCA9),
        surfaceHighLight: Color(0xFFFBF4F1),
        onSurfaceVariantLight: Color(0xFFC04040),
        backdropLight: [
          Color(0xFFFFFBFA),
          Color(0xFFFFEDEB),
          Color(0xFFFFDAD8),
        ],
        orbLight: Color(0x3DF05D56),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFFFFDFC), Color(0xFFFFFAF8)],
        shadowLight: Color(0x141F2937),
        // Dark ──────────────────────
        primaryDark: Color(0xFFFF8A85),
        secondaryDark: Color(0xFF9BD3F5),
        tertiaryDark: Color(0xFF5FDDAA),
        surfaceDark: Color(0xFF2A1010),
        backgroundDark: Color(0xFF1E0909),
        onPrimaryDark: Color(0xFF3A0000),
        onTertiaryDark: Color(0xFF002D1D),
        onSurfaceDark: Color(0xFFFFE8E7),
        outlineDark: Color(0xFF703020),
        surfaceHighDark: Color(0xFF3D2020),
        onSurfaceVariantDark: Color(0xFFF0A5A0),
        backdropDark: [Color(0xFF1E0808), Color(0xFF250A0A), Color(0xFF180606)],
        orbDark: Color(0x3FFF8A85),
        cardDark: [Color(0xFF2F1818), Color(0xFF251010), Color(0xFF3A2020)],
        shadowDark: Color(0x66000000),
        cardRadius: 28,
        cardBorderWidth: 3.2,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Skin 2 · 数据透明 — Glassmorphism + Flat Design
      // SaaS Analytics Dashboard：磨砂玻璃卡片 × 电气蓝 × 扁平无渐变按钮
      // ─────────────────────────────────────────────────────────────────────
      AppSkinTheme.goldenBloom => const AppSkinSpec(
        styleName: '数据透明',
        styleDescription:
            'Glassmorphism + Flat Design — 电气蓝 × 天蓝 × 青色 CTA，'
            '磨砂玻璃卡片、1px 细描边（14px 圆角）、扁平无阴影按钮，适合数据仪表盘。',
        // Light ─────────────────────
        primaryLight: Color(0xFF0066FF), // Electric Blue
        secondaryLight: Color(0xFF38BDF8), // Sky Blue
        tertiaryLight: Color(0xFF0EA5E9), // Clean Blue (CTA)
        surfaceLight: Color(0xFFF7FAFF),
        backgroundLight: Color(0xFFEEF3FF),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF0F1B3D),
        outlineLight: Color(0xFFC0D5FF),
        surfaceHighLight: Color(0xFFF1F6FB),
        onSurfaceVariantLight: Color(0xFF3366BB),
        backdropLight: [
          Color(0xFFF2F7FF),
          Color(0xFFE8F2FF),
          Color(0xFFD8E8FF),
        ],
        orbLight: Color(0x3A0066FF),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFFCFEFF), Color(0xFFF7FAFD)],
        shadowLight: Color(0x141B2C3D),
        // Dark ──────────────────────
        primaryDark: Color(0xFF60A5FA),
        secondaryDark: Color(0xFF38BDF8),
        tertiaryDark: Color(0xFF2DD4BF),
        surfaceDark: Color(0xFF0D1825),
        backgroundDark: Color(0xFF080E18),
        onPrimaryDark: Color(0xFF001440),
        onTertiaryDark: Color(0xFF002926),
        onSurfaceDark: Color(0xFFE2EDFF),
        outlineDark: Color(0xFF1E3050),
        surfaceHighDark: Color(0xFF152232),
        onSurfaceVariantDark: Color(0xFF90C0F8),
        backdropDark: [Color(0xFF080E18), Color(0xFF0C1422), Color(0xFF060B15)],
        orbDark: Color(0x3A60A5FA),
        cardDark: [Color(0xFF0F1F35), Color(0xFF0C1A2D), Color(0xFF142540)],
        shadowDark: Color(0x66000000),
        cardRadius: 14,
        cardBorderWidth: 1.0,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Skin 3 · AI 对话 — AI-Native UI + Minimalism
      // AI Chatbot Platform：AI紫 × 极简留白 × 对话气泡感 × 单点缀色
      // ─────────────────────────────────────────────────────────────────────
      AppSkinTheme.beagleBreeze => const AppSkinSpec(
        styleName: 'AI 对话',
        styleDescription:
            'AI-Native UI + Minimalism — AI 紫 #6366F1 × 成功绿 CTA，'
            '极简留白、1px 细边框（16px 圆角）、对话气泡层次感，专为智能助手场景打造。',
        // Light ─────────────────────
        primaryLight: Color(0xFF6366F1), // AI Purple
        secondaryLight: Color(0xFFA5B4FC), // Light Purple
        tertiaryLight: Color(0xFF059669), // Forest Green (CTA)
        surfaceLight: Color(0xFFFAFAFA),
        backgroundLight: Color(0xFFF5F5F5),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF111827),
        outlineLight: Color(0xFFE0E0F0),
        surfaceHighLight: Color(0xFFF4F4F8),
        onSurfaceVariantLight: Color(0xFF4B50D0),
        backdropLight: [
          Color(0xFFF8F8F8),
          Color(0xFFF3F3F3),
          Color(0xFFEDEDED),
        ],
        orbLight: Color(0x286366F1),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFFDFCFF), Color(0xFFFAFAFD)],
        shadowLight: Color(0x141E2433),
        // Dark ──────────────────────
        primaryDark: Color(0xFF818CF8),
        secondaryDark: Color(0xFFC4B5FD),
        tertiaryDark: Color(0xFF34D399),
        surfaceDark: Color(0xFF121212),
        backgroundDark: Color(0xFF0A0A0A),
        onPrimaryDark: Color(0xFF1E1B4B),
        onTertiaryDark: Color(0xFF022C22),
        onSurfaceDark: Color(0xFFF9FAFB),
        outlineDark: Color(0xFF2A2A3A),
        surfaceHighDark: Color(0xFF1E1E2E),
        onSurfaceVariantDark: Color(0xFF9BA5F8),
        backdropDark: [Color(0xFF0C0C0C), Color(0xFF111111), Color(0xFF080808)],
        orbDark: Color(0x2A818CF8),
        cardDark: [Color(0xFF181828), Color(0xFF14142A), Color(0xFF1E1E32)],
        shadowDark: Color(0x55000000),
        cardRadius: 16,
        cardBorderWidth: 1.0,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Skin 4 · 健康轻灵 — Neumorphism + Soft UI Evolution
      // Health & Wellness：单色蓝灰基调 × 双层柔阴影 × 凸凹浮雕 × 高可访问性
      // ─────────────────────────────────────────────────────────────────────
      AppSkinTheme.huskyFrost => const AppSkinSpec(
        styleName: '健康轻灵',
        styleDescription:
            'Neumorphism + Soft UI Evolution — 治愈蓝 × 天蓝 × 鼠尾草绿 CTA，'
            '柔性双层阴影（-5px/-5px + 5px/5px）、20px 圆角、极细边框，专为健康养生场景设计。',
        // Light ─────────────────────
        primaryLight: Color(0xFF4A90D9), // Therapeutic Blue
        secondaryLight: Color(0xFF87CEEB), // Sky Blue
        tertiaryLight: Color(0xFF4E9E7E), // Sage Green (CTA)
        surfaceLight: Color(0xFFE8EFF6), // Neumorphic base surface
        backgroundLight: Color(0xFFDDE7F0), // Slightly deeper for depth
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF1A3651),
        outlineLight: Color(0xFFB8D0E8),
        surfaceHighLight: Color(0xFFF0F4F8),
        onSurfaceVariantLight: Color(0xFF356890),
        backdropLight: [
          Color(0xFFE8F0F8),
          Color(0xFFDCE8F2),
          Color(0xFFCFE0EC),
        ],
        orbLight: Color(0x2A4A90D9),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFFCFDFE), Color(0xFFF7FAFC)],
        shadowLight: Color(0x141D2A38),
        // Dark ──────────────────────
        primaryDark: Color(0xFF7BB8E8),
        secondaryDark: Color(0xFFA8D5F0),
        tertiaryDark: Color(0xFF6EC8A0),
        surfaceDark: Color(0xFF1A2A3A),
        backgroundDark: Color(0xFF121E2C),
        onPrimaryDark: Color(0xFF0A1E32),
        onTertiaryDark: Color(0xFF0A2818),
        onSurfaceDark: Color(0xFFD0E8F5),
        outlineDark: Color(0xFF243850),
        surfaceHighDark: Color(0xFF1E3040),
        onSurfaceVariantDark: Color(0xFF88C0E0),
        backdropDark: [Color(0xFF121E2C), Color(0xFF172535), Color(0xFF0E1A28)],
        orbDark: Color(0x2A7BB8E8),
        cardDark: [Color(0xFF1E2E3E), Color(0xFF182838), Color(0xFF243240)],
        shadowDark: Color(0x55000000),
        cardRadius: 20,
        cardBorderWidth: 0.8,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Skin 5 · 云朵温柔 — Soft UI Evolution + Neumorphism
      // Beauty & Spa Service：玫瑰粉 × 薰衣草紫 CTA × 柔性浮雕 × WCAG AA+ 对比
      // ─────────────────────────────────────────────────────────────────────
      AppSkinTheme.samoyedSpa => const AppSkinSpec(
        styleName: '云朵温柔',
        styleDescription:
            'Soft UI Evolution + Neumorphism — 玫瑰粉 × 胭脂粉 × 薰衣草紫 CTA，'
            '进化版柔性浮雕、1.2px 描边（18px 圆角）、WCAG AA+ 对比度，专为美容与温泉服务打造。',
        // Light ─────────────────────
        primaryLight: Color(0xFFC96480), // Rose Pink
        secondaryLight: Color(0xFFF4B8C5), // Blush
        tertiaryLight: Color(0xFF9B7BBF), // Lavender Purple (CTA)
        surfaceLight: Color(0xFFFFF5F7),
        backgroundLight: Color(0xFFFBEEF2),
        onPrimaryLight: Colors.white,
        onTertiaryLight: Colors.white,
        onSurfaceLight: Color(0xFF5C1832),
        outlineLight: Color(0xFFF0C0CC),
        surfaceHighLight: Color(0xFFFCF2F5),
        onSurfaceVariantLight: Color(0xFFAA4060),
        backdropLight: [
          Color(0xFFFFF8FA),
          Color(0xFFFFEFF3),
          Color(0xFFFFE4EA),
        ],
        orbLight: Color(0x2AC96480),
        cardLight: [Color(0xFFFFFFFF), Color(0xFFFFFCFD), Color(0xFFFFF8FA)],
        shadowLight: Color(0x141F2330),
        // Dark ──────────────────────
        primaryDark: Color(0xFFF0A0B4),
        secondaryDark: Color(0xFFF9C5D0),
        tertiaryDark: Color(0xFFC4A8E8),
        surfaceDark: Color(0xFF2A1520),
        backgroundDark: Color(0xFF1E0D16),
        onPrimaryDark: Color(0xFF3A0015),
        onTertiaryDark: Color(0xFF2D1548),
        onSurfaceDark: Color(0xFFFFE0E8),
        outlineDark: Color(0xFF5A2535),
        surfaceHighDark: Color(0xFF36182A),
        onSurfaceVariantDark: Color(0xFFECA0B5),
        backdropDark: [Color(0xFF1E0D16), Color(0xFF230F1B), Color(0xFF190A13)],
        orbDark: Color(0x2AF0A0B4),
        cardDark: [Color(0xFF2F1820), Color(0xFF261219), Color(0xFF381F2A)],
        shadowDark: Color(0x55000000),
        cardRadius: 18,
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
