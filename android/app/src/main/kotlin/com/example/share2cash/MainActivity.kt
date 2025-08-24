// android/app/src/main/kotlin/com/example/share2cash/MainActivity.kt
package com.example.share2cash

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.pawns.sdk.common.sdk.Pawns


class MainActivity : FlutterActivity() {
    private val CHANNEL = "pawns_control"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startPawns" -> {
                    Pawns.getInstance().startSharing(this)
                    result.success(null)
                }
                "stopPawns" -> {
                    Pawns.getInstance().stopSharing(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}

