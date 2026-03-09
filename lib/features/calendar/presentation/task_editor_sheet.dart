import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showTaskEditorSheet(
  BuildContext context,
  WidgetRef ref, {
  CalendarItem? item,
  QuickEntryDraft? draft,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => TaskEditorSheet(item: item, draft: draft),
  );
}

class TaskEditorSheet extends ConsumerStatefulWidget {
  const TaskEditorSheet({super.key, this.item, this.draft});

  final CalendarItem? item;
  final QuickEntryDraft? draft;

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startAt;
  late DateTime _endAt;
  late CalendarCategory _category;
  late String? _petId;
  final List<int> _offsets = [15];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final draft = widget.draft;
    _titleController = TextEditingController(
      text: item?.title ?? draft?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _startAt = item?.startAt ?? draft?.startAt ?? DateTime.now();
    _endAt =
        item?.endAt ??
        draft?.endAt ??
        DateTime.now().add(const Duration(minutes: 30));
    _category = item?.category ?? draft?.category ?? CalendarCategory.pet;
    _petId = item?.petId ?? draft?.petId;
    final itemOffsets = item?.reminders.map(
      (reminder) => reminder.offsetMinutes,
    );
    if (itemOffsets != null && itemOffsets.isNotEmpty) {
      _offsets
        ..clear()
        ..addAll(itemOffsets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final pets = state.pets;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: LiquidGlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item == null ? '新建日程' : '编辑日程',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '备注'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CalendarCategory.values.map((category) {
                  return ChoiceChip(
                    label: Text(category.label),
                    selected: category == _category,
                    onSelected: (_) => setState(() => _category = category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _petId,
                decoration: const InputDecoration(labelText: '关联宠物'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('不关联'),
                  ),
                  ...pets.map(
                    (pet) => DropdownMenuItem<String?>(
                      value: pet.id,
                      child: Text(pet.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _petId = value),
              ),
              const SizedBox(height: 16),
              _DateTile(
                label: '开始时间',
                value: _startAt,
                onChanged: (value) => setState(() {
                  _startAt = value;
                  if (_endAt.isBefore(_startAt)) {
                    _endAt = _startAt.add(const Duration(minutes: 30));
                  }
                }),
              ),
              const SizedBox(height: 12),
              _DateTile(
                label: '结束时间',
                value: _endAt,
                onChanged: (value) => setState(() => _endAt = value),
              ),
              const SizedBox(height: 16),
              Text('提醒时间', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 15, 30, 60].map((offset) {
                  final selected = _offsets.contains(offset);
                  return FilterChip(
                    label: Text('$offset 分钟前'),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _offsets.add(offset);
                        } else {
                          _offsets.remove(offset);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final reminders = _offsets
                      .map((offset) => ReminderPolicy(offsetMinutes: offset))
                      .toList();
                  await ref
                      .read(appStateProvider.notifier)
                      .saveTask(
                        id: widget.item?.id,
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        startAt: _startAt,
                        endAt: _endAt,
                        category: _category,
                        petId: _petId,
                        reminders: reminders,
                      );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('保存日程'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(label),
      subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(value)),
      trailing: const Icon(Icons.edit_calendar_rounded),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
          initialDate: value,
        );
        if (date == null || !context.mounted) {
          return;
        }
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null) {
          return;
        }
        onChanged(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      },
    );
  }
}
