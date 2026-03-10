import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/doggylog_platform.dart';

class IosCalendarSyncService {
  IosCalendarSyncService(this._platform);

  final DoggylogPlatform _platform;

  Future<bool> requestAccess() => _platform.requestCalendarAccess();

  Future<bool> isAvailable() => _platform.isCalendarSyncAvailable();

  Future<List<SystemCalendar>> loadSystemCalendars() =>
      _platform.getSystemCalendars();

  Future<List<CalendarItem>> importItems({List<String>? selectedCalendarIds}) =>
      _platform.importCalendarItemsFromCalendars(
        selectedCalendarIds: selectedCalendarIds,
      );

  Future<CalendarSyncDelta?> syncDelta({
    DateTime? updatedAfter,
    List<String>? selectedCalendarIds,
  }) => _platform.syncCalendarDelta(
    updatedAfter: updatedAfter,
    selectedCalendarIds: selectedCalendarIds,
  );

  Future<String?> upsertItem(CalendarItem item) =>
      _platform.upsertCalendarItem(item.copyWith(reminders: const []));

  Future<bool> deleteItem(CalendarItem item) =>
      _platform.deleteCalendarItem(item);

  Stream<String> get platformEvents => _platform.platformEvents;
}
