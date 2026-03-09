import 'package:doggylog/features/calendar/presentation/task_editor_sheet.dart';
import 'package:doggylog/features/pets/presentation/pets_screen.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/create_entry_screen.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _selectedPawAsset = 'assets/images/calendar/paw_badge_selected.png';
const _idlePawAsset = 'assets/images/calendar/paw_stamp_idle.png';
const _timelineDogAsset = 'assets/images/calendar/calendar_dog_timeline.png';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _calendarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final selectedItems = sortAgendaItemsByReminderTime(_selectedItems(state));

    return Scaffold(
      body: SoftBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              _CalendarHeader(
                monthLabel: DateFormat('yyyy年MM月').format(state.selectedDate),
                pet: state.selectedPet,
                onPickMonth: () => _pickMonth(context, controller, state),
                onPetTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PetsScreen()),
                ),
                onAddTap: () => showCreateEntryScreen(
                  context,
                  initialDate: state.selectedDate,
                ),
              ),
              const SizedBox(height: 28),
              _CalendarDeck(
                expanded: _calendarExpanded,
                state: state,
                onSelectDate: controller.selectDate,
                onToggleExpanded: _toggleCalendarExpanded,
                onDragToggle: _handleCalendarDrag,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat(
                        'M月d日 EEEE',
                        'zh_CN',
                      ).format(state.selectedDate),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.selectDate(DateTime.now()),
                    child: const Text('今天'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (selectedItems.isEmpty)
                const _EmptyAgenda()
              else
                ...selectedItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AgendaItemRow(
                      item: item,
                      onToggle: (value) =>
                          controller.toggleTaskCompletion(item.id, value),
                      onDelete: () => controller.deleteTask(item.id),
                      onTap: () =>
                          showTaskEditorSheet(context, ref, item: item),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  List<CalendarItem> _selectedItems(AppState state) {
    return state.calendarItems
        .where((item) => _sameDay(item.startAt, state.selectedDate))
        .toList();
  }

  Future<void> _pickMonth(
    BuildContext context,
    AppStateController controller,
    AppState state,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: state.selectedDate,
    );
    if (picked == null) {
      return;
    }
    controller.selectDate(picked);
  }

  void _handleCalendarDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 180 && !_calendarExpanded) {
      setState(() => _calendarExpanded = true);
      return;
    }
    if (velocity < -180 && _calendarExpanded) {
      setState(() => _calendarExpanded = false);
    }
  }

  void _toggleCalendarExpanded() {
    setState(() => _calendarExpanded = !_calendarExpanded);
  }
}

List<CalendarItem> sortAgendaItemsByReminderTime(List<CalendarItem> items) {
  return [...items]..sort(
    (a, b) => _reminderTriggerAt(b).compareTo(_reminderTriggerAt(a)),
  );
}

DateTime _reminderTriggerAt(CalendarItem item) {
  if (item.reminders.isEmpty) {
    return item.startAt;
  }
  return item.reminders
      .map((reminder) => item.startAt.subtract(Duration(minutes: reminder.offsetMinutes)))
      .reduce((current, next) => current.isBefore(next) ? current : next);
}

class _CalendarDeck extends StatelessWidget {
  const _CalendarDeck({
    required this.expanded,
    required this.state,
    required this.onSelectDate,
    required this.onToggleExpanded,
    required this.onDragToggle,
  });

