import 'package:doggylog/features/pets/presentation/pets_screen.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fontScaleOptions = <({String label, double value})>[
  (label: '小', value: 1.0),
  (label: '中', value: 1.1),
  (label: '大', value: 1.2),
];

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
            Text('宠物', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            LiquidGlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('管理宠物皮肤'),
                subtitle: const Text('进入页面后切换宠物，对应整套 App 皮肤会立即切换'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PetsScreen()),
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
                    title: const Text('系统日历'),
                    subtitle: Text(
                      _systemCalendarSummary(preferences),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SystemCalendarSettingsScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('字号'),
                    subtitle: const Text('切换小、中、大三档全局字体大小'),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fontScaleOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option.label),
                          selected: preferences.fontScale == option.value,
                          onSelected: (_) => controller.updatePreferences(
                            preferences.copyWith(fontScale: option.value),
                          ),
                        );
                      }).toList(),
                    ),
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

String _systemCalendarSummary(UserPreference preferences) {
  if (!preferences.useSystemCalendarFilter) {
    return '默认展示系统上所有可访问的日历事件';
  }
  if (preferences.visibleSystemCalendarIds.isEmpty) {
    return '当前未纳入任何系统日历';
  }
  return '已选择 ${preferences.visibleSystemCalendarIds.length} 个系统日历';
}

class SystemCalendarSettingsScreen extends ConsumerStatefulWidget {
  const SystemCalendarSettingsScreen({super.key});

  @override
  ConsumerState<SystemCalendarSettingsScreen> createState() =>
      _SystemCalendarSettingsScreenState();
}

class _SystemCalendarSettingsScreenState
    extends ConsumerState<SystemCalendarSettingsScreen> {
  late Future<List<SystemCalendar>> _calendarsFuture;
  final Set<String> _selectedIds = <String>{};
  bool _hasInitializedSelection = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _calendarsFuture = ref
        .read(appStateProvider.notifier)
        .loadSystemCalendars();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appStateProvider).preferences;
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统日历'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _saveSelection(context),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('完成'),
          ),
        ],
      ),
      body: SoftBackdrop(
        child: FutureBuilder<List<SystemCalendar>>(
          future: _calendarsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final calendars = snapshot.data ?? const <SystemCalendar>[];
            if (!_hasInitializedSelection) {
              _hasInitializedSelection = true;
              if (preferences.useSystemCalendarFilter) {
                _selectedIds
                  ..clear()
                  ..addAll(preferences.visibleSystemCalendarIds);
              } else {
                _selectedIds
                  ..clear()
                  ..addAll(calendars.map((calendar) => calendar.id));
              }
            }
            if (calendars.isEmpty) {
              return _EmptySystemCalendarState(
                onRetry: () {
                  setState(() {
                    _hasInitializedSelection = false;
                    _calendarsFuture = ref
                        .read(appStateProvider.notifier)
                        .loadSystemCalendars();
                  });
                },
              );
            }
            final grouped = <String, List<SystemCalendar>>{};
            for (final calendar in calendars) {
              grouped.putIfAbsent(calendar.sourceTitle, () => []).add(calendar);
            }
            final groups = grouped.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '勾选后纳入 DoggyLog 展示与增量同步范围。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                LiquidGlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('全部日历'),
                        subtitle: const Text('默认会自动纳入新出现的系统日历'),
                        trailing: Checkbox(
                          value: _selectedIds.length == calendars.length,
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedIds
                                  ..clear()
                                  ..addAll(calendars.map((item) => item.id));
                              } else {
                                _selectedIds.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      group.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  LiquidGlassCard(
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < group.value.length;
                          index++
                        ) ...[
                          _SystemCalendarTile(
                            calendar: group.value[index],
                            selected: _selectedIds.contains(
                              group.value[index].id,
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  _selectedIds.add(group.value[index].id);
                                } else {
                                  _selectedIds.remove(group.value[index].id);
                                }
                              });
                            },
                          ),
                          if (index != group.value.length - 1)
                            const Divider(height: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveSelection(BuildContext context) async {
    final navigator = Navigator.of(context);
    final calendars = await _calendarsFuture;
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(appStateProvider.notifier)
          .updateVisibleSystemCalendars(
            _selectedIds.toList(),
            totalCalendarCount: calendars.length,
          );
      if (!mounted) {
        return;
      }
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SystemCalendarTile extends StatelessWidget {
  const _SystemCalendarTile({
    required this.calendar,
    required this.selected,
    required this.onChanged,
  });

  final SystemCalendar calendar;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = _parseColor(calendar.colorHex);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => onChanged(!selected),
      leading: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: indicatorColor, width: 2),
          color: selected ? indicatorColor : Colors.transparent,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
            : null,
      ),
      title: Text(calendar.title),
      subtitle: calendar.allowsContentModifications ? null : const Text('只读日历'),
      trailing: Checkbox(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
      ),
    );
  }
}

class _EmptySystemCalendarState extends StatelessWidget {
  const _EmptySystemCalendarState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 48),
            const SizedBox(height: 12),
            Text('未读取到系统日历', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '请确认已授予日历权限，或当前设备确实存在可访问的日历。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('重新加载')),
          ],
        ),
      ),
    );
  }
}

Color _parseColor(String colorHex) {
  final normalized = colorHex.replaceFirst('#', '');
  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(normalized);
  return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFC7CDD8);
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
