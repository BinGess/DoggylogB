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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0E141B), Color(0xFF121922), Color(0xFF0B1016)]
              : const [Color(0xFFF6F9FC), Color(0xFFF0F5FA), Color(0xFFE8EEF5)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: -110, left: -72, child: _GlowOrb(size: 240)),
          const Positioned(top: 180, right: -64, child: _GlowOrb(size: 180)),
          const Positioned(bottom: -96, left: 36, child: _GlowOrb(size: 200)),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDark
                ? const [Color(0x145BD4C4), Color(0x005BD4C4)]
                : const [Color(0x2A93DDD5), Color(0x0093DDD5)],
          ),
        ),
      ),
    );
  }
}
