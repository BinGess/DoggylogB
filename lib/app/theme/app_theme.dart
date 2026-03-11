import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light({
    double fontScale = 1,
    AppSkinTheme skinTheme = AppSkinTheme.shibaJoy,
  }) {
    final skin = skinTheme.spec;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: skin.primaryLight,
          brightness: Brightness.light,
        ).copyWith(
          primary: skin.primaryLight,
          onPrimary: skin.onPrimaryLight,
          secondary: skin.secondaryLight,
          tertiary: skin.tertiaryLight,
          onTertiary: skin.onTertiaryLight,
          surface: skin.surfaceLight,
          onSurface: skin.onSurfaceLight,
          surfaceContainerHighest: skin.surfaceHighLight,
          onSurfaceVariant: skin.onSurfaceVariantLight,
          outline: skin.outlineLight,
        );
    return _buildTheme(scheme, Brightness.light, fontScale, skin);
  }

  static ThemeData dark({
    double fontScale = 1,
    AppSkinTheme skinTheme = AppSkinTheme.shibaJoy,
  }) {
    final skin = skinTheme.spec;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: skin.primaryDark,
          brightness: Brightness.dark,
        ).copyWith(
          primary: skin.primaryDark,
          onPrimary: skin.onPrimaryDark,
          secondary: skin.secondaryDark,
          tertiary: skin.tertiaryDark,
          onTertiary: skin.onTertiaryDark,
          surface: skin.surfaceDark,
          onSurface: skin.onSurfaceDark,
          surfaceContainerHighest: skin.surfaceHighDark,
          onSurfaceVariant: skin.onSurfaceVariantDark,
          outline: skin.outlineDark,
        );
    return _buildTheme(scheme, Brightness.dark, fontScale, skin);
  }

  static ThemeData _buildTheme(
    ColorScheme scheme,
    Brightness brightness,
    double fontScale,
    AppSkinSpec skin,
  ) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _textTheme(
      isDark ? Typography.whiteMountainView : Typography.blackMountainView,
      scheme,
      fontScale,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? skin.backgroundDark
          : skin.backgroundLight,
      canvasColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      extensions: [
        AppThemeSurfaceStyle(
          backdropColors: isDark ? skin.backdropDark : skin.backdropLight,
          orbColor: isDark ? skin.orbDark : skin.orbLight,
          cardGradientColors: isDark ? skin.cardDark : skin.cardLight,
          cardBorderColor: isDark
              ? scheme.outline.withValues(alpha: 0.54)
              : Colors.white.withValues(alpha: 0.92),
          cardShadowColor: isDark ? skin.shadowDark : skin.shadowLight,
          cardRadius: skin.cardRadius,
          cardBorderWidth: skin.cardBorderWidth,
          actionColor: isDark ? skin.tertiaryDark : skin.tertiaryLight,
          onActionColor: isDark ? skin.onTertiaryDark : skin.onTertiaryLight,
        ),
      ],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius),
          side: BorderSide(
            color: scheme.outline.withValues(alpha: isDark ? 0.34 : 0.72),
            width: skin.cardBorderWidth,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 8),
        ),
        tileColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.92),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.84),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 8),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: 0.28),
            width: skin.cardBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 8),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: 0.28),
            width: skin.cardBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 8),
          borderSide: BorderSide(color: scheme.tertiary, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 10),
          side: BorderSide.none,
        ),
        selectedColor: scheme.tertiary.withValues(alpha: isDark ? 0.24 : 0.16),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.54),
        disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.tertiary,
          foregroundColor: scheme.onTertiary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(skin.cardRadius - 10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(
            color: scheme.tertiary.withValues(alpha: 0.36),
            width: skin.cardBorderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(skin.cardRadius - 10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.tertiary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.cardRadius - 8),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? skin.surfaceDark.withValues(alpha: 0.98)
            : skin.surfaceLight.withValues(alpha: 0.99),
        modalBackgroundColor: isDark
            ? skin.surfaceDark.withValues(alpha: 0.98)
            : skin.surfaceLight.withValues(alpha: 0.99),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.tertiary
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.tertiary
                : scheme.onSurfaceVariant,
          );
        }),
        indicatorColor: scheme.tertiary.withValues(alpha: isDark ? 0.22 : 0.14),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.tertiary,
        linearTrackColor: scheme.surfaceContainerHighest.withValues(
          alpha: 0.52,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.tertiary;
          }
          return isDark ? Colors.white : scheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.tertiary.withValues(alpha: 0.34);
          }
          return scheme.surfaceContainerHighest;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: 0.52),
          width: 1.2,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.tertiary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.tertiary,
        overlayColor: scheme.tertiary.withValues(alpha: 0.12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.18),
        thickness: 1,
      ),
    );
  }

  static TextTheme _textTheme(
    TextTheme base,
    ColorScheme scheme,
    double fontScale,
  ) {
    final scale = fontScale.clamp(1.0, 1.2);
    final canLoadGoogleFonts = GoogleFonts.config.allowRuntimeFetching;
    final headingBase = canLoadGoogleFonts
        ? GoogleFonts.varelaRoundTextTheme(base)
        : base;
    final bodyBase = canLoadGoogleFonts
        ? GoogleFonts.notoSansScTextTheme(base)
        : base;

    return bodyBase.copyWith(
      // Display — 大标题：移除负向字距，中文不需要紧缩字距
      displayLarge: headingBase.displayLarge?.copyWith(
        fontSize: 38 * scale,
        height: 1.28,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      displayMedium: headingBase.displayMedium?.copyWith(
        fontSize: 30 * scale,
        height: 1.28,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      // Headline — 页面标题
      headlineLarge: headingBase.headlineLarge?.copyWith(
        fontSize: 26 * scale,
        height: 1.32,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineMedium: headingBase.headlineMedium?.copyWith(
        fontSize: 22 * scale,
        height: 1.32,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineSmall: headingBase.headlineSmall?.copyWith(
        fontSize: 19 * scale,
        height: 1.38,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      // Title — 卡片/列表标题
      titleLarge: headingBase.titleLarge?.copyWith(
        fontSize: 17 * scale,
        height: 1.42,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: headingBase.titleMedium?.copyWith(
        fontSize: 15 * scale,
        height: 1.45,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleSmall: headingBase.titleSmall?.copyWith(
        fontSize: 13 * scale,
        height: 1.45,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      // Body — 正文：中文需要充裕的行高才舒适
      bodyLarge: bodyBase.bodyLarge?.copyWith(
        fontSize: 16 * scale,
        height: 1.7,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      bodyMedium: bodyBase.bodyMedium?.copyWith(
        fontSize: 14 * scale,
        height: 1.7,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      bodySmall: bodyBase.bodySmall?.copyWith(
        fontSize: 12 * scale,
        height: 1.6,
        letterSpacing: 0.3,
        color: scheme.onSurfaceVariant,
      ),
      // Label — 标签/按钮/底部导航：保留微弱字距提升小字可读性
      labelLarge: bodyBase.labelLarge?.copyWith(
        fontSize: 13 * scale,
        height: 1.35,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      labelMedium: bodyBase.labelMedium?.copyWith(
        fontSize: 11 * scale,
        height: 1.35,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w700,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: bodyBase.labelSmall?.copyWith(
        fontSize: 10 * scale,
        height: 1.35,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
