import 'package:doggylog/app/localization/app_localizations.dart';
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
    final l10n = context.l10n;
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
                      label: Text(l10n.save),
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
    final l10n = context.l10n;
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
                decoration: InputDecoration(
                  labelText: l10n.titleLabel,
                  hintText: l10n.titleHintSchedule,
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
                label: l10n.startTime,
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
                label: l10n.endTime,
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
                label: l10n.repeat,
                value: _repeat.label(l10n),
                onTap: () => _selectOption<_RepeatOption>(
                  title: l10n.repeat,
                  current: _repeat,
                  options: _RepeatOption.values,
                  labelBuilder: (option) => option.label(l10n),
                  onSelected: (option) => setState(() => _repeat = option),
                ),
              ),
              const SizedBox(height: 10),
              _SelectionRow<_ReminderOption>(
                label: l10n.reminder,
                value: _scheduleReminder.label(l10n),
                onTap: () => _selectOption<_ReminderOption>(
                  title: l10n.reminder,
                  current: _scheduleReminder,
                  options: _ReminderOption.values,
                  labelBuilder: (option) => option.label(l10n),
                  onSelected: (option) =>
                      setState(() => _scheduleReminder = option),
                ),
              ),
              const SizedBox(height: 10),
              _SelectionRow<_CalendarOption>(
                label: l10n.category,
                value: _calendar.label(l10n),
                prefix: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _calendar.color,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _selectOption<_CalendarOption>(
                  title: l10n.category,
                  current: _calendar,
                  options: _CalendarOption.values,
                  labelBuilder: (option) => option.label(l10n),
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
    final l10n = context.l10n;
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
                decoration: InputDecoration(
                  labelText: l10n.titleLabel,
                  hintText: l10n.titleHintCountdown,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FormSection(
          title: null,
          child: CompactDateTimeField(
            label: l10n.countdownTargetTime,
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
                label: l10n.reminder,
                value: _countdownReminder.label(l10n),
                onTap: () => _selectOption<_ReminderOption>(
                  title: l10n.reminder,
                  current: _countdownReminder,
                  options: _ReminderOption.values,
                  labelBuilder: (option) => option.label(l10n),
                  onSelected: (option) =>
                      setState(() => _countdownReminder = option),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.countdownSticker,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    _sticker.label(l10n),
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
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage(l10n.enterTitle);
      return;
    }

    if (_activeTab == CreateEntryTab.schedule) {
      if (!_endAt.isAfter(_startAt)) {
        _showMessage(l10n.endTimeAfterStart);
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
                  context.l10n.chooseBestOption,
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
  none(null),
  atTime(0),
  fiveMinutes(5),
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60),
  oneDay(1440);

  const _ReminderOption(this.offsetMinutes);

  final int? offsetMinutes;

  String label(AppLocalizations l10n) => switch (this) {
    _ReminderOption.none => l10n.none,
    _ReminderOption.atTime => l10n.atTime,
    _ReminderOption.fiveMinutes => l10n.minutesBefore(5),
    _ReminderOption.fifteenMinutes => l10n.minutesBefore(15),
    _ReminderOption.thirtyMinutes => l10n.minutesBefore(30),
    _ReminderOption.oneHour => l10n.hoursBefore(1),
    _ReminderOption.oneDay => l10n.daysBefore(1),
  };
}

enum _RepeatOption {
  none,
  everyDay,
  everyWeek,
  everyMonth;

  String label(AppLocalizations l10n) => switch (this) {
    _RepeatOption.none => l10n.none,
    _RepeatOption.everyDay => l10n.everyDay,
    _RepeatOption.everyWeek => l10n.everyWeek,
    _RepeatOption.everyMonth => l10n.everyMonth,
  };
}

enum _CalendarOption {
  personal(Color(0xFFE58A5E), CalendarCategory.daily),
  work(Color(0xFF6B7EFF), CalendarCategory.work),
  pet(Color(0xFF56BFA3), CalendarCategory.pet),
  anniversary(Color(0xFFF0B24D), CalendarCategory.anniversary);

  const _CalendarOption(this.color, this.category);

  final Color color;
  final CalendarCategory category;

  String label(AppLocalizations l10n) => switch (this) {
    _CalendarOption.personal => l10n.personalCategory,
    _CalendarOption.work => l10n.workCategoryShort,
    _CalendarOption.pet => l10n.petCategoryShort,
    _CalendarOption.anniversary => l10n.anniversaryCategoryShort,
  };
}

enum _StickerOption {
  stopwatch(Icons.timer_rounded),
  coffee(Icons.local_cafe_rounded),
  star(Icons.auto_awesome_rounded),
  cake(Icons.cake_rounded);

  const _StickerOption(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    _StickerOption.stopwatch => l10n.stickerEfficiency,
    _StickerOption.coffee => l10n.stickerRelaxed,
    _StickerOption.star => l10n.stickerPinned,
    _StickerOption.cake => l10n.stickerCelebrate,
  };
}

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.controller, required this.onChanged});

  final TabController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: [
        ButtonSegment<int>(value: 0, label: Text(context.l10n.scheduleTab)),
        ButtonSegment<int>(value: 1, label: Text(context.l10n.countdownTab)),
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
