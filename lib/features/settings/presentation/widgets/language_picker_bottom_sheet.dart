import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';

Future<AppLanguageMode?> showLanguagePickerBottomSheet(
  BuildContext context, {
  required AppLanguageMode selectedMode,
}) {
  return showModalBottomSheet<AppLanguageMode>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return LanguagePickerBottomSheet(selectedMode: selectedMode);
    },
  );
}

class LanguagePickerBottomSheet extends StatelessWidget {
  const LanguagePickerBottomSheet({super.key, required this.selectedMode});

  final AppLanguageMode selectedMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaceStyle = theme.extension<AppThemeSurfaceStyle>();
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: LiquidGlassCard(
          key: const Key('language-picker-sheet'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.tertiary.withValues(alpha: 0.92),
                              scheme.primary.withValues(alpha: 0.82),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (surfaceStyle?.cardShadowColor ??
                                          Colors.black)
                                      .withValues(alpha: 0.18),
                              blurRadius: 18,
                              spreadRadius: -8,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.translate_rounded,
                          color: scheme.onTertiary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.languagePickerTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.languagePickerSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                          backgroundColor: scheme.surface.withValues(
                            alpha: 0.62,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  for (final mode in AppLanguageMode.values) ...[
                    _LanguageOptionCard(
                      mode: mode,
                      isSelected: mode == selectedMode,
                    ),
                    if (mode != AppLanguageMode.values.last)
                      const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    l10n.languagePickerTapHint,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({required this.mode, required this.isSelected});

  final AppLanguageMode mode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaceStyle = theme.extension<AppThemeSurfaceStyle>();
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(
      (surfaceStyle?.cardRadius ?? 24) - 8,
    );

    final background = isSelected
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.tertiary.withValues(alpha: 0.16),
              scheme.primary.withValues(alpha: 0.12),
              scheme.surface,
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surface.withValues(alpha: 0.92),
              scheme.surfaceContainerHighest.withValues(alpha: 0.82),
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('language-option-${mode.name}'),
        borderRadius: borderRadius,
        onTap: () => Navigator.of(context).pop(mode),
        child: Ink(
          decoration: BoxDecoration(
            gradient: background,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected
                  ? scheme.tertiary.withValues(alpha: 0.58)
                  : (surfaceStyle?.cardBorderColor ??
                            scheme.outline.withValues(alpha: 0.24))
                        .withValues(alpha: isSelected ? 0.58 : 0.7),
              width: isSelected
                  ? (surfaceStyle?.cardBorderWidth ?? 1) + 0.4
                  : surfaceStyle?.cardBorderWidth ?? 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (surfaceStyle?.cardShadowColor ?? Colors.black)
                    .withValues(alpha: isSelected ? 0.14 : 0.08),
                blurRadius: isSelected ? 22 : 16,
                spreadRadius: -10,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.tertiary
                        : scheme.surface.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    context.l10n.languageLeadingBadge(mode),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? scheme.onTertiary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.languageCurrentLabel(mode),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.languageNativeLabel(mode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? scheme.tertiary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.languageOptionDescription(mode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('selected'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.tertiary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.languagePickerCurrentBadge,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.arrow_outward_rounded,
                          key: const ValueKey('unselected'),
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
