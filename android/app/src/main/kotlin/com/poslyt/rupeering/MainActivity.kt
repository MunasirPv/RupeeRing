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

class MainActivity: FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "com.poslyt.rupeering/settings"
    private var tts: TextToSpeech? = null
    private var isTtsInitialized = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Native TTS
        tts = TextToSpeech(this, this)

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
                    
                    if (text != null && isTtsInitialized) {
                        speakOverAlarmStream(text, languageCode)
                        result.success(true)
                    } else {
                        result.error("TTS_ERROR", "TTS not initialized or text is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            isTtsInitialized = true
        }
    }

    private fun speakOverAlarmStream(text: String, languageCode: String) {
        // 1. Check Ringer Mode to Respect Silent/Vibrate
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_SILENT, AudioManager.RINGER_MODE_VIBRATE -> {
                println("RupeeRing: Aborting TTS because phone is in Silent/Vibrate mode.")
                return 
            }
        }

        // 2. Set Language
        val locale = Locale.forLanguageTag(languageCode)
        tts?.language = locale

        // 3. Set Audio Attributes to USAGE_ALARM to bypass Media Volume
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
            .build()
            
        tts?.setAudioAttributes(audioAttributes)

        // 4. Speak
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "RupeeRingAlarmTTS")
    }
    
    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
