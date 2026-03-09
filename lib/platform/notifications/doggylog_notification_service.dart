import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  Future<void> scheduleTask(CalendarItem item) async {
    await cancelTask(item.id);
    if (item.isDeleted || item.isCompleted) {
      return;
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
            ? '即将开始 · ${item.category.label}'
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
            'DoggyLog Tasks',
            channelDescription: 'Task reminders for DoggyLog calendar entries.',
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'doggylog_tasks',
        'DoggyLog Tasks',
        description: 'Task reminders for DoggyLog calendar entries.',
        importance: Importance.max,
      ),
    );
  }
}
