import 'package:doggylog/features/countdown/presentation/countdown_detail_sheet.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop_app_bar.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_circle_icon_button.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final countdowns = state.countdowns;
    final now = DateTime.now();
    final nearest = countdowns.isEmpty
        ? null
        : ([...countdowns]..sort((a, b) => a.dueAt.compareTo(b.dueAt)));
    final activeCount = countdowns.where((item) => !item.hasCelebrated).length;
    return Scaffold(
      appBar: SoftBackdropAppBar(
        title: const Text('陪伴式倒计时'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SoftCircleIconButton(
                onTap: () => showCreateEntryScreen(
                  context,
                  initialTab: CreateEntryTab.countdown,
                  initialDate: state.selectedDate,
                ),
                icon: Icons.add_rounded,
                tooltip: '添加',
              ),
            ),
          ),
        ],
      ),
      body: SoftBackdrop(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: countdowns.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '下一次重要节点',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nearest == null
                          ? '还没有倒计时，先放一个值得期待的日期。'
                          : '${nearest.first.title} · ${DateFormat('M 月 d 日').format(nearest.first.dueAt)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: '进行中',
                            value: '$activeCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryStat(
                            label: '最近到期',
                            value: nearest == null
                                ? '--'
                                : '${nearest.first.dueAt.difference(now).inDays + 1} 天',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            final item = countdowns[index - 1];
            return CountdownTile(
              item: item,
              now: now,
              onToggleCelebrated: (value) =>
                  controller.toggleCountdownCelebrated(item.id, value),
              onDelete: () => controller.deleteCountdown(item.id),
              onTap: () => showCountdownDetailSheet(context, ref, item: item),
            );
          },
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

    return Dismissible(
      key: ValueKey(item.id),
      background: _swipeAction(
        context,
        icon: item.hasCelebrated ? Icons.undo_rounded : Icons.check_rounded,
        label: item.hasCelebrated ? '恢复' : '完成',
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeAction(
        context,
        icon: Icons.delete_outline_rounded,
        label: '删除',
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleCelebrated(!item.hasCelebrated);
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
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      decoration: item.hasCelebrated
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.hasCelebrated
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
                _StatusBadge(item: item),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '截止 ${DateFormat('yyyy/MM/dd HH:mm').format(item.dueAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: item.hasCelebrated ? 1 : progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _remainingLabel(item, now),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  item.hasCelebrated
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

  static String _remainingLabel(CountdownItem item, DateTime now) {
    if (item.hasCelebrated) {
      return '已完成';
    }
    final hours = item.dueAt.difference(now).inHours;
    if (hours < 0) {
      return '已逾期 ${hours.abs().ceil()} 小时';
    }
    final days = (hours / 24).ceil();
    return '剩余 $days 天';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final CountdownItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = item.hasCelebrated ? const Color(0xFF2B9348) : scheme.primary;
    final label = item.hasCelebrated ? '已完成' : '详情';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: item.hasCelebrated ? 0.12 : 0.08),
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
