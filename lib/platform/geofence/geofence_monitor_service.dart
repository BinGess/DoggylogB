import 'dart:async';

import 'package:doggylog/features/shared/domain/models.dart';
import 'package:geolocator/geolocator.dart';

class GeofenceSceneUpdate {
  const GeofenceSceneUpdate({required this.sceneMode, this.placeName});

  final SceneMode sceneMode;
  final String? placeName;
}

class GeofenceMonitorService {
  StreamSubscription<Position>? _positionSub;

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> startMonitoring(
    List<GeofencePlace> places,
    void Function(GeofenceSceneUpdate update) onUpdate,
  ) async {
    await stopMonitoring();
    if (places.isEmpty) {
      onUpdate(const GeofenceSceneUpdate(sceneMode: SceneMode.home));
      return;
    }

    final current = await Geolocator.getCurrentPosition();
    onUpdate(resolveScene(places, current.latitude, current.longitude));

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 40,
          ),
        ).listen((position) {
          onUpdate(resolveScene(places, position.latitude, position.longitude));
        });
  }

  Future<void> stopMonitoring() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  GeofenceSceneUpdate resolveScene(
    List<GeofencePlace> places,
    double latitude,
    double longitude,
  ) {
    GeofencePlace? best;
    var bestDistance = double.infinity;
    for (final place in places) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );
      if (distance <= place.radiusMeters && distance < bestDistance) {
        best = place;
        bestDistance = distance;
      }
    }
    if (best == null) {
      return const GeofenceSceneUpdate(sceneMode: SceneMode.home);
    }
    return GeofenceSceneUpdate(sceneMode: best.sceneMode, placeName: best.name);
  }
}
