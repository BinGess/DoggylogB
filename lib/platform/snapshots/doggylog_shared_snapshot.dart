import 'package:doggylog/features/shared/domain/models.dart';
import 'package:intl/intl.dart';

class DoggylogSharedSnapshot {
  const DoggylogSharedSnapshot({
    required this.generatedAt,
    required this.today,
    required this.pet,
    required this.countdown,
    required this.recentTasks,
  });

  final DateTime generatedAt;
  final SnapshotToday today;
  final SnapshotPet pet;
  final SnapshotCountdown? countdown;
  final List<SnapshotTask> recentTasks;

  Map<String, dynamic> toJson() => {
    'generatedAt': generatedAt.millisecondsSinceEpoch,
    'today': today.toJson(),
    'pet': pet.toJson(),
    'countdown': countdown?.toJson(),
    'recentTasks': recentTasks.map((item) => item.toJson()).toList(),
  };

  factory DoggylogSharedSnapshot.fromAppState(
    AppState state, {
    required PetMood mood,
  }) {
    final now = DateTime.now();
    final todayTasks =
        state.calendarItems
            .where(
              (item) =>
                  !item.isDeleted &&
                  item.startAt.year == now.year &&
                  item.startAt.month == now.month &&
                  item.startAt.day == now.day,
            )
            .toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final nextTask =
        state.calendarItems
            .where((item) => !item.isDeleted && item.startAt.isAfter(now))
            .toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final pinnedCountdown = [...state.countdowns]
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return a.dueAt.compareTo(b.dueAt);
      });

    return DoggylogSharedSnapshot(
      generatedAt: now,
      today: SnapshotToday(
        pendingCount: todayTasks.where((item) => !item.isCompleted).length,
        completedCount: todayTasks.where((item) => item.isCompleted).length,
        nextTaskTitle: nextTask.isEmpty ? null : nextTask.first.title,
        nextTaskTime: nextTask.isEmpty
            ? null
            : DateFormat('HH:mm').format(nextTask.first.startAt),
      ),
      pet: SnapshotPet(
        name: state.selectedPet?.name ?? 'DoggyLog',
        breed: state.selectedPet?.breed.name ?? PetBreed.shiba.name,
        mood: mood.name,
        loyaltyLevel: state.selectedPet?.loyaltyLevel ?? 1,
        sceneMode: state.activeScene.name,
      ),
      countdown: pinnedCountdown.isEmpty
          ? null
          : SnapshotCountdown(
              title: pinnedCountdown.first.title,
              dueAt: pinnedCountdown.first.dueAt.millisecondsSinceEpoch,
              daysRemaining:
                  pinnedCountdown.first.dueAt.difference(now).inDays + 1,
            ),
      recentTasks: todayTasks
          .take(3)
          .map(
            (item) => SnapshotTask(
              title: item.title,
              time: DateFormat('HH:mm').format(item.startAt),
              category: item.category.name,
              completed: item.isCompleted,
            ),
          )
          .toList(),
    );
  }
}

class SnapshotToday {
  const SnapshotToday({
    required this.pendingCount,
    required this.completedCount,
    required this.nextTaskTitle,
    required this.nextTaskTime,
  });

  final int pendingCount;
  final int completedCount;
  final String? nextTaskTitle;
  final String? nextTaskTime;

  Map<String, dynamic> toJson() => {
    'pendingCount': pendingCount,
    'completedCount': completedCount,
    'nextTaskTitle': nextTaskTitle,
    'nextTaskTime': nextTaskTime,
  };
}

class SnapshotPet {
  const SnapshotPet({
    required this.name,
    required this.breed,
    required this.mood,
    required this.loyaltyLevel,
    required this.sceneMode,
  });

  final String name;
  final String breed;
  final String mood;
  final int loyaltyLevel;
  final String sceneMode;

  Map<String, dynamic> toJson() => {
    'name': name,
    'breed': breed,
    'mood': mood,
    'loyaltyLevel': loyaltyLevel,
    'sceneMode': sceneMode,
  };
}

class SnapshotCountdown {
  const SnapshotCountdown({
    required this.title,
    required this.dueAt,
    required this.daysRemaining,
  });

  final String title;
  final int dueAt;
  final int daysRemaining;

  Map<String, dynamic> toJson() => {
    'title': title,
    'dueAt': dueAt,
    'daysRemaining': daysRemaining,
  };
}

class SnapshotTask {
  const SnapshotTask({
    required this.title,
    required this.time,
    required this.category,
    required this.completed,
  });

  final String title;
  final String time;
  final String category;
  final bool completed;

  Map<String, dynamic> toJson() => {
    'title': title,
    'time': time,
    'category': category,
    'completed': completed,
  };
}
