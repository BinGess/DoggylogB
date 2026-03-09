import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/compact_date_time_field.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum CreateEntryTab { schedule, countdown }

Future<void> showCreateEntryScreen(
  BuildContext context, {
  CreateEntryTab initialTab = CreateEntryTab.schedule,
  DateTime? initialDate,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          CreateEntryScreen(initialTab: initialTab, initialDate: initialDate),
    ),
  );
}

class CreateEntryScreen extends ConsumerStatefulWidget {
  const CreateEntryScreen({
    super.key,
    this.initialTab = CreateEntryTab.schedule,
    this.initialDate,
  });

  final CreateEntryTab initialTab;
  final DateTime? initialDate;

  @override
  ConsumerState<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends ConsumerState<CreateEntryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _titleController;
  late DateTime _startAt;
  late DateTime _endAt;
  late DateTime _countdownAt;
  _RepeatOption _repeat = _RepeatOption.none;
  _ReminderOption _scheduleReminder = _ReminderOption.atTime;
  _ReminderOption _countdownReminder = _ReminderOption.atTime;
  _CalendarOption _calendar = _CalendarOption.personal;
  _StickerOption _sticker = _StickerOption.stopwatch;

  CreateEntryTab get _activeTab => CreateEntryTab.values[_tabController.index];