  final bool expanded;
  final AppState state;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onToggleExpanded;
  final GestureDragEndCallback onDragToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: onDragToggle,
      child: Column(
        children: [
          _WeekdayHeader(
            weekStartsOnMonday: state.preferences.weekStartsOnMonday,
          ),
          const SizedBox(height: 20),
          AnimatedCrossFade(
            firstChild: RepaintBoundary(
              child: _CompactWeekView(
                key: const ValueKey('compact-week'),
                state: state,
                onSelectDate: onSelectDate,
                selectedPet: state.selectedPet,
              ),
            ),
            secondChild: RepaintBoundary(
              child: _MonthView(
                key: const ValueKey('expanded-month'),
                state: state,
                onSelectDate: onSelectDate,
                selectedPet: state.selectedPet,
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            excludeBottomFocus: true,
          ),
          const SizedBox(height: 24),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onToggleExpanded,
              child: Container(
                width: 52,
                height: 18,
                alignment: Alignment.center,
                child: Container(
                  width: 52,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expanded ? '上滑收起月历' : '下拉展开月历',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.34),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.monthLabel,
    required this.pet,
    required this.onPickMonth,
    required this.onPetTap,
    required this.onAddTap,
  });

  final String monthLabel;
  final PetProfile? pet;
  final VoidCallback onPickMonth;
  final VoidCallback onPetTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPickMonth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      monthLabel,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down_rounded, size: 26),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _SoftCircleButton(
          onTap: onPetTap,
          child: _PetGlyph(breed: pet?.breed),
        ),
        const SizedBox(width: 12),
        _SoftCircleButton(
          onTap: onAddTap,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.weekStartsOnMonday});

  final bool weekStartsOnMonday;

  @override
  Widget build(BuildContext context) {
    final labels = weekStartsOnMonday
        ? const ['一', '二', '三', '四', '五', '六', '日']
        : const ['日', '一', '二', '三', '四', '五', '六'];

    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    super.key,
    required this.state,
    required this.onSelectDate,
    required this.selectedPet,
  });

