import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
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
                isDark ? const Color(0xFF243140) : const Color(0xFFFCFDFF),
                isDark ? const Color(0xFF1A2430) : const Color(0xFFF1F5FB),
                scheme.primary.withValues(alpha: isDark ? 0.10 : 0.06),
              ],
            ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.24)
                : const Color(0xFFB9C6D8).withValues(alpha: 0.42),
            blurRadius: 24,
            offset: const Offset(10, 12),
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 18,
            offset: const Offset(-8, -8),
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
              Colors.white.withValues(alpha: isDark ? 0.04 : 0.26),
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
