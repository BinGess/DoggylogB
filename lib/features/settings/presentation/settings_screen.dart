import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:doggylog/features/stats/presentation/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final preferences = state.preferences;
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TaskReviewSummaryCard(
              stats: state.stats,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TaskReviewDetailScreen(stats: state.stats),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('设置', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            LiquidGlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('周一作为起始日'),
                    value: preferences.weekStartsOnMonday,
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(weekStartsOnMonday: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('震动反馈'),
                    value: preferences.hapticsEnabled,
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(hapticsEnabled: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Face ID / Touch ID'),
                    value: preferences.faceIdEnabled,
                    onChanged: controller.setFaceIdEnabled,
                  ),
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('开发调试'),
                    subtitle: const Text('动画强度、提醒调试与 iOS 增强能力'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DevelopmentDebugScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DevelopmentDebugScreen extends ConsumerWidget {
  const DevelopmentDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final preferences = state.preferences;
    return Scaffold(
      appBar: AppBar(title: const Text('开发调试')),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('动画强度', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '保留柔和动效，但给低性能设备留出缓冲。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: preferences.animationSpeed,
                    min: 0.7,
                    max: 1.4,
                    divisions: 7,
                    label: preferences.animationSpeed.toStringAsFixed(1),
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(animationSpeed: value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('渲染档位', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PerformanceTier.values.map((tier) {
                      return ChoiceChip(
                        label: Text(tier.name),
                        selected: preferences.performanceTier == tier,
                        onSelected: (_) => controller.updatePreferences(
                          preferences.copyWith(performanceTier: tier),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('提醒调试模式'),
                    subtitle: const Text('保存带提醒的任务后，立即触发一次 App 内提醒预览'),
                    value: preferences.debugImmediateReminders,
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(debugImmediateReminders: value),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'iOS 增强能力',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _CapabilityRow(
                    title: 'EventKit 同步',
                    subtitle: state.calendarPermissionGranted
                        ? '日历已可访问，可导入系统事件并回写 DoggyLog 任务'
                        : '尚未授予日历权限',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: controller.importIosCalendarEvents,
                        child: const Text('导入系统日历'),
                      ),
                      FilledButton.tonal(
                        onPressed: controller.syncAllToIosCalendar,
                        child: const Text('同步到 iOS 日历'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: '通知提醒',
                    subtitle: state.notificationPermissionGranted
                        ? '通知权限已开启，任务保存后会自动调度提醒'
                        : '尚未授予通知权限',
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: controller.requestNotificationPermissions,
                    child: const Text('开启通知权限'),
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: '地理围栏遛弯模式',
                    subtitle: state.locationPermissionGranted
                        ? state.activeGeofenceName == null
                              ? '位置权限已开启，当前未进入任何预设围栏'
                              : '当前位于 ${state.activeGeofenceName}，宠物状态为 ${state.activeScene.name}'
                        : '尚未授予定位权限，无法自动切换宠物场景',
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: controller.enableGeofenceMonitoring,
                    child: Text(
                      state.locationPermissionGranted ? '刷新地理围栏状态' : '开启定位权限',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: 'Core Motion 视差',
                    subtitle: state.sensorStreamActive
                        ? '传感器流已启动，液态玻璃和宠物动效会跟随设备倾斜'
                        : '当前设备未启用传感器流，界面会自动降级为静态效果',
                  ),
                  if (state.lastSyncMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      state.lastSyncMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 14),
                  const _CapabilityRow(
                    title: 'CloudKit 备份恢复',
                    subtitle: '共享快照与映射存储已预留',
                  ),
                  const _CapabilityRow(
                    title: 'Widget / Dynamic Island',
                    subtitle: '快照协议与原生扩展骨架待接入',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
