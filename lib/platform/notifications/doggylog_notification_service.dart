import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

bool shouldFireDebugReminderPreview({
  required bool debugImmediateReminders,
  required CalendarItem item,
}) {
  return debugImmediateReminders &&
      item.reminders.isNotEmpty &&
      !item.isDeleted &&
      !item.isCompleted;
}

class DoggylogNotificationService {
  DoggylogNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(initializationSettings);
    await _configureTimezone();
    await _createAndroidChannel();
  }

  Future<bool> requestPermissions() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
    await android?.requestNotificationsPermission();
    return iosGranted;
  }

  Future<void> syncTaskReminders(Iterable<CalendarItem> items) async {
    final pending = await _plugin.pendingNotificationRequests();
    final activeIds = pending
        .where((item) => item.payload?.startsWith('task:') ?? false)
        .map((item) => item.id)
        .toSet();
    final expectedIds = <int>{};
    for (final item in items) {
      expectedIds.addAll(_idsForTask(item.id, item.reminders));
      await scheduleTask(item);
    }
    for (final id in activeIds.difference(expectedIds)) {
      await _plugin.cancel(id);
    }
  }

  Future<void> scheduleTask(
    CalendarItem item, {
    bool fireNowForDebug = false,
  }) async {
    final l10n = AppLocalizations.current();
    await cancelTask(item.id);
    if (item.isDeleted || item.isCompleted) {
      return;
    }
    if (
      shouldFireDebugReminderPreview(
        debugImmediateReminders: fireNowForDebug,
        item: item,
      )
    ) {
      for (final reminder in item.reminders) {
        await _plugin.show(
          _debugPreviewNotificationId(item.id, reminder.offsetMinutes),
          l10n.notificationDebugTitle(item.title),
          item.description.isEmpty
              ? l10n.notificationDebugBody(reminder.offsetMinutes)
              : l10n.notificationDebugBodyWithDescription(
                  item.description,
                  reminder.offsetMinutes,
                ),
          NotificationDetails(
            iOS: const DarwinNotificationDetails(
              interruptionLevel: InterruptionLevel.timeSensitive,
              presentAlert: true,
              presentSound: true,
            ),
            android: AndroidNotificationDetails(
              'doggylog_tasks',
              l10n.notificationChannelName,
              channelDescription: l10n.notificationChannelDescription,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: 'task-preview:${item.id}:${reminder.offsetMinutes}',
        );
      }
    }
    final now = DateTime.now();
    for (final reminder in item.reminders) {
      final fireAt = item.startAt.subtract(
        Duration(minutes: reminder.offsetMinutes),
      );
      if (!fireAt.isAfter(now)) {
        continue;
      }
      await _plugin.zonedSchedule(
        _notificationId(item.id, reminder.offsetMinutes),
        item.title,
        item.description.isEmpty
            ? l10n.notificationStartingSoon(item.category)
            : item.description,
        tz.TZDateTime.from(fireAt, tz.local),
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
            presentAlert: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'doggylog_tasks',
            l10n.notificationChannelName,
            channelDescription: l10n.notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'task:${item.id}',
      );
    }
  }

  Future<void> cancelTask(String taskId) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final id
        in pending
            .where((item) => item.payload == 'task:$taskId')
            .map((item) => item.id)) {
      await _plugin.cancel(id);
    }
  }

  List<int> _idsForTask(String taskId, List<ReminderPolicy> reminders) {
    return reminders
        .map((item) => _notificationId(taskId, item.offsetMinutes))
        .toList();
  }

  int _notificationId(String taskId, int offsetMinutes) {
    var hash = 17;
    for (final code in taskId.codeUnits) {
      hash = 37 * hash + code;
    }
    hash = 37 * hash + offsetMinutes;
    return hash.abs() % 2147483646;
  }

  int _debugPreviewNotificationId(String taskId, int offsetMinutes) {
    return _notificationId(taskId, -(offsetMinutes + 1));
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _createAndroidChannel() async {
    final l10n = AppLocalizations.current();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        'doggylog_tasks',
        l10n.notificationChannelName,
        description: l10n.notificationChannelDescription,
        importance: Importance.max,
      ),
    );
  }
}
