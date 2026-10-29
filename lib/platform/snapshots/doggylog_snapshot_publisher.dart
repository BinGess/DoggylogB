import 'dart:convert';

import 'package:doggylog/features/shared/data/app_repository.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:doggylog/platform/snapshots/doggylog_shared_snapshot.dart';

class DoggylogSnapshotPublisher {
  DoggylogSnapshotPublisher(
    this._platform,
    this._repository, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DoggylogPlatform _platform;
  final AppRepository _repository;
  final DateTime Function() _now;

  Future<void> publish(AppState state) async {
    final pet = state.selectedPet;
    final mood = pet == null
        ? PetMood.calm
        : _repository.deriveMood(pet, state.calendarItems);
    final snapshot = DoggylogSharedSnapshot.fromAppState(
      state,
      mood: mood,
      now: _now(),
    );
    final payload = jsonEncode(snapshot.toJson());
    if (!await _platform.publishWidgetSnapshot(payload)) {
      throw StateError('Widget snapshot was not published');
    }
    if (snapshot.countdown != null) {
      await _platform.updateDynamicIsland(payload);
    } else {
      await _platform.endDynamicIsland();
    }
  }
}
