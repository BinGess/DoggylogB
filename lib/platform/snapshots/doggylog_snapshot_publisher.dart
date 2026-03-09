import 'dart:convert';

import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:doggylog/platform/snapshots/doggylog_shared_snapshot.dart';

class DoggylogSnapshotPublisher {
  DoggylogSnapshotPublisher(this._platform, this._repository);

  final DoggylogPlatform _platform;
  final AppRepository _repository;

  Future<void> publish(AppState state) async {
    final pet = state.selectedPet;
    final mood = pet == null
        ? PetMood.calm
        : _repository.deriveMood(pet, state.calendarItems);
    final snapshot = DoggylogSharedSnapshot.fromAppState(state, mood: mood);
    final payload = jsonEncode(snapshot.toJson());
    await _platform.publishWidgetSnapshot(payload);
    final hasLiveActivityContent =
        snapshot.today.pendingCount > 0 ||
        snapshot.today.nextTaskTitle != null ||
        snapshot.countdown != null ||
        snapshot.recentTasks.isNotEmpty;
    if (hasLiveActivityContent) {
      await _platform.updateDynamicIsland(payload);
    } else {
      await _platform.endDynamicIsland();
    }
  }
}
