import 'dart:convert';
import 'dart:async';

import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DoggylogPlatform {
  static const _channel = MethodChannel('doggylog/platform');
  static final StreamController<String> _eventController =
      StreamController<String>.broadcast();
  static final StreamController<MotionSample> _sensorController =
      StreamController<MotionSample>.broadcast();
  static final StreamController<String> _widgetActionController =
      StreamController<String>.broadcast();
  static bool _handlerInitialized = false;

  DoggylogPlatform() {
    _ensureHandler();
  }

  Stream<String> get platformEvents => _eventController.stream;
  Stream<MotionSample> get sensorEvents => _sensorController.stream;

  /// 灵动岛"完成"按钮触发的任务 ID 流
  Stream<String> get widgetCompleteTaskEvents => _widgetActionController.stream;

  Future<bool> isCalendarSyncAvailable() async {
    return _invokeBool('isCalendarSyncAvailable');
  }

  Future<bool> requestCalendarAccess() async {
    return _invokeBool('requestCalendarAccess');
  }

  Future<AppVersionInfo?> loadAppVersionInfo() async {
    try {
      final payload = await _channel.invokeMapMethod<String, Object?>(
        'loadAppVersionInfo',
      );
      if (payload == null) {
        return null;
      }
      final version = payload['version'] as String?;
      final buildNumber = payload['buildNumber'] as String?;
      if (version == null || buildNumber == null) {
        return null;
      }
      return AppVersionInfo(version: version, buildNumber: buildNumber);
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('DoggylogPlatform.loadAppVersionInfo failed: $error');
      return null;
    }
  }

  Future<List<CalendarItem>> importCalendarItems() async {
    return importCalendarItemsFromCalendars();
  }

  Future<List<CalendarItem>> importCalendarItemsFromCalendars({
    List<String>? selectedCalendarIds,
  }) async {
    try {
      final json = await _channel.invokeMethod<String>(
        'importCalendarItems',
        <String, Object?>{'selectedCalendarIds': selectedCalendarIds},
      );
      if (json == null || json.isEmpty) {
        return const [];
      }
      final decoded = (jsonDecode(json) as List<dynamic>)
          .map((item) => CalendarItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return decoded;
    } on MissingPluginException {
      return const [];
    } catch (error) {
      debugPrint('DoggylogPlatform.importCalendarItems failed: $error');
      return const [];
    }
  }

  Future<List<SystemCalendar>> getSystemCalendars() async {
    try {
      final json = await _channel.invokeMethod<String>('getSystemCalendars');
      if (json == null || json.isEmpty) {
        return const [];
      }
      final decoded = (jsonDecode(json) as List<dynamic>)
          .map(
            (item) => SystemCalendar.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      return decoded;
    } on MissingPluginException {
      return const [];
    } catch (error) {
      debugPrint('DoggylogPlatform.getSystemCalendars failed: $error');
      return const [];
    }
  }

  Future<CalendarSyncDelta?> syncCalendarDelta({
    DateTime? updatedAfter,
    List<String>? selectedCalendarIds,
  }) async {
    try {
      final json = await _channel
          .invokeMethod<String>('syncCalendarDelta', <String, Object?>{
            'updatedAfter': updatedAfter?.millisecondsSinceEpoch,
            'selectedCalendarIds': selectedCalendarIds,
          });
      if (json == null || json.isEmpty) {
        return null;
      }
      return CalendarSyncDelta.fromJson(
        Map<String, dynamic>.from(jsonDecode(json) as Map),
      );
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('DoggylogPlatform.syncCalendarDelta failed: $error');
      return null;
    }
  }

  Future<String?> upsertCalendarItem(CalendarItem item) async {
    try {
      return await _channel.invokeMethod<String>(
        'upsertCalendarItem',
        <String, Object?>{'payloadJson': jsonEncode(item.toJson())},
      );
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('DoggylogPlatform.upsertCalendarItem failed: $error');
      return null;
    }
  }

  Future<bool> deleteCalendarItem(CalendarItem item) async {
    return _invokeBool(
      'deleteCalendarItem',
      arguments: <String, Object?>{
        'systemEntryId': item.systemEntryId,
        'localId': item.id,
      },
    );
  }

  Future<bool> requestNotificationPermissions() async {
    return _invokeBool('requestNotificationPermissions');
  }

  Future<bool> backupToCloud() async {
    return _invokeBool('backupToCloud');
  }

  Future<List<String>> loadVerifiedOwnedProductIds(
    List<String> productIds,
  ) async {
    try {
      final ids = await _channel.invokeListMethod<String>(
        'loadVerifiedOwnedProductIds',
        <String, Object?>{'productIds': productIds},
      );
      return ids ?? const <String>[];
    } on MissingPluginException {
      return const <String>[];
    } catch (error) {
      debugPrint('DoggylogPlatform.loadVerifiedOwnedProductIds failed: $error');
      return const <String>[];
    }
  }

  Future<bool> publishWidgetSnapshot(String payloadJson) async {
    return _invokeBool(
      'publishWidgetSnapshot',
      arguments: <String, Object?>{'payloadJson': payloadJson},
    );
  }

  Future<bool> updateDynamicIsland(String payloadJson) async {
    return _invokeBool(
      'updateDynamicIsland',
      arguments: <String, Object?>{'payloadJson': payloadJson},
    );
  }

  Future<bool> endDynamicIsland() async {
    return _invokeBool('endDynamicIsland');
  }

  Future<bool> startSensors() async {
    return _invokeBool('startSensors');
  }

  Future<void> stopSensors() async {
    try {
      await _channel.invokeMethod<void>('stopSensors');
    } on MissingPluginException {
      // Running in Flutter-only mode until native enhancements are connected.
    }
  }

  Future<bool> _invokeBool(
    String method, {
    Map<String, Object?>? arguments,
  }) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on MissingPluginException {
      return false;
    } catch (error) {
      debugPrint('DoggylogPlatform.$method failed: $error');
      return false;
    }
  }

  void _ensureHandler() {
    if (_handlerInitialized) {
      return;
    }
    _handlerInitialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'eventStoreDidChange') {
        _eventController.add('eventStoreDidChange');
      } else if (call.method == 'sensorSample') {
        final arguments = call.arguments;
        if (arguments is Map) {
          _sensorController.add(
            MotionSample.fromJson(Map<String, dynamic>.from(arguments)),
          );
        }
      } else if (call.method == 'completeTaskFromWidget') {
        final arguments = call.arguments;
        if (arguments is Map) {
          final taskId = arguments['taskId'] as String?;
          if (taskId != null && taskId.isNotEmpty) {
            _widgetActionController.add(taskId);
          }
        }
      }
    });
  }
}

class AppVersionInfo {
  const AppVersionInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;
}
