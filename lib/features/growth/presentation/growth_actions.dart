import 'dart:async';
import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/application/domain_event_bus.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'growth_copy.dart';
import 'growth_screen.dart';

final _busyTasks = <String>{};

/// All destructive UI entry points use the same preview and revision check.
Future<bool> performGrowthAction(
  BuildContext context,
  WidgetRef ref,
  String id, {
  bool completing = false,
  bool deleting = false,
}) async {
  if (!_busyTasks.add(id)) return false;
  try {
    final repository = await ref.read(repositoryProvider.future);
    int? revision;
    if (!completing) {
      while (true) {
        final change = await repository.previewGrowthRemoval(
          id,
          deleting: deleting,
        );
        if (!context.mounted) return false;
        final now = DateTime.now();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              deleting
                  ? growthText(
                      ctx,
                      '删除这项日程？',
                      'Delete this task?',
                      'この予定を削除しますか？',
                    )
                  : growthText(ctx, '取消完成？', 'Undo completion?', '完了を取り消しますか？'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    growthText(
                      ctx,
                      '总经验 ${change.before.totalXp} → ${change.after.totalXp}（${signedXp(change.delta)}）',
                      'Total XP ${change.before.totalXp} → ${change.after.totalXp} (${signedXp(change.delta)})',
                      '合計経験値 ${change.before.totalXp} → ${change.after.totalXp}（${signedXp(change.delta)}）',
                    ),
                  ),
                  Text('Lv${change.before.level} → Lv${change.after.level}'),
                  Text(
                    growthText(
                      ctx,
                      '当前连续 ${change.before.currentStreak(now)} → ${change.after.currentStreak(now)} 天',
                      'Current streak ${change.before.currentStreak(now)} → ${change.after.currentStreak(now)} days',
                      '現在の連続 ${change.before.currentStreak(now)} → ${change.after.currentStreak(now)} 日',
                    ),
                  ),
                  Text(
                    growthText(
                      ctx,
                      '最长连续 ${change.before.longestStreak} → ${change.after.longestStreak} 天',
                      'Best streak ${change.before.longestStreak} → ${change.after.longestStreak} days',
                      '最長連続 ${change.before.longestStreak} → ${change.after.longestStreak} 日',
                    ),
                  ),
                  if (change.revokedBadgeIds.isNotEmpty)
                    Text(
                      growthText(ctx, '将撤回：', 'Will revoke: ', '取り消されるバッジ：') +
                          change.revokedBadgeIds
                              .map((b) => badgeName(ctx, b))
                              .join(ctx.l10n.isChinese ? '、' : ', '),
                    ),
                  ...change.before.entries.where((e) => e.active).map((e) {
                    final after = change.after.entries.firstWhere(
                      (a) => a.id == e.id,
                    );
                    final delta = (after.active ? after.xp : 0) - e.xp;
                    if (delta == 0) return const SizedBox.shrink();
                    return Text(
                      '${ctx.l10n.localizedStoredText(e.title)} · ${e.dateKey}: ${signedXp(delta)}',
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(growthText(ctx, '保留原状', 'Keep unchanged', '変更しない')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(growthText(ctx, '确认', 'Confirm', '確認')),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return false;
        if (growthDateKey(DateTime.now()) != growthDateKey(now)) continue;
        revision = change.before.revision;
        try {
          if (deleting) {
            await ref
                .read(appStateProvider.notifier)
                .deleteTask(id, expectedRevision: revision);
          } else {
            await ref
                .read(appStateProvider.notifier)
                .toggleTaskCompletion(id, false, expectedRevision: revision);
          }
          return true;
        } on GrowthPreviewChanged {
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                growthText(
                  context,
                  '记录已变化，请确认最新影响。',
                  'Records changed. Please review the updated impact.',
                  '記録が変更されました。最新の影響をご確認ください。',
                ),
              ),
            ),
          );
        }
      }
    }
    await ref.read(appStateProvider.notifier).toggleTaskCompletion(id, true);
    if (context.mounted) {
      final item = ref
          .read(appStateProvider)
          .calendarItems
          .where((e) => e.id == id)
          .firstOrNull;
      if (item != null && item.source != SyncSource.localOnly) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              growthText(
                context,
                '已完成 · 系统／导入日程不发经验',
                'Completed · System/imported tasks earn no XP',
                '完了 · システム・インポート予定は経験値の対象外です',
              ),
            ),
          ),
        );
      }
    }
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            growthText(
              context,
              '保存失败，任务与成长未改变，请重试。',
              'Save failed. Task and growth are unchanged. Please retry.',
              '保存できませんでした。予定と成長は変更されていません。再試行してください。',
            ),
          ),
          action: SnackBarAction(
            label: growthText(context, '重试', 'Retry', '再試行'),
            onPressed: () => performGrowthAction(
              context,
              ref,
              id,
              completing: completing,
              deleting: deleting,
            ),
          ),
        ),
      );
    }
    return false;
  } finally {
    _busyTasks.remove(id);
  }
}

