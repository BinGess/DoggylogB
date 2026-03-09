import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompactDateTimeField extends StatelessWidget {
  const CompactDateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showTime = true,
    this.firstDate,
    this.lastDate,
    this.datePattern = 'yyyy 年 MM 月 dd 日',
    this.dateChipWidth,
    this.timeChipWidth = 96,
    this.showIcons = true,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool showTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String datePattern;
  final double? dateChipWidth;
  final double timeChipWidth;
  final bool showIcons;

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
                child: SizedBox(
                  width: dateChipWidth,
                  child: _PickerChip(
                    label: DateFormat(datePattern).format(value),
                    icon: showIcons ? Icons.calendar_today_rounded : null,
                    onTap: () => _pickDate(context),
                  ),
                ),
              ),
              if (showTime) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: timeChipWidth,
                  child: _PickerChip(
                    label: DateFormat('HH:mm').format(value),
                    icon: showIcons ? Icons.schedule_rounded : null,
                    onTap: () => _pickTime(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showCompactDatePickerSheet(
      context,
      initialDate: value,
      firstDate:
          firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) {
      return;
    }
    onChanged(
      DateTime(picked.year, picked.month, picked.day, value.hour, value.minute),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showCompactTimePickerSheet(
      context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked == null) {
      return;
    }
    onChanged(
      DateTime(
        value.year,
        value.month,
        value.day,
        picked.hour,
        picked.minute,
      ),
    );
  }
}

Future<DateTime?> showCompactDatePickerSheet(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      var selected = initialDate;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.78,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '选择日期',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(DateTime.now()),
                            child: const Text('今天'),
                          ),
                        ],
                      ),
                      Text(
                        '直接点选日期即可，流程比系统双弹窗更短。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        currentDate: DateTime.now(),
                        onDateChanged: (value) =>
                            setState(() => selected = value),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(selected),
                          child: const Text('完成'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<TimeOfDay?> showCompactTimePickerSheet(
  BuildContext context, {
  required TimeOfDay initialTime,
}) async {
  final result = await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      var selected = DateTime(
        2026,
        1,
        1,
        initialTime.hour,
        initialTime.minute,
      );
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.66,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择时间',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '滚轮选择更适合单手快速调整小时和分钟。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: selected,
                        onDateTimeChanged: (value) => setState(() {
                          selected = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(selected),
                        child: const Text('完成'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  if (result == null) {
    return null;
  }
  return TimeOfDay(hour: result.hour, minute: result.minute);
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
