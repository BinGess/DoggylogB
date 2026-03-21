package com.example.doggylog

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "doggylog/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isCalendarSyncAvailable",
                    "backupToCloud",
                    "publishWidgetSnapshot",
                    "updateDynamicIsland",
                    "endDynamicIsland",
                    "startSensors" -> result.success(false)
                    "loadAppVersionInfo" -> {
                        val packageInfo = packageManager.getPackageInfo(packageName, 0)
                        result.success(
                            mapOf(
                                "version" to (packageInfo.versionName ?: ""),
                                "buildNumber" to packageInfo.longVersionCode.toString(),
                            )
                        )
                    }
                    "stopSensors" -> result.success(null)
                    else -> result.notImplemented()
                }
            }
    }
}
