import 'dart:convert';

enum CalendarCategory {
  daily('日常', 'bone'),
  work('工作', 'folder'),
  anniversary('纪念日', 'heart'),
  pet('宠物相关', 'paw');

  const CalendarCategory(this.label, this.iconToken);
  final String label;
  final String iconToken;
}

enum CalendarViewMode { month, week, day, list }

enum PetBreed { shiba, goldenRetriever, beagle, husky, samoyed }

enum PetMood { excited, calm, lazy, sad }

enum SceneMode { home, working, walking, resting, caring }

enum SyncSource { localOnly, iosCalendar, iosReminder, imported }

enum ReminderChannel { inApp, push, sound }

enum CountdownMood { sunrise, noon, dusk, midnight }

enum PerformanceTier { rich, balanced, lite }

class MotionSample {
  const MotionSample({required this.x, required this.y, required this.depth});

  const MotionSample.zero() : x = 0, y = 0, depth = 0;

  final double x;
  final double y;
  final double depth;

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'depth': depth};

  factory MotionSample.fromJson(Map<String, dynamic> json) {
    return MotionSample(
      x: (json['x'] as num? ?? 0).toDouble(),
      y: (json['y'] as num? ?? 0).toDouble(),
      depth: (json['depth'] as num? ?? 0).toDouble(),
    );
  }
}

class ReminderPolicy {
  const ReminderPolicy({
    required this.offsetMinutes,
    this.channels = const [ReminderChannel.inApp, ReminderChannel.push],
  });

  final int offsetMinutes;
  final List<ReminderChannel> channels;

  Map<String, dynamic> toJson() => {
    'offsetMinutes': offsetMinutes,
    'channels': channels.map((item) => item.name).toList(),
  };

  factory ReminderPolicy.fromJson(Map<String, dynamic> json) {
    return ReminderPolicy(
      offsetMinutes: json['offsetMinutes'] as int? ?? 15,
      channels: (json['channels'] as List<dynamic>? ?? const [])
          .map((item) => ReminderChannel.values.byName(item as String))
          .toList(),
    );
  }
}