/// Serializes celebrations and consumes post-commit events, never granting XP.
class GrowthFeedbackHost extends ConsumerStatefulWidget {
  const GrowthFeedbackHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<GrowthFeedbackHost> createState() => _GrowthFeedbackHostState();
}

class _GrowthFeedbackHostState extends ConsumerState<GrowthFeedbackHost> {
  StreamSubscription<DomainEvent>? _sub;
  final _queue = <GrowthChange>[];
  bool _showing = false;
  final _presented = <String>{};
  @override
  void initState() {
    super.initState();
    _sub = ref.read(eventBusProvider).stream.listen((event) {
      if (event is GrowthUpdatedEvent &&
          event.showReward &&
          event.change.delta > 0) {
        _queue.add(event.change);
        WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
        WidgetsBinding.instance.scheduleFrame();
      }
    });
  }

  Future<void> _drain() async {
    if (_showing || !mounted) return;
    _showing = true;
    try {
      while (_queue.isNotEmpty) {
        if (!mounted) break;
        final change = _queue.removeAt(0);
        final seen = ref.read(appStateProvider).growth.seenBadgeIds;
        final fresh = change.newBadgeIds
            .where((id) => !seen.contains(id) && !_presented.contains(id))
            .toList();
        if (!change.upgraded && fresh.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                growthText(
                  context,
                  '+${change.delta} 经验 · 基础 10 + 连续加成 ${change.delta - 10}',
                  '+${change.delta} XP · Base 10 + streak ${change.delta - 10}',
                  '+${change.delta} 経験値 · 基本10 + 連続 ${change.delta - 10}',
                ),
              ),
            ),
          );
          continue;
        }
        _presented.addAll(fresh);
        final target = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    change.upgraded
                        ? growthText(
                            ctx,
                            '升级到 Lv${change.after.level}',
                            'Reached Lv${change.after.level}',
                            'Lv${change.after.level} にアップ',
                          )
                        : growthText(
                            ctx,
                            '新的陪伴徽章',
                            'New companion badge',
                            '新しいバッジ',
                          ),
                  ),
                ),
                IconButton(
                  tooltip: growthText(ctx, '关闭', 'Close', '閉じる'),
                  onPressed: () => Navigator.pop(ctx, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.celebration, size: 56),
                  Text(
                    growthText(
                      ctx,
                      '+${change.delta} 经验 · 基础 10 + 连续加成 ${change.delta - 10}',
                      '+${change.delta} XP · Base 10 + streak ${change.delta - 10}',
                      '+${change.delta} 経験値 · 基本10 + 連続 ${change.delta - 10}',
                    ),
                  ),
                  ...fresh.map((b) => Text(badgeName(ctx, b))),
                  const SizedBox(height: 12),
                  Text(
                    growthText(
                      ctx,
                      '距 Lv${change.after.level + 1} 还差 ${change.after.nextLevelXp} 经验',
                      '${change.after.nextLevelXp} XP to Lv${change.after.level + 1}',
                      'Lv${change.after.level + 1} まであと ${change.after.nextLevelXp} 経験値',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(growthText(ctx, '继续安排', 'Keep planning', '予定に戻る')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(growthText(ctx, '查看徽章', 'View badges', 'バッジを見る')),
              ),
            ],
          ),
        );
        if (!mounted) break;
        try {
          await ref
              .read(appStateProvider.notifier)
              .acknowledgeGrowthBadges(fresh);
        } catch (error) {
          debugPrint('Badge acknowledgement failed: $error');
        }
        if (target == true && mounted) openGrowthPage(context, 'badges');
      }
    } finally {
      _showing = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
