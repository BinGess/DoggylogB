import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeShellTabIndexProvider = StateProvider<int>((ref) => 1);

int? homeShellTabIndexForId(String? tabId) {
  switch (tabId) {
    case 'countdown':
      return 0;
    case 'calendar':
      return 1;
    case 'settings':
      return 2;
    default:
      return null;
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.initialTabId});

  final String? initialTabId;
  static const pages = [
    CountdownScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];
  static const navRadius = 26.0;
  static const navHeight = 64.0;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    _syncInitialTab();
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabId != widget.initialTabId) {
      _syncInitialTab();
    }
  }

  void _syncInitialTab() {
    final targetIndex = homeShellTabIndexForId(widget.initialTabId);
    if (targetIndex == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(homeShellTabIndexProvider.notifier).state = targetIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeShellTabIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: HomeShell.pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeShell.navRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? const Color(0xFF1E2834) : const Color(0xFFFBFDFF))
                    .withValues(alpha: 0.96),
                (isDark ? const Color(0xFF16202A) : const Color(0xFFF0F4FA))
                    .withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: isDark
                  ? scheme.outline.withValues(alpha: 0.38)
                  : Colors.white.withValues(alpha: 0.82),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFFB7C4D4).withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(8, 10),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.72),
                blurRadius: 14,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HomeShell.navRadius),
            child: _HomeBottomTabBar(
              selectedIndex: index,
              onSelected: (value) {
                ref.read(homeShellTabIndexProvider.notifier).state = value;
              },
              scheme: scheme,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomTabBar extends StatelessWidget {
  const _HomeBottomTabBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.scheme,
    required this.isDark,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ColorScheme scheme;
  final bool isDark;

  static const _items = <({IconData icon, String label, String keyId})>[
    (icon: Icons.timelapse_rounded, label: '倒计时', keyId: 'countdown'),
    (icon: Icons.calendar_month_rounded, label: '日历', keyId: 'calendar'),
    (icon: Icons.person_rounded, label: '我的', keyId: 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = scheme.primary;
    final unselectedColor = scheme.onSurfaceVariant;
    final selectedTextStyle = theme.textTheme.labelMedium?.copyWith(
      color: scheme.onSurface,
    );
    final unselectedTextStyle = theme.textTheme.labelMedium?.copyWith(
      color: unselectedColor,
    );

    return SizedBox(
      key: const Key('home-bottom-tab-bar'),
      height: HomeShell.navHeight,
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: _HomeTabItem(
                icon: _items[i].icon,
                label: _items[i].label,
                keyId: _items[i].keyId,
                selected: i == selectedIndex,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                selectedTextStyle: selectedTextStyle,
                unselectedTextStyle: unselectedTextStyle,
                isDark: isDark,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeTabItem extends StatelessWidget {
  const _HomeTabItem({
    required this.icon,
    required this.label,
    required this.keyId,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedTextStyle,
    required this.unselectedTextStyle,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String keyId;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: selected
                    ? selectedColor.withValues(alpha: isDark ? 0.18 : 0.14)
                    : Colors.transparent,
              ),
              child: Column(
                key: selected ? Key('home-tab-$keyId-selected') : null,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: selected ? selectedTextStyle : unselectedTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
