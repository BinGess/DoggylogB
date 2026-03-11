import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:flutter/material.dart';

class SoftBackdrop extends StatelessWidget {
  const SoftBackdrop({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final surfaceStyle = Theme.of(context).extension<AppThemeSurfaceStyle>();
    final backdropColors =
        surfaceStyle?.backdropColors ??
        const [Color(0xFFF6F9FC), Color(0xFFF0F5FA), Color(0xFFE8EEF5)];
    final orbColor = surfaceStyle?.orbColor ?? const Color(0x2A93DDD5);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backdropColors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            left: -72,
            child: _GlowOrb(size: 240, color: orbColor),
          ),
          Positioned(
            top: 180,
            right: -64,
            child: _GlowOrb(size: 180, color: orbColor),
          ),
          Positioned(
            bottom: -96,
            left: 36,
            child: _GlowOrb(size: 200, color: orbColor),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