class CalendarItem {
  const CalendarItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.category,
    required this.petId,
    required this.reminders,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.systemEntryId,
    this.isCompleted = false,
    this.isDeleted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final CalendarCategory category;
  final String? petId;
  final List<ReminderPolicy> reminders;
  final SyncSource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? systemEntryId;
  final bool isCompleted;
  final bool isDeleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startAt': startAt.millisecondsSinceEpoch,
    'endAt': endAt.millisecondsSinceEpoch,
    'category': category.name,
    'petId': petId,
    'reminders': reminders.map((item) => item.toJson()).toList(),
    'source': source.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'systemEntryId': systemEntryId,
    'isCompleted': isCompleted,
    'isDeleted': isDeleted,
  };

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startAt: DateTime.fromMillisecondsSinceEpoch(json['startAt'] as int),
      endAt: DateTime.fromMillisecondsSinceEpoch(json['endAt'] as int),
      category: CalendarCategory.values.byName(
        json['category'] as String? ?? CalendarCategory.daily.name,
      ),
      petId: json['petId'] as String?,
      reminders: (json['reminders'] as List<dynamic>? ?? const [])
          .map(
            (item) => ReminderPolicy.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      source: SyncSource.values.byName(
        json['source'] as String? ?? SyncSource.localOnly.name,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      systemEntryId: json['systemEntryId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  CalendarItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    CalendarCategory? category,
    String? petId,
    List<ReminderPolicy>? reminders,
    SyncSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? systemEntryId,
    bool? isCompleted,
    bool? isDeleted,
  }) {
    return CalendarItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      category: category ?? this.category,
      petId: petId ?? this.petId,
      reminders: reminders ?? this.reminders,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      systemEntryId: systemEntryId ?? this.systemEntryId,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class PetSkin {
  const PetSkin({
    required this.id,
    required this.name,
    required this.visualTag,
    required this.unlockLevel,
  });

  final String id;
  final String name;
  final String visualTag;
  final int unlockLevel;
}

class PetProfile {
  const PetProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.loyaltyPoints,
    required this.selectedSkinId,
    required this.unlockedSkinIds,
    required this.createdAt,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final PetBreed breed;
  final int loyaltyPoints;
  final String selectedSkinId;
  final List<String> unlockedSkinIds;
  final DateTime createdAt;
  final bool isSelected;

  int get loyaltyLevel => (loyaltyPoints ~/ 100) + 1;

  PetProfile copyWith({
    String? id,
    String? name,
    PetBreed? breed,
    int? loyaltyPoints,
    String? selectedSkinId,
    List<String>? unlockedSkinIds,
    DateTime? createdAt,
    bool? isSelected,
  }) {
    return PetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      unlockedSkinIds: unlockedSkinIds ?? this.unlockedSkinIds,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class LoyaltyLedger {
  const LoyaltyLedger({
    required this.id,
    required this.petId,
    required this.calendarItemId,
    required this.points,
    required this.createdAt,
    required this.reason,
  });

  final String id;
  final String petId;
  final String calendarItemId;
  final int points;
  final DateTime createdAt;
  final String reason;
}

class CountdownItem {
  const CountdownItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.createdAt,
    this.petId,
    this.isPinned = false,
    this.hasCelebrated = false,
  });

  final String id;
  final String title;
  final DateTime dueAt;
  final DateTime createdAt;
  final String? petId;
  final bool isPinned;
  final bool hasCelebrated;

  CountdownItem copyWith({
    String? id,
    String? title,
    DateTime? dueAt,
    DateTime? createdAt,
    String? petId,
    bool? isPinned,
    bool? hasCelebrated,
  }) {
    return CountdownItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      petId: petId ?? this.petId,
      isPinned: isPinned ?? this.isPinned,
      hasCelebrated: hasCelebrated ?? this.hasCelebrated,
    );
  }

  double progress(DateTime now) {
    final total = dueAt.difference(createdAt).inSeconds.abs();
    if (total == 0) {
      return 1;
    }
    final elapsed = now.difference(createdAt).inSeconds.clamp(0, total);
    return elapsed / total;
  }

  CountdownMood mood(DateTime now) {
    final remainingRatio = 1 - progress(now);
    if (remainingRatio <= 0.1) {
      return CountdownMood.midnight;
    }
    if (remainingRatio <= 0.25) {
      return CountdownMood.dusk;
    }
    if (remainingRatio <= 0.55) {
      return CountdownMood.noon;
    }
    return CountdownMood.sunrise;
  }
}

class GeofencePlace {
  const GeofencePlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.sceneMode,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final SceneMode sceneMode;
}

class UserPreference {
  const UserPreference({
    required this.hasCompletedOnboarding,
    required this.weekStartsOnMonday,
    required this.fontScale,
    required this.hapticsEnabled,
    required this.animationSpeed,
    required this.performanceTier,
    required this.selectedCalendarView,
    required this.faceIdEnabled,
    required this.debugImmediateReminders,
    required this.useSystemCalendarFilter,
    required this.visibleSystemCalendarIds,
  });

  const UserPreference.defaults()
    : hasCompletedOnboarding = false,
      weekStartsOnMonday = false,
      fontScale = 1,
      hapticsEnabled = true,
      animationSpeed = 1,
      performanceTier = PerformanceTier.balanced,
      selectedCalendarView = CalendarViewMode.month,
      faceIdEnabled = false,
      debugImmediateReminders = false,
      useSystemCalendarFilter = false,
      visibleSystemCalendarIds = const [];

  final bool hasCompletedOnboarding;
  final bool weekStartsOnMonday;
  final double fontScale;
  final double animationSpeed;
  final bool hapticsEnabled;
  final PerformanceTier performanceTier;
  final CalendarViewMode selectedCalendarView;
  final bool faceIdEnabled;
  final bool debugImmediateReminders;
  final bool useSystemCalendarFilter;
  final List<String> visibleSystemCalendarIds;

  UserPreference copyWith({
    bool? hasCompletedOnboarding,
    bool? weekStartsOnMonday,
    double? fontScale,
    bool? hapticsEnabled,
    double? animationSpeed,
    PerformanceTier? performanceTier,
    CalendarViewMode? selectedCalendarView,
    bool? faceIdEnabled,
    bool? debugImmediateReminders,
    bool? useSystemCalendarFilter,
    List<String>? visibleSystemCalendarIds,
  }) {
    return UserPreference(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      weekStartsOnMonday: weekStartsOnMonday ?? this.weekStartsOnMonday,
      fontScale: fontScale ?? this.fontScale,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      performanceTier: performanceTier ?? this.performanceTier,
      selectedCalendarView: selectedCalendarView ?? this.selectedCalendarView,
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
      debugImmediateReminders:
          debugImmediateReminders ?? this.debugImmediateReminders,
      useSystemCalendarFilter:
          useSystemCalendarFilter ?? this.useSystemCalendarFilter,
      visibleSystemCalendarIds:
          visibleSystemCalendarIds ?? this.visibleSystemCalendarIds,
    );
  }
}

class QuickEntryDraft {
  const QuickEntryDraft({
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.category,
    this.petId,
  });

  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final CalendarCategory category;
  final String? petId;
}

class CalendarSyncDelta {
  const CalendarSyncDelta({
    required this.items,
    required this.visibleSystemEntryIds,
    required this.syncedAt,
  });

  final List<CalendarItem> items;
  final List<String> visibleSystemEntryIds;
  final DateTime syncedAt;

  factory CalendarSyncDelta.fromJson(Map<String, dynamic> json) {
    return CalendarSyncDelta(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => CalendarItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      visibleSystemEntryIds:
          (json['visibleSystemEntryIds'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      syncedAt: DateTime.fromMillisecondsSinceEpoch(
        json['syncedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

class SystemCalendar {
  const SystemCalendar({
    required this.id,
    required this.title,
    required this.sourceTitle,
    required this.colorHex,
    this.allowsContentModifications = true,
  });

  final String id;
  final String title;
  final String sourceTitle;
  final String colorHex;
  final bool allowsContentModifications;

  factory SystemCalendar.fromJson(Map<String, dynamic> json) {
    return SystemCalendar(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '未命名日历',
      sourceTitle: json['sourceTitle'] as String? ?? '其他',
      colorHex: json['colorHex'] as String? ?? '#C7CDD8',
      allowsContentModifications:
          json['allowsContentModifications'] as bool? ?? true,
    );
  }
}

class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final CalendarCategory category;
  final int durationMinutes;
}

class AppState {
  const AppState({
    required this.preferences,
    required this.selectedDate,
    required this.calendarView,
    required this.calendarItems,
    required this.pets,
    required this.countdowns,
    required this.templates,
    required this.geofences,
    required this.recentSuggestions,
    this.notificationPermissionGranted = false,
    this.calendarPermissionGranted = false,
    this.locationPermissionGranted = false,
    this.biometricAvailable = false,
    this.appUnlocked = true,
    this.activeGeofenceName,
    this.motion = const MotionSample.zero(),
    this.sensorStreamActive = false,
    this.lastSyncMessage,
    this.activeScene = SceneMode.home,
    this.fetchingBall = false,
  });

  final UserPreference preferences;
  final DateTime selectedDate;
  final CalendarViewMode calendarView;
  final List<CalendarItem> calendarItems;
  final List<PetProfile> pets;
  final List<CountdownItem> countdowns;
  final List<TaskTemplate> templates;
  final List<GeofencePlace> geofences;
  final List<String> recentSuggestions;
  final bool notificationPermissionGranted;
  final bool calendarPermissionGranted;
  final bool locationPermissionGranted;
  final bool biometricAvailable;
  final bool appUnlocked;
  final String? activeGeofenceName;
  final MotionSample motion;
  final bool sensorStreamActive;
  final String? lastSyncMessage;
  final SceneMode activeScene;
  final bool fetchingBall;

  PetProfile? get selectedPet {
    for (final pet in pets) {
      if (pet.isSelected) {
        return pet;
      }
    }
    return pets.isEmpty ? null : pets.first;
  }

  AppState copyWith({
    UserPreference? preferences,
    DateTime? selectedDate,
    CalendarViewMode? calendarView,
    List<CalendarItem>? calendarItems,
    List<PetProfile>? pets,
    List<CountdownItem>? countdowns,
    List<TaskTemplate>? templates,
    List<GeofencePlace>? geofences,
    List<String>? recentSuggestions,
    bool? notificationPermissionGranted,
    bool? calendarPermissionGranted,
    bool? locationPermissionGranted,
    bool? biometricAvailable,
    bool? appUnlocked,
    String? activeGeofenceName,
    MotionSample? motion,
    bool? sensorStreamActive,
    String? lastSyncMessage,
    SceneMode? activeScene,
    bool? fetchingBall,
  }) {
    return AppState(
      preferences: preferences ?? this.preferences,
      selectedDate: selectedDate ?? this.selectedDate,
      calendarView: calendarView ?? this.calendarView,
      calendarItems: calendarItems ?? this.calendarItems,
      pets: pets ?? this.pets,
      countdowns: countdowns ?? this.countdowns,
      templates: templates ?? this.templates,
      geofences: geofences ?? this.geofences,
      recentSuggestions: recentSuggestions ?? this.recentSuggestions,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      calendarPermissionGranted:
          calendarPermissionGranted ?? this.calendarPermissionGranted,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      appUnlocked: appUnlocked ?? this.appUnlocked,
      activeGeofenceName: activeGeofenceName ?? this.activeGeofenceName,
      motion: motion ?? this.motion,
      sensorStreamActive: sensorStreamActive ?? this.sensorStreamActive,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
      activeScene: activeScene ?? this.activeScene,
      fetchingBall: fetchingBall ?? this.fetchingBall,
    );
  }
}

String encodeJsonList(List<Map<String, dynamic>> value) => jsonEncode(value);

List<Map<String, dynamic>> decodeJsonList(String? value) {
  if (value == null || value.isEmpty) {
    return const [];
  }
  final decoded = jsonDecode(value) as List<dynamic>;
  return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
}
