import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStateProvider).stats;
    return TaskReviewDetailScreen(stats: stats);
  }
}

class TaskReviewDetailScreen extends StatelessWidget {
  const TaskReviewDetailScreen({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务复盘')),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [TaskReviewDetailSection(stats: stats)],
        ),
      ),
    );
  }
}

class TaskReviewSummaryCard extends StatelessWidget {
  const TaskReviewSummaryCard({super.key, required this.stats, this.onTap});

  final DashboardStats stats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rate = stats.completionRate;
    final child = LiquidGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '任务复盘',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '查看连续打卡、忠诚度总分和分类分布。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: rate, minHeight: 10),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(rate * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '完成率',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
    if (onTap == null) {
      return child;
    }
    return GestureDetector(onTap: onTap, child: child);
  }
}

class TaskReviewDetailSection extends StatelessWidget {
  const TaskReviewDetailSection({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskReviewSummaryCard(stats: stats),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: '连续打卡',
                value: '${stats.streakDays} 天',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: '忠诚度总分',
                value: '${stats.loyaltyPoints}',
                icon: Icons.pets_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('分类分布', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...CalendarCategory.values.map((category) {
                final count = stats.categoryCounts[category] ?? 0;
                final max = stats.totalTasks == 0 ? 1 : stats.totalTasks;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.label,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            '$count',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: count / max,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.14),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
