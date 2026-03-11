import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.gradient,
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceStyle = theme.extension<AppThemeSurfaceStyle>();
    final resolvedRadius = surfaceStyle?.cardRadius ?? radius;
    final borderRadius = BorderRadius.circular(resolvedRadius);

    final body = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  surfaceStyle?.cardGradientColors ??
                  [
                    isDark ? const Color(0xFF213040) : const Color(0xFFFDFEFF),
                    isDark ? const Color(0xFF19232E) : const Color(0xFFF8FAFC),
                    isDark
                        ? scheme.outline.withValues(alpha: 0.16)
                        : const Color(0xFFF4F7FA),
                  ],
            ),
        border: Border.all(
          color:
              surfaceStyle?.cardBorderColor ??
              (isDark
                  ? scheme.outline.withValues(alpha: 0.4)
                  : scheme.outline.withValues(alpha: 0.22)),
          width: surfaceStyle?.cardBorderWidth ?? 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                surfaceStyle?.cardShadowColor ??
                (isDark
                    ? Colors.black.withValues(alpha: 0.22)
                    : const Color(0xFF1F2937).withValues(alpha: 0.08)),
            blurRadius: 24,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.24),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: isDark ? 0.03 : 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) {
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor:
            surfaceStyle?.actionColor.withValues(alpha: 0.08) ??
            scheme.tertiary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: body,
      ),
    );
  }
}
