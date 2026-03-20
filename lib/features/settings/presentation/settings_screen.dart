import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/pets/presentation/pets_screen.dart';
import 'package:doggylog/features/settings/presentation/widgets/language_picker_bottom_sheet.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop_page_header.dart';
import 'package:doggylog/platform/purchases/doggylog_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fontScaleOptions = <({double value})>[
  (value: 1.0),
  (value: 1.1),
  (value: 1.2),
];

class NotificationPermissionSwitchTile extends StatelessWidget {
  const NotificationPermissionSwitchTile({
    super.key,
    required this.isGranted,
    required this.onRequestPermission,
  });

  final bool isGranted;
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.notificationReminders),
      subtitle: Text(
        isGranted
            ? l10n.notificationPermissionGranted
            : l10n.notificationPermissionDenied,
      ),
      value: isGranted,
      onChanged: (value) {
        if (!value) {
          return;
        }
        onRequestPermission();
      },
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final preferences = state.preferences;
    final l10n = context.l10n;
    return Scaffold(
      body: SoftBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              SoftBackdropPageHeader(
                title: l10n.settingsHeaderTitle,
                titleStyle: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                //subtitle: '管理宠物、偏好设置和设备能力。',
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.petsSectionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LiquidGlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.managePetSkins),
                    // subtitle: const Text('进入页面后切换宠物，对应整套 App 皮肤会立即切换'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PetsScreen(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.settingsSectionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LiquidGlassCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.weekStartsOnMonday),
                        value: preferences.weekStartsOnMonday,
                        onChanged: (value) {
                          controller.updatePreferences(
                            preferences.copyWith(weekStartsOnMonday: value),
                          );
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.hapticsFeedback),
                        value: preferences.hapticsEnabled,
                        onChanged: (value) {
                          controller.updatePreferences(
                            preferences.copyWith(hapticsEnabled: value),
                          );
                        },
                      ),
                      NotificationPermissionSwitchTile(
                        isGranted: state.notificationPermissionGranted,
                        onRequestPermission:
                            controller.requestNotificationPermissions,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.biometricUnlock),
                        value: preferences.faceIdEnabled,
                        onChanged: controller.setFaceIdEnabled,
                      ),
                      const Divider(height: 24),
                      ListTile(
                        key: const Key('settings-language-tile'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.language),
                        subtitle: Text(
                          l10n.languageCurrentLabel(preferences.languageMode),
                        ),
                        trailing: _LanguagePreferencePill(
                          label: l10n.languageCurrentLabel(
                            preferences.languageMode,
                          ),
                        ),
                        onTap: () {
                          _showLanguagePicker(context, controller, preferences);
                        },
                      ),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.systemCalendar),
                        subtitle: Text(
                          _systemCalendarSummary(l10n, preferences),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                const SystemCalendarSettingsScreen(),
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.fontSize),
                        subtitle: Text(l10n.fontSizeSubtitle),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _fontScaleOptions.map((option) {
                            return ChoiceChip(
                              label: Text(l10n.fontScaleLabel(option.value)),
                              selected: preferences.fontScale == option.value,
                              onSelected: (_) => controller.updatePreferences(
                                preferences.copyWith(fontScale: option.value),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(height: 24),
                      const _RestorePurchasesAction(),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.developmentDebug),
                        subtitle: Text(l10n.developmentDebugSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DevelopmentDebugScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestorePurchasesAction extends ConsumerStatefulWidget {
  const _RestorePurchasesAction();

  @override
  ConsumerState<_RestorePurchasesAction> createState() =>
      _RestorePurchasesActionState();
}

class _RestorePurchasesActionState
    extends ConsumerState<_RestorePurchasesAction> {
  bool _restoreInFlight = false;

  Future<void> _restorePurchases() async {
    if (_restoreInFlight) {
      return;
    }
    setState(() {
      _restoreInFlight = true;
    });
    final result = await ref.read(purchaseServiceProvider).restorePurchases();
    if (!mounted) {
      return;
    }
    setState(() {
      _restoreInFlight = false;
    });
    final l10n = context.l10n;
    final message = switch (result) {
      RestorePurchasesResult.requested => l10n.messageRestorePurchasesRequested,
      RestorePurchasesResult.unavailable =>
        l10n.messageRestorePurchasesUnavailable,
      RestorePurchasesResult.failed => l10n.messageRestorePurchasesFailed,
    };
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.restorePurchases),
          subtitle: Text(l10n.restorePurchasesSubtitle),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            key: const Key('settings-restore-purchases-tile'),
            onPressed: _restoreInFlight ? null : _restorePurchases,
            icon: _restoreInFlight
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(l10n.restorePurchases),
          ),
        ),
      ],
    );
  }
}

