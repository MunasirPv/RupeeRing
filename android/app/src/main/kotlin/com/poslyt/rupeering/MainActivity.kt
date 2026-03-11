package com.poslyt.rupeering

import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.content.Context
import android.provider.Settings
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.poslyt.rupeering/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Native TTS Utility
        TtsManager.init(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "speakAlarm" -> {
                    val text = call.argument<String>("text")
                    val languageCode = call.argument<String>("language") ?: "en-IN"
                    val overrideSilentMode = call.argument<Boolean>("overrideSilentMode") ?: false
                    
                    if (text != null) {
                        TtsManager.speak(this, text, languageCode, overrideSilentMode)
                        result.success(true)
                    } else {
                        result.error("TTS_ERROR", "Text is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        TtsManager.shutdown()
        super.onDestroy()
    }
}
