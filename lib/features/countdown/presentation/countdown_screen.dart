import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CountdownScreen extends ConsumerWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final countdowns = state.countdowns;
    final now = DateTime.now();
    final nearest = countdowns.isEmpty
        ? null
        : ([...countdowns]..sort((a, b) => a.dueAt.compareTo(b.dueAt)));
    return Scaffold(
      appBar: AppBar(title: const Text('陪伴式倒计时')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateEntryScreen(
          context,
          initialTab: CreateEntryTab.countdown,
          initialDate: state.selectedDate,
        ),
        icon: const Icon(Icons.flag_rounded),
        label: const Text('新增倒计时'),
      ),
      body: SoftBackdrop(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: countdowns.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return LiquidGlassCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.14),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.88),
                  ],
                ),
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
                            label: '总数',
                            value: '${countdowns.length}',
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
            final progress = item.progress(now);
            final colors = switch (item.mood(now)) {
              CountdownMood.sunrise => [
                const Color(0xFFFFD6A5),
                const Color(0xFFFFADAD),
              ],
              CountdownMood.noon => [
                const Color(0xFF90E0EF),
                const Color(0xFF48CAE4),
              ],
              CountdownMood.dusk => [
                const Color(0xFFFFB4A2),
                const Color(0xFFE5989B),
              ],
              CountdownMood.midnight => [
                const Color(0xFF3A0CA3),
                const Color(0xFF4361EE),
              ],
            };
            return LiquidGlassCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors
                    .map((item) => item.withValues(alpha: 0.28))
                    .toList(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (item.isPinned)
                        const Icon(Icons.push_pin_rounded, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '截止 ${DateFormat('yyyy/MM/dd HH:mm').format(item.dueAt)}',
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '剩余 ${(item.dueAt.difference(now).inHours / 24).ceil()} 天',
                      ),
                      const Spacer(),
                      Text('${(progress * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
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