Future<void> _showLanguagePicker(
  BuildContext context,
  AppStateController controller,
  UserPreference preferences,
) async {
  final mode = await showLanguagePickerBottomSheet(
    context,
    selectedMode: preferences.languageMode,
  );
  if (mode == null || mode == preferences.languageMode) {
    return;
  }
  await controller.updatePreferences(preferences.copyWith(languageMode: mode));
}

class _LanguagePreferencePill extends StatelessWidget {
  const _LanguagePreferencePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.tertiary.withValues(alpha: 0.16),
            scheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more_rounded, size: 18, color: scheme.tertiary),
          ],
        ),
      ),
    );
  }
}

String _systemCalendarSummary(
  AppLocalizations l10n,
  UserPreference preferences,
) {
  if (!preferences.useSystemCalendarFilter) {
    return l10n.systemCalendarSummaryAll;
  }
  if (preferences.visibleSystemCalendarIds.isEmpty) {
    return l10n.systemCalendarSummaryNone;
  }
  return l10n.systemCalendarSummarySelected(
    preferences.visibleSystemCalendarIds.length,
  );
}

class SystemCalendarSettingsScreen extends ConsumerStatefulWidget {
  const SystemCalendarSettingsScreen({super.key});

  @override
  ConsumerState<SystemCalendarSettingsScreen> createState() =>
      _SystemCalendarSettingsScreenState();
}

class _SystemCalendarSettingsScreenState
    extends ConsumerState<SystemCalendarSettingsScreen> {
  late Future<List<SystemCalendar>> _calendarsFuture;
  final Set<String> _selectedIds = <String>{};
  bool _hasInitializedSelection = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _calendarsFuture = ref
        .read(appStateProvider.notifier)
        .loadSystemCalendars();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appStateProvider).preferences;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.systemCalendar),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _saveSelection(context),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.done),
          ),
        ],
      ),
      body: SoftBackdrop(
        child: FutureBuilder<List<SystemCalendar>>(
          future: _calendarsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final calendars = snapshot.data ?? const <SystemCalendar>[];
            if (!_hasInitializedSelection) {
              _hasInitializedSelection = true;
              if (preferences.useSystemCalendarFilter) {
                _selectedIds
                  ..clear()
                  ..addAll(preferences.visibleSystemCalendarIds);
              } else {
                _selectedIds
                  ..clear()
                  ..addAll(calendars.map((calendar) => calendar.id));
              }
            }
            if (calendars.isEmpty) {
              return _EmptySystemCalendarState(
                onRetry: () {
                  setState(() {
                    _hasInitializedSelection = false;
                    _calendarsFuture = ref
                        .read(appStateProvider.notifier)
                        .loadSystemCalendars();
                  });
                },
              );
            }
            final grouped = <String, List<SystemCalendar>>{};
            for (final calendar in calendars) {
              grouped.putIfAbsent(calendar.sourceTitle, () => []).add(calendar);
            }
            final groups = grouped.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.systemCalendarGuide,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                LiquidGlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.allCalendars),
                        subtitle: Text(l10n.allCalendarsSubtitle),
                        trailing: Checkbox(
                          value: _selectedIds.length == calendars.length,
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedIds
                                  ..clear()
                                  ..addAll(calendars.map((item) => item.id));
                              } else {
                                _selectedIds.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      group.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  LiquidGlassCard(
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < group.value.length;
                          index++
                        ) ...[
                          _SystemCalendarTile(
                            calendar: group.value[index],
                            selected: _selectedIds.contains(
                              group.value[index].id,
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  _selectedIds.add(group.value[index].id);
                                } else {
                                  _selectedIds.remove(group.value[index].id);
                                }
                              });
                            },
                          ),
                          if (index != group.value.length - 1)
                            const Divider(height: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveSelection(BuildContext context) async {
    final navigator = Navigator.of(context);
    final calendars = await _calendarsFuture;
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(appStateProvider.notifier)
          .updateVisibleSystemCalendars(
            _selectedIds.toList(),
            totalCalendarCount: calendars.length,
          );
      if (!mounted) {
        return;
      }
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SystemCalendarTile extends StatelessWidget {
  const _SystemCalendarTile({
    required this.calendar,
    required this.selected,
    required this.onChanged,
  });

  final SystemCalendar calendar;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = _parseColor(calendar.colorHex);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => onChanged(!selected),
      leading: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: indicatorColor, width: 2),
          color: selected ? indicatorColor : Colors.transparent,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
            : null,
      ),
      title: Text(calendar.title),
      subtitle: calendar.allowsContentModifications
          ? null
          : Text(context.l10n.readOnlyCalendar),
      trailing: Checkbox(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
      ),
    );
  }
}