  @override
  void initState() {
    super.initState();
    final seed = widget.initialDate ?? DateTime.now();
    final base = DateTime(seed.year, seed.month, seed.day, 12);
    _tabController =
        TabController(
          length: CreateEntryTab.values.length,
          vsync: this,
          initialIndex: widget.initialTab.index,
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
    _titleController = TextEditingController();
    _startAt = base;
    _endAt = base.add(const Duration(hours: 1));
    _countdownAt = base;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('保存'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                  children: [
                    const SizedBox(height: 4),
                    _SegmentedTabBar(
                      controller: _tabController,
                      onChanged: (index) {
                        setState(() => _tabController.index = index);
                      },
                    ),
                    const SizedBox(height: 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _activeTab == CreateEntryTab.schedule
                          ? _buildScheduleForm(context)
                          : _buildCountdownForm(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleForm(BuildContext context) {
    return Column(
      key: const ValueKey('schedule-form'),
      children: [
        _FormSection(
          title: null,
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '例如：带 Mochi 晚间遛弯',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: null,
          child: Column(
            children: [
              CompactDateTimeField(
                label: '开始时间',
                value: _startAt,
                showIcons: false,
                onChanged: (value) => setState(() {
                  _startAt = value;
                  if (_endAt.isBefore(_startAt)) {
                    _endAt = _startAt.add(const Duration(hours: 1));
                  }
                }),
              ),
              const SizedBox(height: 12),
              CompactDateTimeField(
                label: '结束时间',
                value: _endAt,
                showIcons: false,
                onChanged: (value) => setState(() {
                  _endAt = value;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: null,
          child: Column(
            children: [
              _SelectionRow<_RepeatOption>(
                label: '重复',
                value: _repeat.label,
                onTap: () => _selectOption<_RepeatOption>(
                  title: '重复',
                  current: _repeat,
                  options: _RepeatOption.values,
                  labelBuilder: (option) => option.label,
                  onSelected: (option) => setState(() => _repeat = option),
                ),
              ),
              const SizedBox(height: 10),
              _SelectionRow<_ReminderOption>(
                label: '提醒',
                value: _scheduleReminder.label,
                onTap: () => _selectOption<_ReminderOption>(
                  title: '提醒',
                  current: _scheduleReminder,
                  options: _ReminderOption.values,
                  labelBuilder: (option) => option.label,
                  onSelected: (option) =>
                      setState(() => _scheduleReminder = option),
                ),
              ),
              const SizedBox(height: 10),
              _SelectionRow<_CalendarOption>(
                label: '分类',
                value: _calendar.label,
                prefix: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _calendar.color,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _selectOption<_CalendarOption>(
                  title: '分类',
                  current: _calendar,
                  options: _CalendarOption.values,
                  labelBuilder: (option) => option.label,
                  onSelected: (option) => setState(() => _calendar = option),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownForm(BuildContext context) {
    return Column(
      key: const ValueKey('countdown-form'),
      children: [
        _FormSection(
          title: null,
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '例如：Mochi 生日 / 年度体检 / 疫苗到期',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: null,
          child: CompactDateTimeField(
            label: '倒计时目标时间',
            value: _countdownAt,
            showIcons: false,
            onChanged: (value) => setState(() {
              _countdownAt = value;
            }),
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: null,
          child: Column(
            children: [
              _SelectionRow<_ReminderOption>(
                label: '提醒',
                value: _countdownReminder.label,
                onTap: () => _selectOption<_ReminderOption>(
                  title: '提醒',
                  current: _countdownReminder,
                  options: _ReminderOption.values,
                  labelBuilder: (option) => option.label,
                  onSelected: (option) =>
                      setState(() => _countdownReminder = option),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '倒计时贴纸',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    _sticker.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _StickerOption.values.map((option) {
                  return _StickerButton(
                    icon: option.icon,
                    selected: option == _sticker,
                    onTap: () => setState(() => _sticker = option),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('请输入标题');
      return;
    }

    if (_activeTab == CreateEntryTab.schedule) {
      if (!_endAt.isAfter(_startAt)) {
        _showMessage('结束时间需要晚于开始时间');
        return;
      }
      final reminders = _scheduleReminder.offsetMinutes == null
          ? const <ReminderPolicy>[]
          : [ReminderPolicy(offsetMinutes: _scheduleReminder.offsetMinutes!)];
      await ref
          .read(appStateProvider.notifier)
          .saveTask(
            title: title,
            description: '',
            startAt: _startAt,
            endAt: _endAt,
            category: _calendar.category,
            petId: ref.read(appStateProvider).selectedPet?.id,
            reminders: reminders,
          );
    } else {
      await ref
          .read(appStateProvider.notifier)
          .saveCountdown(
            CountdownItem(
              id: const Uuid().v4(),
              title: title,
              dueAt: _countdownAt,
              createdAt: DateTime.now(),
              petId: ref.read(appStateProvider).selectedPet?.id,
              isPinned: _sticker == _StickerOption.star,
            ),
          );
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _selectOption<T>({
    required String title,
    required T current,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required ValueChanged<T> onSelected,
  }) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '选择一个最接近当前场景的选项，之后还可以继续改。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                ...options.map((option) {
                  final selected = option == current;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(labelBuilder(option)),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      onSelected(result);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _ReminderOption {
  none('无', null),
  atTime('事件发生时', 0),
  fiveMinutes('5 分钟前', 5),
  fifteenMinutes('15 分钟前', 15),
  thirtyMinutes('30 分钟前', 30),
  oneHour('1 小时前', 60),
  oneDay('1 天前', 1440);

  const _ReminderOption(this.label, this.offsetMinutes);

  final String label;
  final int? offsetMinutes;
}

enum _RepeatOption {
  none('无'),
  everyDay('每天'),
  everyWeek('每周'),
  everyMonth('每月');

  const _RepeatOption(this.label);

  final String label;
}

enum _CalendarOption {
  personal('个人', Color(0xFFE58A5E), CalendarCategory.daily),
  work('工作', Color(0xFF6B7EFF), CalendarCategory.work),
  pet('宠物', Color(0xFF56BFA3), CalendarCategory.pet),
  anniversary('纪念', Color(0xFFF0B24D), CalendarCategory.anniversary);

  const _CalendarOption(this.label, this.color, this.category);

  final String label;
  final Color color;
  final CalendarCategory category;
}

enum _StickerOption {
  stopwatch('效率', Icons.timer_rounded),
  coffee('轻松', Icons.local_cafe_rounded),
  star('置顶', Icons.auto_awesome_rounded),
  cake('庆祝', Icons.cake_rounded);

  const _StickerOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.controller, required this.onChanged});

  final TabController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment<int>(value: 0, label: Text('日程')),
        ButtonSegment<int>(value: 1, label: Text('倒计时')),
      ],
      selected: {controller.index},
      onSelectionChanged: (values) => onChanged(values.first),
      showSelectedIcon: false,
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.child,
  });

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
          ],
          if (title != null) const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectionRow<T> extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.prefix,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerButton extends StatelessWidget {
  const _StickerButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? scheme.primary.withValues(alpha: 0.16)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.28),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.4)
                  : scheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
