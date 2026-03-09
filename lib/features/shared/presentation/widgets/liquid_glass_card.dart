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
    final borderRadius = BorderRadius.circular(radius);

    final body = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? const Color(0xFF213040) : const Color(0xFFFDFEFF),
                isDark ? const Color(0xFF19232E) : const Color(0xFFF2F6FB),
                scheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              ],
            ),
        border: Border.all(
          color: isDark
              ? scheme.outline.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.88),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.22)
                : const Color(0xFFB8C8D9).withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(8, 10),
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.7),
            blurRadius: 14,
            offset: const Offset(-5, -5),
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
              Colors.white.withValues(alpha: isDark ? 0.03 : 0.2),
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
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: body,
      ),
    );
  }
}
