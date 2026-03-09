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
    return Scaffold(
      appBar: AppBar(title: const Text('任务复盘')),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [TaskReviewSection(stats: stats)],
        ),
      ),
    );
  }
}

class TaskReviewSection extends StatelessWidget {
  const TaskReviewSection({
    super.key,
    required this.stats,
    this.showTitle = true,
  });

  final DashboardStats stats;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final rate = stats.completionRate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiquidGlassCard(
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
              if (showTitle) ...[
                Text('任务复盘', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
              ],
              Text('完成率', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '柔和面板展示近期执行质量与陪伴成长。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: rate, minHeight: 14),
              ),
              const SizedBox(height: 12),
              Text(
                '${(rate * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
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
                          Expanded(child: Text(category.label)),
                          Text('$count'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: count / max,
                          minHeight: 10,
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
          Text(title),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
