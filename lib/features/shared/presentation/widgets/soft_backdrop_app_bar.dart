import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:flutter/material.dart';

class SoftBackdropAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SoftBackdropAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceStyle = theme.extension<AppThemeSurfaceStyle>();
    final backdropColors =
        surfaceStyle?.backdropColors ??
        const [Color(0xFFF6F9FC), Color(0xFFF0F5FA), Color(0xFFE8EEF5)];
    final topColor = backdropColors.first;
    final secondColor = backdropColors.length > 1
        ? backdropColors[1]
        : backdropColors.first;

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topColor,
              Color.lerp(topColor, secondColor, 0.7)!,
              secondColor.withValues(alpha: 0.96),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
