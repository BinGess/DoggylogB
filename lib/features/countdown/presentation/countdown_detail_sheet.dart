import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/compact_date_time_field.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showCountdownDetailSheet(
  BuildContext context,
  WidgetRef ref, {
  required CountdownItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => CountdownDetailSheet(item: item),
  );
}

class CountdownDetailSheet extends ConsumerStatefulWidget {
  const CountdownDetailSheet({super.key, required this.item});

  final CountdownItem item;

  @override
  ConsumerState<CountdownDetailSheet> createState() =>
      _CountdownDetailSheetState();
}

class _CountdownDetailSheetState extends ConsumerState<CountdownDetailSheet> {
  late final TextEditingController _titleController;
  late DateTime _dueAt;
  late bool _isPinned;
  late bool _hasCelebrated;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _dueAt = widget.item.dueAt;
    _isPinned = widget.item.isPinned;
    _hasCelebrated = widget.item.hasCelebrated;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remainingDays = _dueAt.difference(now).inHours / 24;

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
              Text('倒计时详情', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题'),
              ),
              const SizedBox(height: 12),
              CompactDateTimeField(
                label: '目标时间',
                value: _dueAt,
                datePattern: 'yyyy/MM/dd',
                showIcons: false,
                onChanged: (value) => setState(() => _dueAt = value),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _CountdownMetaChip(
                      label: '剩余',
                      value: _hasCelebrated
                          ? '已完成'
                          : '${remainingDays.ceil().clamp(0, 999)} 天',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CountdownMetaChip(
                      label: '创建于',
                      value: DateFormat('M月d日').format(widget.item.createdAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('置顶倒计时'),
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_hasCelebrated ? '已完成倒计时' : '完成倒计时'),
                value: _hasCelebrated,
                onChanged: (value) => setState(() => _hasCelebrated = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(appStateProvider.notifier)
                          .deleteCountdown(widget.item.id);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('删除'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final title = _titleController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入标题')),
                          );
                          return;
                        }
                        await ref
                            .read(appStateProvider.notifier)
                            .saveCountdown(
                              widget.item.copyWith(
                                title: title,
                                dueAt: _dueAt,
                                isPinned: _isPinned,
                                hasCelebrated: _hasCelebrated,
                              ),
                            );
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('保存倒计时'),
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

class _CountdownMetaChip extends StatelessWidget {
  const _CountdownMetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
