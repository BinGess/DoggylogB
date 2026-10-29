import 'dart:async';
import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/pets/presentation/pets_screen.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/calendar/presentation/calendar_theme_assets.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'growth_copy.dart';

void openGrowthPage(BuildContext context, String page) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => GrowthScreen(page: page)));
}

/// Refreshes time-dependent streaks at local midnight and on foreground resume.
class GrowthClock extends StatefulWidget {
  const GrowthClock({super.key, required this.builder});
  final Widget Function(BuildContext, DateTime) builder;
  @override
  State<GrowthClock> createState() => _GrowthClockState();
}

class _GrowthClockState extends State<GrowthClock> with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(
      next.difference(now) + const Duration(milliseconds: 50),
      _refresh,
    );
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}

class GrowthPetCard extends ConsumerWidget {
  const GrowthPetCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final pet = state.selectedPet;
    final l = context.l10n;
    final spec = appSkinThemeForBreed(pet?.breed ?? PetBreed.shiba).spec;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                calendarTimelineAssetsForBreed(pet?.breed).pngAssetPath,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet == null
                          ? l.noPetSelected
                          : l.localizedStoredText(pet.name),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(l.localizedSkinStyleName(spec.styleName)),
                  ],
                ),
              ),
              TextButton(
                key: const Key('growth-dress-up'),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PetsScreen()),
                ),
                child: Text(growthText(context, '换装', 'Dress up', '着せ替え')),
              ),
            ],
          ),
          const Divider(height: 24),
          if (state.growthUnavailable) const GrowthRecoveryNotice(),
          if (!state.growthUnavailable)
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('growth-details'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => openGrowthPage(context, 'growth'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GrowthSummary(growth: state.growth),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            growthText(
                              context,
                              '成长详情',
                              'Growth details',
                              '成長の詳細',
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GrowthSummary extends StatelessWidget {
  const GrowthSummary({super.key, required this.growth, this.expanded = false});
  final CompanionGrowth growth;
  final bool expanded;
  @override
  Widget build(BuildContext context) => GrowthClock(
    builder: (context, now) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lv${growth.level} · ${badgeName(context, growth.titleBadgeId)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (expanded)
          Text(
            growthText(
              context,
              '总经验 ${growth.totalXp}',
              'Total XP ${growth.totalXp}',
              '合計経験値 ${growth.totalXp}',
            ),
          ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: growth.levelXp / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Text(
          growthText(
            context,
            '本级 ${growth.levelXp}/100 · 距下一级 ${growth.nextLevelXp}',
            '${growth.levelXp}/100 XP · ${growth.nextLevelXp} to next level',
            '現在 ${growth.levelXp}/100 · 次まで ${growth.nextLevelXp}',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              growthText(
                context,
                '当前连续 ${growth.currentStreak(now)} 天',
                'Streak ${growth.currentStreak(now)} days',
                '現在 ${growth.currentStreak(now)} 日連続',
              ),
            ),
            Text(
              growthText(
                context,
                '最长 ${growth.longestStreak} 天',
                'Best ${growth.longestStreak} days',
                '最長 ${growth.longestStreak} 日',
              ),
            ),
            Text(
              growthText(
                context,
                '徽章 ${growth.badgeIds.length}/7',
                'Badges ${growth.badgeIds.length}/7',
                'バッジ ${growth.badgeIds.length}/7',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key, this.page = 'growth'});
  final String page;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final g = state.growth;
    final title = page == 'badges'
        ? growthText(context, '陪伴徽章', 'Companion badges', '寄り添いバッジ')
        : page == 'ledger'
        ? growthText(context, '经验明细', 'XP history', '経験値の履歴')
        : growthText(context, '陪伴成长', 'Companion growth', '一緒に成長');
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (state.growthUnavailable) const GrowthRecoveryNotice(),
            if (page == 'growth' && !state.growthUnavailable) ...[
              LiquidGlassCard(child: GrowthSummary(growth: g, expanded: true)),
              const SizedBox(height: 20),
              LiquidGlassCard(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        growthText(
                          context,
                          '陪伴徽章',
                          'Companion badges',
                          '寄り添いバッジ',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => openGrowthPage(context, 'badges'),
                    ),
                    ListTile(
                      title: Text(
                        growthText(context, '经验明细', 'XP history', '経験値の履歴'),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => openGrowthPage(context, 'ledger'),
                    ),
                    ListTile(
                      title: Text(
                        growthText(
                          context,
                          '经验如何获得',
                          'How to earn XP',
                          '経験値の獲得方法',
                        ),
                      ),
                      trailing: const Icon(Icons.help_outline),
                      onTap: () => showGrowthRules(context),
                    ),
                  ],
                ),
              ),
            ],
            if (page == 'badges' && !state.growthUnavailable)
              ...growthBadges.map((b) {
                final earned = g.badgeIds.contains(b.id);
                final value = b.isStreak ? g.longestStreak : g.level;
                final condition = b.isStreak
                    ? growthText(
                        context,
                        '最长有效连续 ${b.goal} 天',
                        'Best valid streak: ${b.goal} days',
                        '最長有効連続 ${b.goal} 日',
                      )
                    : 'Lv${b.goal}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiquidGlassCard(
                    child: ListTile(
                      leading: Icon(
                        earned ? Icons.workspace_premium : Icons.lock_outline,
                        color: earned
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(badgeName(context, b.id)),
                      subtitle: Text(
                        '$condition · ${earned ? growthText(context, "已达成", "Earned", "達成済み") : "$value/${b.goal}"}',
                      ),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(badgeName(context, b.id)),
                          content: Text(
                            '$condition\n${value > b.goal ? b.goal : value}/${b.goal}\n${growthText(context, "撤销支撑记录后会重新判断，不影响已购外观。", "Recalculated when supporting completions are revoked. Purchased skins are unaffected.", "達成の根拠となる記録の取消後に再計算します。購入済みの外観には影響しません。")}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(context.l10n.done),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            if (page == 'ledger' && !state.growthUnavailable) ...[
              Text(
                growthText(
                  context,
                  '仅记录新版本启用后的奖励；历史积分不计入。',
                  'Only rewards earned in this version are included. Legacy points are excluded.',
                  '新バージョン開始後の報酬のみ記録します。以前のポイントは含まれません。',
                ),
              ),
              const SizedBox(height: 16),
              if (g.entries.isEmpty)
                Text(
                  growthText(
                    context,
                    '完成一个本地日程，开始积累经验。',
                    'Complete a local task to start earning XP.',
                    'ローカルの予定を完了して経験値を獲得しましょう。',
                  ),
                ),
              ...g.entries.reversed.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiquidGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.localizedStoredText(e.title),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${DateFormat.yMd(context.l10n.localeName).format(DateTime.parse(e.dateKey))} · ${DateFormat.Hm(context.l10n.localeName).format(e.completedAt.toLocal())}',
                        ),
                        Text(
                          growthText(
                            context,
                            '基础 ${e.baseXp} · 当日连续加成 ${e.bonusXp} · 连续 ${e.streak} 天',
                            'Base ${e.baseXp} · Daily bonus ${e.bonusXp} · Streak ${e.streak}',
                            '基本 ${e.baseXp} · 当日ボーナス ${e.bonusXp} · 連続 ${e.streak} 日',
                          ),
                        ),
                        Text(
                          e.active
                              ? growthText(
                                  context,
                                  '有效 · +${e.xp}',
                                  'Active · +${e.xp}',
                                  '有効 · +${e.xp}',
                                )
                              : growthText(
                                  context,
                                  '已作废 · ${e.reason == "delete" ? "删除" : "取消完成"}',
                                  'Revoked · ${e.reason == "delete" ? "Deleted" : "Undone"}',
                                  '無効 · ${e.reason == "delete" ? "削除" : "完了取消"}',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                growthText(context, '账目变动记录', 'Account adjustments', '調整履歴'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...g.audit.reversed.map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${context.l10n.localizedStoredText(a.title)} · ${signedXp(a.delta)}',
                  ),
                  subtitle: Text(
                    '${growthReason(context, a.reason)} · ${DateFormat.yMd(context.l10n.localeName).add_Hm().format(a.at.toLocal())}\n${a.beforeXp} → ${a.afterXp}\n${a.adjustments.entries.map((v) {
                      final entry = g.entries.firstWhere((e) => e.id == v.key);
                      final day = DateFormat.yMd(context.l10n.localeName).format(DateTime.parse(entry.dateKey));
                      return "${context.l10n.localizedStoredText(entry.title)} ($day): ${signedXp(v.value)}";
                    }).join("\n")}',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showGrowthRules(BuildContext context) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(growthText(context, '经验如何获得', 'How to earn XP', '経験値の獲得方法')),
    content: SingleChildScrollView(
      child: Text(
        growthText(
          context,
          '每个有效本地任务：基础 +10。\n连续 3–4 天：每天一次 +5。\n连续 5–6 天：每天一次 +8。\n连续 7 天及以上：每天一次 +12。\n\n按实际完成时的本地自然日统计；加成归属当日最早的有效完成记录。编辑计划日期不改变奖励。撤销或删除会重算当日及后续受影响奖励。\n\n每 100 经验升一级。系统／导入事项和倒计时不发经验；外观与成长独立。',
          'Each valid local task: +10 base XP.\nDays 3–4: +5 once daily.\nDays 5–6: +8 once daily.\nDay 7 onward: +12 once daily.\n\nStreaks use the local date of actual completion. The earliest valid completion carries the daily bonus. Editing planned dates does not change rewards. Undoing or deleting recalculates affected rewards.\n\nEvery 100 XP earns a level. System/imported tasks and countdowns earn no XP. Skins are independent of growth.',
          '有効なローカル予定ごとに基本 +10。\n連続3–4日：1日1回 +5。\n連続5–6日：1日1回 +8。\n連続7日以上：1日1回 +12。\n\n実際の完了時の現地日付で計算します。当日最初の有効記録にボーナスを付与します。予定日の編集では報酬は変わりません。取消・削除時は関連報酬を再計算します。\n\n100経験値ごとにレベルアップ。システム・インポート予定やカウントダウンは対象外。外観と成長は独立しています。',
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(context.l10n.done),
      ),
    ],
  ),
);

class GrowthRecoveryNotice extends ConsumerWidget {
  const GrowthRecoveryNotice({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Icons.error_outline),
    title: Text(
      growthText(
        context,
        '成长数据暂不可用',
        'Growth data unavailable',
        '成長データを読み込めません',
      ),
    ),
    subtitle: Text(
      growthText(
        context,
        '已保留原数据；恢复前暂停成长写入。',
        'Original data is retained. Growth writes are paused until recovery.',
        '元データは保持されています。復旧まで成長の書き込みを停止します。',
      ),
    ),
    trailing: TextButton(
      onPressed: () =>
          ref.read(appStateProvider.notifier).retryGrowthInitialization(),
      child: Text(growthText(context, '重试', 'Retry', '再試行')),
    ),
  );
}