  final AppState state;
  final ValueChanged<DateTime> onSelectDate;
  final PetProfile? selectedPet;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      1,
    );
    final offset = state.preferences.weekStartsOnMonday
        ? first.weekday - 1
        : first.weekday % 7;
    final start = first.subtract(Duration(days: offset));
    final days = List.generate(42, (index) => start.add(Duration(days: index)));
    final scheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 14,
        crossAxisSpacing: 4,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final date = days[index];
        final selected = _sameDay(date, state.selectedDate);
        final inMonth = date.month == state.selectedDate.month;
        final isToday = _sameDay(date, now);
        final dayItems = state.calendarItems
            .where((item) => _sameDay(item.startAt, date))
            .toList();
        final hasPetTask = dayItems.any(
          (item) => item.category == CalendarCategory.pet,
        );

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelectDate(date),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? scheme.primary.withValues(alpha: 0.16)
                          : Colors.transparent,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(-4, -4),
                              ),
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.16),
                                blurRadius: 16,
                                offset: const Offset(4, 8),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: selected || isToday
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: inMonth
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (dayItems.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dayItems.length.clamp(0, 2), (_) {
                        return Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                ],
              ),
              if (selected && selectedPet != null)
                Positioned(
                  left: -2,
                  top: 16,
                  child: _CalendarPetMarker(breed: selectedPet!.breed),
                )
              else if (hasPetTask)
                Positioned(
                  right: 8,
                  bottom: 22,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets_rounded,
                      size: 10,
                      color: scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactWeekView extends StatelessWidget {
  const _CompactWeekView({
    super.key,
    required this.state,
    required this.onSelectDate,
    required this.selectedPet,
  });

  final AppState state;
  final ValueChanged<DateTime> onSelectDate;
  final PetProfile? selectedPet;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weekDates = _weekDates(
      state.selectedDate,
      state.preferences.weekStartsOnMonday,
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weekDates.map((date) {
            final selected = _sameDay(date, state.selectedDate);
            final inMonth = date.month == state.selectedDate.month;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelectDate(date),
                child: Column(
                  children: [
                    SizedBox(
                      height: 58,
                      child: selected
                          ? _PawBadge(day: date.day)
                          : Center(
                              child: Text(
                                '${date.day}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: inMonth
                                          ? scheme.onSurface.withValues(
                                              alpha: 0.72,
                                            )
                                          : scheme.onSurface.withValues(
                                              alpha: 0.22,
                                            ),
                                    ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: selected && selectedPet != null
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: _TimelinePetIllustration(
                                breed: selectedPet!.breed,
                                width: 56,
                                height: 46,
                              ),
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _PawStamp(
                                  size: 18,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.06,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AgendaItemRow extends StatelessWidget {
  const _AgendaItemRow({
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
    final accent = switch (item.category) {
      CalendarCategory.daily => const Color(0xFFE49583),
      CalendarCategory.work => const Color(0xFF7A8CA5),
      CalendarCategory.anniversary => const Color(0xFFEB8CA2),
      CalendarCategory.pet => const Color(0xFFE0A54D),
    };

    return Dismissible(
      key: ValueKey(item.id),
      background: _agendaAction(
        context,
        icon: Icons.check_rounded,
        label: item.isCompleted ? '恢复' : '完成',
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _agendaAction(
        context,
        icon: Icons.delete_outline_rounded,
        label: '删除',
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle(!item.isCompleted);
          return false;
        }
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: _softDecoration(context, radius: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onToggle(!item.isCompleted),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(
                        alpha: item.isCompleted ? 0.2 : 0.14,
                      ),
                    ),
                    child: Icon(
                      _categoryIcon(item.category),
                      size: 16,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.isCompleted
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.42)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('HH:mm').format(item.startAt),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _agendaAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Alignment alignment,
  }) {
    final padding = alignment == Alignment.centerLeft
        ? const EdgeInsets.only(left: 22)
        : const EdgeInsets.only(right: 22);
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ] else ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: _softDecoration(context, radius: 24),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.pets_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '今天还没有安排，点右上角加号创建第一件事。',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircleButton extends StatelessWidget {
  const _SoftCircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: _softDecoration(
            context,
            radius: 999,
            fillColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.86),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _PetGlyph extends StatelessWidget {
  const _PetGlyph({required this.breed});

  final PetBreed? breed;

  @override
  Widget build(BuildContext context) {
    final background = switch (breed) {
      PetBreed.husky => const Color(0xFF344E77),
      PetBreed.goldenRetriever => const Color(0xFFB8843B),
      PetBreed.beagle => const Color(0xFF8D6A56),
      PetBreed.shiba || null => const Color(0xFF2E3036),
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: const Icon(Icons.pets_rounded, size: 18, color: Colors.white),
    );
  }
}

class _PawBadge extends StatelessWidget {
  const _PawBadge({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            _selectedPawAsset,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          Positioned(
            top: 20,
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PawStamp extends StatelessWidget {
  const _PawStamp({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.18,
      height: size,
      child: IgnorePointer(
        child: Image.asset(
          _idlePawAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }
}

class _CalendarPetMarker extends StatelessWidget {
  const _CalendarPetMarker({required this.breed});

  final PetBreed breed;

  @override
  Widget build(BuildContext context) {
    final background = switch (breed) {
      PetBreed.husky => const Color(0xFF45648F),
      PetBreed.goldenRetriever => const Color(0xFFD39C42),
      PetBreed.beagle => const Color(0xFFA27757),
      PetBreed.shiba => const Color(0xFF32343B),
    };
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.pets_rounded, size: 15, color: Colors.white),
    );
  }
}

class _TimelinePetIllustration extends StatelessWidget {
  const _TimelinePetIllustration({
    required this.breed,
    required this.width,
    required this.height,
  });

  final PetBreed breed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: IgnorePointer(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: width,
            height: height,
            child: Image.asset(
              _timelineDogAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

List<DateTime> _weekDates(DateTime selectedDate, bool weekStartsOnMonday) {
  final weekdayOffset = weekStartsOnMonday
      ? selectedDate.weekday - 1
      : selectedDate.weekday % 7;
  final start = selectedDate.subtract(Duration(days: weekdayOffset));
  return List.generate(7, (index) => start.add(Duration(days: index)));
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

IconData _categoryIcon(CalendarCategory category) {
  return switch (category) {
    CalendarCategory.daily => Icons.wb_sunny_outlined,
    CalendarCategory.work => Icons.work_outline_rounded,
    CalendarCategory.anniversary => Icons.cake_outlined,
    CalendarCategory.pet => Icons.pets_rounded,
  };
}

BoxDecoration _softDecoration(
  BuildContext context, {
  required double radius,
  Color? fillColor,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final background =
      fillColor ??
      (isDark
          ? const Color(0xFF202835).withValues(alpha: 0.9)
          : const Color(0xFFF1F3F6).withValues(alpha: 0.96));

  return BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.7),
    ),
    boxShadow: [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.24)
            : const Color(0xFFD3D7DD).withValues(alpha: 0.82),
        blurRadius: 18,
        offset: const Offset(8, 10),
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.95),
        blurRadius: 16,
        offset: const Offset(-8, -8),
      ),
    ],
  );
}
