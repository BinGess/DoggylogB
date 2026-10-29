/// Growth dates are captured at completion in the device's local calendar.
/// They are not derived from a task's planned date or reinterpreted on travel.
String growthDateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

int growthBonus(int days) => days >= 7
    ? 12
    : days >= 5
    ? 8
    : days >= 3
    ? 5
    : 0;

class GrowthBadge {
  const GrowthBadge(this.id, this.goal, {this.isStreak = false});
  final String id;
  final int goal;
  final bool isStreak;
}

const growthBadges = [
  GrowthBadge('lv1', 1),
  GrowthBadge('lv3', 3),
  GrowthBadge('lv5', 5),
  GrowthBadge('lv7', 7),
  GrowthBadge('lv10', 10),
  GrowthBadge('s3', 3, isStreak: true),
  GrowthBadge('s7', 7, isStreak: true),
];

class GrowthLedgerEntry {
  const GrowthLedgerEntry({
    required this.id,
    required this.taskId,
    required this.title,
    required this.completedAt,
    required this.dateKey,
    this.active = true,
    this.baseXp = 10,
    this.bonusXp = 0,
    this.streak = 1,
    this.revokedAt,
    this.reason = 'complete',
  });
  final String id;
  final String taskId;
  final String title;
  final DateTime completedAt;
  final String dateKey;
  final bool active;
  final int baseXp;
  final int bonusXp;
  final int streak;
  final DateTime? revokedAt;
  final String reason;
  int get xp => baseXp + bonusXp;

  GrowthLedgerEntry copyWith({
    String? title,
    bool? active,
    int? bonusXp,
    int? streak,
    DateTime? revokedAt,
    String? reason,
  }) => GrowthLedgerEntry(
    id: id,
    taskId: taskId,
    title: title ?? this.title,
    completedAt: completedAt,
    dateKey: dateKey,
    active: active ?? this.active,
    baseXp: baseXp,
    bonusXp: bonusXp ?? this.bonusXp,
    streak: streak ?? this.streak,
    revokedAt: revokedAt ?? this.revokedAt,
    reason: reason ?? this.reason,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'title': title,
    'completedAt': completedAt.millisecondsSinceEpoch,
    'dateKey': dateKey,
    'active': active,
    'baseXp': baseXp,
    'bonusXp': bonusXp,
    'streak': streak,
    'revokedAt': revokedAt?.millisecondsSinceEpoch,
    'reason': reason,
  };
  factory GrowthLedgerEntry.fromJson(Map<String, dynamic> json) =>
      GrowthLedgerEntry(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        title: json['title'] as String,
        completedAt: DateTime.fromMillisecondsSinceEpoch(
          json['completedAt'] as int,
        ),
        dateKey: json['dateKey'] as String,
        active: json['active'] as bool,
        baseXp: json['baseXp'] as int,
        bonusXp: json['bonusXp'] as int,
        streak: json['streak'] as int,
        revokedAt: json['revokedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['revokedAt'] as int),
        reason: json['reason'] as String,
      );
}

class CompanionGrowth {
  const CompanionGrowth({
    this.baseXp = 0,
    this.entries = const [],
    this.seenBadgeIds = const ['lv1'],
    this.version = 2,
    this.revision = 0,
    this.audit = const [],
  });
  final int revision;
  final List<GrowthAudit> audit;
  final int baseXp;
  final List<GrowthLedgerEntry> entries;
  final List<String> seenBadgeIds;
  final int version;
  int get totalXp =>
      baseXp + entries.where((e) => e.active).fold(0, (sum, e) => sum + e.xp);
  int get level => totalXp ~/ 100 + 1;
  int get levelXp => totalXp % 100;
  int get nextLevelXp => 100 - levelXp;
  int get longestStreak => entries
      .where((e) => e.active)
      .fold(0, (best, e) => e.streak > best ? e.streak : best);
  List<String> get badgeIds => growthBadges
      .where((b) => (b.isStreak ? longestStreak : level) >= b.goal)
      .map((b) => b.id)
      .toList();
  String get titleBadgeId =>
      growthBadges.where((b) => !b.isStreak && level >= b.goal).last.id;

  int currentStreak(DateTime now) {
    final today = growthDateKey(now);
    final local = now.toLocal();
    final yesterday = growthDateKey(
      DateTime(local.year, local.month, local.day - 1),
    );
    final active = entries.where((e) => e.active);
    final todayEntries = active.where((e) => e.dateKey == today);
    if (todayEntries.isNotEmpty) return todayEntries.first.streak;
    final yesterdayEntries = active.where((e) => e.dateKey == yesterday);
    return yesterdayEntries.isEmpty ? 0 : yesterdayEntries.first.streak;
  }

  bool completedToday(DateTime now) =>
      entries.any((e) => e.active && e.dateKey == growthDateKey(now));

