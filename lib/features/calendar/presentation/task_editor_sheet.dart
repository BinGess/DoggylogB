import 'package:collection/collection.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/compact_date_time_field.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const _reminderOptions = [5, 15, 30, 60];

  late final TextEditingController _titleController;
  late DateTime _startAt;
  late DateTime _endAt;
  late CalendarCategory _category;
  late int _selectedOffset;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final draft = widget.draft;
    _titleController = TextEditingController(
      text: item?.title ?? draft?.title ?? '',
    );
    _startAt = item?.startAt ?? draft?.startAt ?? DateTime.now();
    _endAt =
        item?.endAt ??
        draft?.endAt ??
        DateTime.now().add(const Duration(minutes: 30));
    _category = item?.category ?? draft?.category ?? CalendarCategory.pet;
    final itemOffsets = item?.reminders.map(
      (reminder) => reminder.offsetMinutes,
    );
    _selectedOffset = itemOffsets?.firstOrNull ?? 15;
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 16),
              CompactDateTimeField(
                label: '开始时间',
                value: _startAt,
                datePattern: 'yyyy/MM/dd',
                showIcons: false,
                onChanged: (value) => setState(() {
                  _startAt = value;
                  if (_endAt.isBefore(_startAt)) {
                    _endAt = _startAt.add(const Duration(minutes: 30));
                  }
                }),
              ),
              const SizedBox(height: 12),
              CompactDateTimeField(
                label: '结束时间',
                value: _endAt,
                datePattern: 'yyyy/MM/dd',
                showIcons: false,
                onChanged: (value) => setState(() => _endAt = value),
              ),
              const SizedBox(height: 16),
              Text('提醒时间', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _selectedOffset,
                items: _reminderOptions
                    .map(
                      (offset) => DropdownMenuItem<int>(
                        value: offset,
                        child: Text('$offset 分钟前'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedOffset = value);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (widget.item != null) ...[
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(appStateProvider.notifier)
                            .deleteTask(widget.item!.id);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Text('删除'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final reminders = [
                          ReminderPolicy(offsetMinutes: _selectedOffset),
                        ];
                        await ref
                            .read(appStateProvider.notifier)
                            .saveTask(
                              id: widget.item?.id,
                              title: _titleController.text.trim(),
                              description: '',
                              startAt: _startAt,
                              endAt: _endAt,
                              category: _category,
                              petId: null,
                              reminders: reminders,
                            );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Text('保存日程'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
