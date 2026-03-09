import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/platform/generated/doggylog_pigeon.g.dart',
    dartPackageName: 'doggylog',
    dartOptions: DartOptions(),
    swiftOut: 'ios/Runner/DoggylogPigeon.g.swift',
    kotlinOut:
        'android/app/src/main/kotlin/com/example/doggylog/DoggylogPigeon.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.doggylog'),
  ),
)
@HostApi()
abstract class CalendarSyncBridge {
  bool isAvailable();

  String syncAll();

  String importExisting();
}

@HostApi()
abstract class CloudBackupBridge {
  bool isAvailable();

  String backupNow();

  String restoreLatest();
}

@HostApi()
abstract class WidgetSnapshotBridge {
  bool publishSnapshot(String payloadJson);
}

@HostApi()
abstract class DynamicIslandBridge {
  bool isSupported();

  bool updateLiveActivity(String payloadJson);
}

@HostApi()
abstract class SensorBridge {
  bool startSensorStream();

  void stopSensorStream();
}
