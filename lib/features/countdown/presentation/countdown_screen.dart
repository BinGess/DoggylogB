import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/countdown/presentation/countdown_detail_sheet.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_circle_icon_button.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final now = DateTime.now();
    final countdowns = [...state.countdowns]
      ..sort((a, b) {
        final aCompleted = a.isCompletedAt(now);
        final bCompleted = b.isCompletedAt(now);
        if (aCompleted != bCompleted) {
          return aCompleted ? 1 : -1;
        }
        final distanceOrder = a.dueAt
            .difference(now)
            .inMicroseconds
            .abs()
            .compareTo(b.dueAt.difference(now).inMicroseconds.abs());
        return distanceOrder != 0 ? distanceOrder : a.id.compareTo(b.id);
      });
    final upcoming = countdowns
        .where((item) => !item.isCompletedAt(now))
        .toList();
    final nearest = upcoming.isEmpty ? null : upcoming;
    final activeCount = upcoming.length;
    final l10n = context.l10n;
    return Scaffold(
      body: SoftBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            itemCount: countdowns.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                final titleStyle = Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700);
                return SoftBackdropPageHeader(
                  title: l10n.countdownTitle,
                  subtitle: l10n.countdownSubtitle,
                  titleStyle: titleStyle,
                  trailing: SoftCircleIconButton(
                    onTap: () => showCreateEntryScreen(
                      context,
                      initialTab: CreateEntryTab.countdown,
                      initialDate: state.selectedDate,
                    ),
                    icon: Icons.add_rounded,
                    tooltip: l10n.add,
                  ),
                );
              }

              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LiquidGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.nextImportantMilestone,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nearest == null
                              ? l10n.noCountdownYet
                              : '${l10n.localizedStoredText(nearest.first.title)} · ${l10n.shortDate(nearest.first.dueAt)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryStat(
                                label: l10n.inProgress,
                                value: '$activeCount',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryStat(
                                label: l10n.dueSoon,
                                value: nearest == null
                                    ? '--'
                                    : l10n.daysLabel(
                                        (nearest.first.dueAt
                                                    .difference(now)
                                                    .inHours /
                                                24)
                                            .ceil()
                                            .clamp(0, 999),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = countdowns[index - 2];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CountdownTile(
                  item: item,
                  now: now,
                  onToggleCelebrated: (value) =>
                      controller.toggleCountdownCelebrated(item.id, value),
                  onDelete: () => controller.deleteCountdown(item.id),
                  onTap: () =>
                      showCountdownDetailSheet(context, ref, item: item),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CountdownTile extends StatelessWidget {
  const CountdownTile({
    super.key,
    required this.item,
    required this.now,
    required this.onToggleCelebrated,
    required this.onDelete,
    required this.onTap,
  });

  final CountdownItem item;
  final DateTime now;
  final ValueChanged<bool> onToggleCelebrated;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = item.progress(now);
    final isCompleted = item.isCompletedAt(now);
    final isExpired = !item.dueAt.isAfter(now);

    return Dismissible(
      key: ValueKey(item.id),
      direction: isExpired
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      background: _swipeAction(
        context,
        icon: isCompleted ? Icons.undo_rounded : Icons.check_rounded,
        label: isCompleted ? context.l10n.restore : context.l10n.complete,
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeAction(
        context,
        icon: Icons.delete_outline_rounded,
        label: context.l10n.delete,
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleCelebrated(!isCompleted);
          return false;
        }
        onDelete();
        return false;
      },
      child: LiquidGlassCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.localizedStoredText(item.title),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.48)
                          : null,
                    ),
                  ),
                ),
                if (item.isPinned) ...[
                  const Icon(Icons.push_pin_rounded, size: 18),
                  const SizedBox(width: 8),
                ],
                _StatusBadge(isCompleted: isCompleted),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.dueAtLabel(item.dueAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: isCompleted ? 1 : progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _remainingLabel(context, item, now),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  isCompleted
                      ? '100%'
                      : '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _swipeAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Alignment alignment,
  }) {
    final padding = alignment == Alignment.centerLeft
        ? const EdgeInsets.only(left: 24)
        : const EdgeInsets.only(right: 24);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static String _remainingLabel(
    BuildContext context,
    CountdownItem item,
    DateTime now,
  ) {
    final l10n = context.l10n;
    if (item.isCompletedAt(now)) {
      return l10n.completed;
    }
    final hours = item.dueAt.difference(now).inMinutes / 60;
    final days = (hours / 24).ceil();
    return l10n.remainingDaysLabel(days);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isCompleted ? const Color(0xFF2B9348) : scheme.primary;
    final label = isCompleted ? context.l10n.completed : context.l10n.detail;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isCompleted ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surface.withValues(alpha: 0.76),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