class _EmptySystemCalendarState extends StatelessWidget {
  const _EmptySystemCalendarState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.emptySystemCalendarsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptySystemCalendarsSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.reload)),
          ],
        ),
      ),
    );
  }
}

Color _parseColor(String colorHex) {
  final normalized = colorHex.replaceFirst('#', '');
  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('ff');
  }
  buffer.write(normalized);
  return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFC7CDD8);
}

class DevelopmentDebugScreen extends ConsumerWidget {
  const DevelopmentDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final preferences = state.preferences;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.developmentDebug)),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.animationIntensity,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.animationIntensitySubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: preferences.animationSpeed,
                    min: 0.7,
                    max: 1.4,
                    divisions: 7,
                    label: preferences.animationSpeed.toStringAsFixed(1),
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(animationSpeed: value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.renderTier,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PerformanceTier.values.map((tier) {
                      return ChoiceChip(
                        label: Text(l10n.performanceTierLabel(tier)),
                        selected: preferences.performanceTier == tier,
                        onSelected: (_) => controller.updatePreferences(
                          preferences.copyWith(performanceTier: tier),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.reminderDebugMode),
                    subtitle: Text(l10n.reminderDebugModeSubtitle),
                    value: preferences.debugImmediateReminders,
                    onChanged: (value) {
                      controller.updatePreferences(
                        preferences.copyWith(debugImmediateReminders: value),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.iosCapabilities,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _CapabilityRow(
                    title: l10n.eventKitSync,
                    subtitle: state.calendarPermissionGranted
                        ? l10n.eventKitGranted
                        : l10n.calendarPermissionDenied,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: controller.importIosCalendarEvents,
                        child: Text(l10n.importSystemCalendar),
                      ),
                      FilledButton.tonal(
                        onPressed: controller.syncAllToIosCalendar,
                        child: Text(l10n.syncToIosCalendar),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: l10n.notificationReminders,
                    subtitle: state.notificationPermissionGranted
                        ? l10n.notificationPermissionGranted
                        : l10n.notificationPermissionDenied,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: controller.requestNotificationPermissions,
                    child: Text(l10n.enableNotificationPermission),
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: l10n.geofenceWalkingMode,
                    subtitle: state.locationPermissionGranted
                        ? state.activeGeofenceName == null
                              ? l10n.geofenceInactive
                              : l10n.geofenceActive(
                                  state.activeGeofenceName!,
                                  state.activeScene,
                                )
                        : l10n.locationPermissionDenied,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: controller.enableGeofenceMonitoring,
                    child: Text(
                      state.locationPermissionGranted
                          ? l10n.refreshGeofenceStatus
                          : l10n.enableLocationPermission,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: l10n.coreMotionParallax,
                    subtitle: state.sensorStreamActive
                        ? l10n.sensorStreamEnabled
                        : l10n.sensorStreamDisabled,
                  ),
                  if (state.lastSyncMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      state.lastSyncMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _CapabilityRow(
                    title: l10n.cloudkitBackupRestore,
                    subtitle: l10n.cloudkitBackupRestoreSubtitle,
                  ),
                  _CapabilityRow(
                    title: l10n.widgetDynamicIsland,
                    subtitle: l10n.widgetDynamicIslandSubtitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
