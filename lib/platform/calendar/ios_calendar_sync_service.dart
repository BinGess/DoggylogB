import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/doggylog_platform.dart';

class IosCalendarSyncService {
  IosCalendarSyncService(this._platform);

  final DoggylogPlatform _platform;

  Future<bool> requestAccess() => _platform.requestCalendarAccess();

  Future<bool> isAvailable() => _platform.isCalendarSyncAvailable();

  Future<List<CalendarItem>> importItems() => _platform.importCalendarItems();

  Future<CalendarSyncDelta?> syncDelta({DateTime? updatedAfter}) =>
      _platform.syncCalendarDelta(updatedAfter: updatedAfter);

  Future<String?> upsertItem(CalendarItem item) =>
      _platform.upsertCalendarItem(item);

  Future<bool> deleteItem(CalendarItem item) =>
      _platform.deleteCalendarItem(item);

  Stream<String> get platformEvents => _platform.platformEvents;
}
