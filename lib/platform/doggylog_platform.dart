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
  static bool _handlerInitialized = false;

  DoggylogPlatform() {
    _ensureHandler();
  }

  Stream<String> get platformEvents => _eventController.stream;
  Stream<MotionSample> get sensorEvents => _sensorController.stream;

  Future<bool> isCalendarSyncAvailable() async {
    return _invokeBool('isCalendarSyncAvailable');
  }

  Future<bool> requestCalendarAccess() async {
    return _invokeBool('requestCalendarAccess');
  }

  Future<List<CalendarItem>> importCalendarItems() async {
    try {
      final json = await _channel.invokeMethod<String>('importCalendarItems');
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

  Future<CalendarSyncDelta?> syncCalendarDelta({DateTime? updatedAfter}) async {
    try {
      final json = await _channel.invokeMethod<String>(
        'syncCalendarDelta',
        <String, Object?>{'updatedAfter': updatedAfter?.millisecondsSinceEpoch},
      );
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
      }
    });
  }
}
