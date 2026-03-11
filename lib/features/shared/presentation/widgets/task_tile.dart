import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  final CalendarItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(item.id),
      background: _swipeAction(
        context,
        Icons.check_circle_rounded,
        context.l10n.complete,
        scheme.primary,
      ),
      secondaryBackground: _swipeAction(
        context,
        Icons.delete_rounded,
        context.l10n.delete,
        Colors.redAccent,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle(!item.isCompleted);
          return false;
        }
        onDelete();
        return false;
      },
      child: LiquidGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: item.isCompleted,
              onChanged: (value) => onToggle(value ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('MM/dd HH:mm', context.l10n.localeName).format(item.startAt)} - ${DateFormat('HH:mm', context.l10n.localeName).format(item.endAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CategoryBadge(category: item.category),
          ],
        ),
      ),
    );
  }

  Widget _swipeAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final CalendarCategory category;

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      CalendarCategory.daily => const Color(0xFFCE8B48),
      CalendarCategory.work => const Color(0xFF667085),
      CalendarCategory.anniversary => const Color(0xFFE56B8B),
      CalendarCategory.pet => const Color(0xFFF1C453),
    };
    final icon = switch (category) {
      CalendarCategory.daily => Icons.bakery_dining_rounded,
      CalendarCategory.work => Icons.work_rounded,
      CalendarCategory.anniversary => Icons.favorite_rounded,
      CalendarCategory.pet => Icons.pets_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(-3, -3),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            context.l10n.categoryLabel(category),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