  /// Exactly one daily bonus, attached to the earliest remaining completion.
  /// Revoking it transfers the bonus when another completion supports that day.
  CompanionGrowth recalculate() {
    final active = entries.where((e) => e.active).toList()
      ..sort((a, b) {
        final byDate = a.dateKey.compareTo(b.dateKey);
        if (byDate != 0) return byDate;
        final byTime = a.completedAt.compareTo(b.completedAt);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    final awards = <String, GrowthLedgerEntry>{};
    String? previousKey;
    DateTime? previousDay;
    var streak = 0;
    for (final entry in active) {
      final firstOfDay = entry.dateKey != previousKey;
      if (firstOfDay) {
        final date = DateTime.parse('${entry.dateKey}T00:00:00Z');
        streak = previousDay != null && date.difference(previousDay).inDays == 1
            ? streak + 1
            : 1;
        previousDay = date;
        previousKey = entry.dateKey;
      }
      awards[entry.id] = entry.copyWith(
        streak: streak,
        bonusXp: firstOfDay ? growthBonus(streak) : 0,
      );
    }
    return copyWith(entries: entries.map((e) => awards[e.id] ?? e).toList());
  }

  void validate() {
    if (version != 2 || baseXp < 0 || revision < 0) {
      throw const FormatException('Unsupported or corrupt growth account');
    }
    final ids = <String>{};
    final activeTasks = <String>{};
    for (final entry in entries) {
      final parsed = DateTime.tryParse('${entry.dateKey}T00:00:00Z');
      if (!ids.add(entry.id) ||
          entry.baseXp != 10 ||
          parsed == null ||
          parsed.toIso8601String().substring(0, 10) != entry.dateKey ||
          (entry.active && !activeTasks.add(entry.taskId))) {
        throw const FormatException('Invalid or duplicate growth reward');
      }
    }
    final calculated = recalculate();
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].active &&
          (entries[i].bonusXp != calculated.entries[i].bonusXp ||
              entries[i].streak != calculated.entries[i].streak)) {
        throw const FormatException('Growth rewards do not reconcile');
      }
    }
  }

  CompanionGrowth withAudit(
    CompanionGrowth before, {
    required String taskId,
    required String title,
    required String reason,
    required DateTime now,
    required String id,
  }) {
    final old = {for (final e in before.entries) e.id: e};
    final adjustments = <String, int>{};
    for (final e in entries) {
      final previous = old[e.id];
      final delta =
          (e.active ? e.xp : 0) -
          (previous != null && previous.active ? previous.xp : 0);
      if (delta != 0) adjustments[e.id] = delta;
    }
    if (adjustments.isEmpty) return this;
    return copyWith(
      revision: before.revision + 1,
      audit: [
        ...before.audit,
        GrowthAudit(
          id: id,
          taskId: taskId,
          title: title,
          reason: reason,
          at: now,
          beforeXp: before.totalXp,
          afterXp: totalXp,
          adjustments: adjustments,
        ),
      ],
    );
  }

  CompanionGrowth copyWith({
    int? baseXp,
    List<GrowthLedgerEntry>? entries,
    List<String>? seenBadgeIds,
    int? revision,
    List<GrowthAudit>? audit,
  }) => CompanionGrowth(
    revision: revision ?? this.revision,
    audit: audit ?? this.audit,
    baseXp: baseXp ?? this.baseXp,
    entries: entries ?? this.entries,
    seenBadgeIds: seenBadgeIds ?? this.seenBadgeIds,
    version: version,
  );
  Map<String, dynamic> toJson() => {
    'revision': revision,
    'audit': audit.map((e) => e.toJson()).toList(),
    'baseXp': baseXp,
    'entries': entries.map((e) => e.toJson()).toList(),
    'seenBadgeIds': seenBadgeIds,
    'version': version,
    'totalXp': totalXp,
  };
  factory CompanionGrowth.fromJson(
    Map<String, dynamic> json,
  ) => CompanionGrowth(
    revision: json['revision'] as int? ?? 0,
    audit: (json['audit'] as List? ?? [])
        .map((e) => GrowthAudit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    baseXp: json['baseXp'] as int,
    entries: (json['entries'] as List)
        .map(
          (e) =>
              GrowthLedgerEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    seenBadgeIds: (json['seenBadgeIds'] as List).cast<String>(),
    version: json['version'] as int,
  );
}

class GrowthChange {
  const GrowthChange({
    required this.before,
    required this.after,
    this.newBadgeIds = const [],
  });
  final CompanionGrowth before;
  final CompanionGrowth after;
  final List<String> newBadgeIds;
  int get delta => after.totalXp - before.totalXp;
  bool get upgraded => after.level > before.level;
  List<String> get revokedBadgeIds =>
      before.badgeIds.where((id) => !after.badgeIds.contains(id)).toList();
}

class GrowthPreviewChanged implements Exception {
  const GrowthPreviewChanged();
}

/// Immutable transaction history survives reassignment and later recalculation.
class GrowthAudit {
  const GrowthAudit({
    required this.id,
    required this.taskId,
    required this.title,
    required this.reason,
    required this.at,
    required this.beforeXp,
    required this.afterXp,
    required this.adjustments,
  });
  final String id, taskId, title, reason;
  final DateTime at;
  final int beforeXp, afterXp;
  final Map<String, int> adjustments;
  int get delta => afterXp - beforeXp;
  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'title': title,
    'reason': reason,
    'at': at.millisecondsSinceEpoch,
    'beforeXp': beforeXp,
    'afterXp': afterXp,
    'adjustments': adjustments,
  };
  factory GrowthAudit.fromJson(Map<String, dynamic> j) => GrowthAudit(
    id: j['id'] as String,
    taskId: j['taskId'] as String,
    title: j['title'] as String,
    reason: j['reason'] as String,
    at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int),
    beforeXp: j['beforeXp'] as int,
    afterXp: j['afterXp'] as int,
    adjustments: Map<String, int>.from(j['adjustments'] as Map),
  );
}
