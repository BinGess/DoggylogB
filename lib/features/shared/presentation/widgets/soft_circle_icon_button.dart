import 'package:flutter/material.dart';

class SoftCircleButton extends StatelessWidget {
  const SoftCircleButton({
    super.key,
    required this.onTap,
    required this.child,
    this.tooltip,
  });

  final VoidCallback onTap;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints.tightFor(width: 58, height: 58),
          decoration: _softCircleDecoration(context),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

class SoftCircleIconButton extends StatelessWidget {
  const SoftCircleIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconSize = 28,
    this.tooltip,
  });

  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SoftCircleButton(
      onTap: onTap,
      tooltip: tooltip,
      child: Icon(icon, size: iconSize),
    );
  }
}

BoxDecoration _softCircleDecoration(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return BoxDecoration(
    color: theme.colorScheme.surface.withValues(alpha: 0.86),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(
      color: isDark
          ? theme.colorScheme.outline.withValues(alpha: 0.36)
          : Colors.white.withValues(alpha: 0.78),
    ),
    boxShadow: [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : const Color(0xFFD3D9E2).withValues(alpha: 0.34),
        blurRadius: 16,
        offset: const Offset(6, 8),
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.7),
        blurRadius: 12,
        offset: const Offset(-4, -4),
      ),
    ],
  );
}
