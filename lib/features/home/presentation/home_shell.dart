import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:doggylog/features/countdown/presentation/countdown_screen.dart';
import 'package:doggylog/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeShellTabIndexProvider = StateProvider<int>((ref) => 1);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _pages = [CountdownScreen(), CalendarScreen(), SettingsScreen()];
  static const _navRadius = 24.0;
  static const _navHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeShellTabIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_navRadius),
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
            borderRadius: BorderRadius.circular(_navRadius),
            child: NavigationBar(
              height: _navHeight,
              selectedIndex: index,
              onDestinationSelected: (value) {
                ref.read(homeShellTabIndexProvider.notifier).state = value;
              },
              indicatorColor: scheme.primary.withValues(alpha: 0.18),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timelapse_rounded),
                  label: '倒计时',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: '日历',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
