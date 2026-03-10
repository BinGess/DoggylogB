import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFF2F8F8A);
  static const _secondary = Color(0xFF78C8C1);
  static const _lightBackground = Color(0xFFF4F7FB);
  static const _lightSurface = Color(0xFFFBFCFE);
  static const _darkBackground = Color(0xFF0E141B);
  static const _darkSurface = Color(0xFF18212B);

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
          primary: _primary,
          secondary: _secondary,
          surface: _lightSurface,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFFE6ECF4),
          onSurfaceVariant: const Color(0xFF617081),
          outline: const Color(0xFFD8E0EA),
        );
    return _buildTheme(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
          primary: const Color(0xFF72C9C1),
          secondary: const Color(0xFF9DDFD8),
          surface: _darkSurface,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFF263241),
          onSurfaceVariant: const Color(0xFF9AA8B8),
          outline: const Color(0xFF334254),
        );
    return _buildTheme(scheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _textTheme(
      isDark ? Typography.whiteMountainView : Typography.blackMountainView,
      scheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? _darkBackground : _lightBackground,
      canvasColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: scheme.outline.withValues(alpha: isDark ? 0.34 : 0.72),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF202A35).withValues(alpha: 0.98)
            : Colors.white.withValues(alpha: 0.88),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.84),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.28)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
        selectedColor: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.54),
        disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: isDark ? const Color(0xFF10211F) : Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.44)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: isDark ? const Color(0xFF10211F) : Colors.white,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? const Color(0xFF17202A).withValues(alpha: 0.98)
            : const Color(0xFFF9FBFE).withValues(alpha: 0.99),
        modalBackgroundColor: isDark
            ? const Color(0xFF17202A).withValues(alpha: 0.98)
            : const Color(0xFFF9FBFE).withValues(alpha: 0.99),
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
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          );
        }),
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest.withValues(
          alpha: 0.52,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return isDark ? Colors.white : scheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.34);
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
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.18),
        thickness: 1,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    final zcoolBase = GoogleFonts.zcoolKuaiLeTextTheme(base);
    return zcoolBase.copyWith(
      // Display — 大标题：移除负向字距，中文不需要紧缩字距
      displayLarge: zcoolBase.displayLarge?.copyWith(
        fontSize: 38,
        height: 1.28,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      displayMedium: zcoolBase.displayMedium?.copyWith(
        fontSize: 30,
        height: 1.28,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Headline — 页面标题
      headlineLarge: zcoolBase.headlineLarge?.copyWith(
        fontSize: 26,
        height: 1.32,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      headlineMedium: zcoolBase.headlineMedium?.copyWith(
        fontSize: 22,
        height: 1.32,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      headlineSmall: zcoolBase.headlineSmall?.copyWith(
        fontSize: 19,
        height: 1.38,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Title — 卡片/列表标题
      titleLarge: zcoolBase.titleLarge?.copyWith(
        fontSize: 17,
        height: 1.42,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      titleMedium: zcoolBase.titleMedium?.copyWith(
        fontSize: 15,
        height: 1.45,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      titleSmall: zcoolBase.titleSmall?.copyWith(
        fontSize: 13,
        height: 1.45,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      // Body — 正文：中文需要充裕的行高才舒适
      bodyLarge: zcoolBase.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.7,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      bodyMedium: zcoolBase.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.7,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      bodySmall: zcoolBase.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.6,
        letterSpacing: 0.3,
        color: scheme.onSurfaceVariant,
      ),
      // Label — 标签/按钮/底部导航：保留微弱字距提升小字可读性
      labelLarge: zcoolBase.labelLarge?.copyWith(
        fontSize: 13,
        height: 1.35,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      labelMedium: zcoolBase.labelMedium?.copyWith(
        fontSize: 11,
        height: 1.35,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: zcoolBase.labelSmall?.copyWith(
        fontSize: 10,
        height: 1.35,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
