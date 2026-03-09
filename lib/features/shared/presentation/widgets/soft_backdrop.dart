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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF101721), Color(0xFF121A25), Color(0xFF0B1118)]
              : const [Color(0xFFF4F7FB), Color(0xFFEAF0F8), Color(0xFFE3EAF4)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: -120, left: -70, child: _GlowOrb(size: 260)),
          const Positioned(top: 130, right: -80, child: _GlowOrb(size: 220)),
          const Positioned(bottom: -110, left: 28, child: _GlowOrb(size: 240)),
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
                ? const [Color(0x26F4A261), Color(0x005EC8C0)]
                : const [Color(0x40FFD7BA), Color(0x00B4C8FF)],
          ),
        ),
      ),
    );
  }
}
