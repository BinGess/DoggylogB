import 'package:flutter/material.dart';

class AppTheme {
  static const _warmPrimary = Color(0xFFE58A5E);
  static const _mintAccent = Color(0xFF5FC8B3);
  static const _lightBackground = Color(0xFFF6F3EE);
  static const _lightSurface = Color(0xFFFFFCF8);
  static const _darkBackground = Color(0xFF12171E);
  static const _darkSurface = Color(0xFF1A212B);

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _warmPrimary,
          brightness: Brightness.light,
          primary: _warmPrimary,
          secondary: _mintAccent,
          surface: _lightSurface,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFFEAE4DB),
          onSurfaceVariant: const Color(0xFF6F6A61),
          outline: const Color(0xFFD6CBBF),
        );
    return _buildTheme(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _warmPrimary,
          brightness: Brightness.dark,
          primary: const Color(0xFFF0A27B),
          secondary: const Color(0xFF82DCCB),
          surface: _darkSurface,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFF252D39),
          onSurfaceVariant: const Color(0xFFA8B0BA),
          outline: const Color(0xFF303A47),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.82),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF202833).withValues(alpha: 0.96)
            : const Color(0xFFF9F5EF).withValues(alpha: 0.98),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.84),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
        selectedColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.16),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: isDark ? const Color(0xFF221B15) : Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.36)),
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
        foregroundColor: isDark ? const Color(0xFF221B15) : Colors.white,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? const Color(0xFF181F29).withValues(alpha: 0.98)
            : const Color(0xFFFCF8F2).withValues(alpha: 0.99),
        modalBackgroundColor: isDark
            ? const Color(0xFF181F29).withValues(alpha: 0.98)
            : const Color(0xFFFCF8F2).withValues(alpha: 0.99),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 76,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
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
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 50,
        height: 1.02,
        letterSpacing: -1.6,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 38,
        height: 1.06,
        letterSpacing: -1.2,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 30,
        height: 1.12,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        height: 1.14,
        letterSpacing: -0.6,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        height: 1.18,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.2,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 17,
        height: 1.24,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 15,
        height: 1.24,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
