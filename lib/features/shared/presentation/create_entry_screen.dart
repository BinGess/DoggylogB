import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  late final TextEditingController _noteController;
  late bool _allDay;
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
    _noteController = TextEditingController();
    _allDay = false;
    _startAt = base;
    _endAt = base.add(const Duration(hours: 1));
    _countdownAt = base;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    Text(
                      _activeTab == CreateEntryTab.schedule ? '添加日程' : '添加倒计时',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _activeTab == CreateEntryTab.schedule
                          ? '把时间、提醒和分类整理成清晰的卡片，避免录入时信息层级混乱。'
                          : '为即将到来的重要时刻建立一个更有仪式感的提醒入口。',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
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
          title: '基本信息',
          subtitle: '先把标题和备注写清楚，后面的提醒和分类会更顺手。',
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
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '补充地点、要带的东西或注意事项',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: '时间安排',
          subtitle: '时间卡片统一使用同一层级，避免之前那种字号和块间距乱跳。',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '全天事项',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Switch(
                    value: _allDay,
                    onChanged: (value) => setState(() => _allDay = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DateTimeTile(
                label: '开始时间',
                dateText: _formatDate(_startAt),
                timeText: _formatTime(_startAt),
                allDay: _allDay,
                onDateTap: () => _pickDate(
                  initial: _startAt,
                  onSelected: (value) => setState(() {
                    _startAt = _mergeDate(_startAt, value);
                    if (_endAt.isBefore(_startAt)) {
                      _endAt = _startAt.add(const Duration(hours: 1));
                    }
                  }),
                ),
                onTimeTap: () => _pickTime(
                  initial: _startAt,
                  onSelected: (value) => setState(() {
                    _startAt = _mergeTime(_startAt, value);
                    if (_endAt.isBefore(_startAt)) {
                      _endAt = _startAt.add(const Duration(hours: 1));
                    }
                  }),
                ),
              ),
              const SizedBox(height: 12),
              _DateTimeTile(
                label: '结束时间',
                dateText: _formatDate(_endAt),
                timeText: _formatTime(_endAt),
                allDay: _allDay,
                onDateTap: () => _pickDate(
                  initial: _endAt,
                  onSelected: (value) => setState(() {
                    _endAt = _mergeDate(_endAt, value);
                  }),
                ),
                onTimeTap: () => _pickTime(
                  initial: _endAt,
                  onSelected: (value) => setState(() {
                    _endAt = _mergeTime(_endAt, value);
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: '规则与分类',
          subtitle: '提醒、重复和日历分类收敛到同一块里，减少界面噪声。',
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
          title: '倒计时标题',
          subtitle: '建议用一个具体的事件名称，避免以后列表里一堆“重要日子”。',
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
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '可选：补充地点、准备事项或需要提醒的人',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: '目标时间',
          subtitle: '保留大号时间按钮，但统一字体和圆角，不再像临时拼出来的卡片。',
          child: Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: _formatDate(_countdownAt),
                  onTap: () => _pickDate(
                    initial: _countdownAt,
                    onSelected: (value) => setState(() {
                      _countdownAt = _mergeDate(_countdownAt, value);
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 108,
                child: _DateChip(
                  label: _formatTime(_countdownAt),
                  onTap: () => _pickTime(
                    initial: _countdownAt,
                    onSelected: (value) => setState(() {
                      _countdownAt = _mergeTime(_countdownAt, value);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: '提醒与风格',
          subtitle: '把提醒方式和展示贴纸收在一起，让这个页面更像一个完整编辑器。',
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
    final note = _noteController.text.trim();
    if (title.isEmpty) {
      _showMessage('请输入标题');
      return;
    }

    if (_activeTab == CreateEntryTab.schedule) {
      final startAt = _allDay
          ? DateTime(_startAt.year, _startAt.month, _startAt.day)
          : _startAt;
      final endAt = _allDay
          ? DateTime(_endAt.year, _endAt.month, _endAt.day, 23, 59)
          : _endAt;
      if (!endAt.isAfter(startAt)) {
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
            description: note,
            startAt: startAt,
            endAt: endAt,
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

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: initial,
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickTime({
    required DateTime initial,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      onSelected(picked);
    }
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

  String _formatDate(DateTime value) {
    return DateFormat('yyyy 年 MM 月 dd 日').format(value);
  }

  String _formatTime(DateTime value) {
    return DateFormat('HH:mm').format(value);
  }

  DateTime _mergeDate(DateTime source, DateTime picked) {
    return DateTime(
      picked.year,
      picked.month,
      picked.day,
      source.hour,
      source.minute,
    );
  }

  DateTime _mergeTime(DateTime source, TimeOfDay picked) {
    return DateTime(
      source.year,
      source.month,
      source.day,
      picked.hour,
      picked.minute,
    );
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
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.dateText,
    required this.timeText,
    required this.allDay,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final String label;
  final String dateText;
  final String timeText;
  final bool allDay;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateChip(label: dateText, onTap: onDateTap),
              ),
              if (!allDay) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: _DateChip(label: timeText, onTap: onTimeTap),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
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
