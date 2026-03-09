import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:doggylog/features/stats/presentation/stats_screen.dart';
import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    CalendarScreen(),
    CountdownScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? const Color(0xFF202A38) : const Color(0xFFF9FBFF))
                    .withValues(alpha: 0.96),
                (isDark ? const Color(0xFF151D28) : const Color(0xFFE8EEF7))
                    .withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.34)
                    : const Color(0xFFBBC7D7).withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(14, 14),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.9),
                blurRadius: 20,
                offset: const Offset(-10, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              indicatorColor: scheme.primary.withValues(alpha: 0.18),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: '日历',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timelapse_rounded),
                  label: '倒计时',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: '复盘',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: '设置',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
