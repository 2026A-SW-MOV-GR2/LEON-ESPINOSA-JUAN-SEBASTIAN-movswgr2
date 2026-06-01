package com.example.actividad_flutter

import android.content.res.Configuration
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "resource_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "getResources") {

                    val text = getString(R.string.dynamic_text)
                    val textColor = ContextCompat.getColor(this, R.color.text_color)
                    val bgColor = ContextCompat.getColor(this, R.color.background_color)

                    result.success(mapOf(
                        "text" to text,
                        "textColor" to textColor,
                        "backgroundColor" to bgColor
                    ))

                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
    }
}