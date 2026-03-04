package com.poslyt.rupeering

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.speech.tts.TextToSpeech
import java.util.Locale

object TtsManager : TextToSpeech.OnInitListener {
    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private var pendingText: String? = null
    private var pendingLocale: Locale? = null
    private var pendingOverride: Boolean = false

    private var appContext: Context? = null

    fun init(context: Context) {
        if (tts == null) {
            appContext = context.applicationContext
            tts = TextToSpeech(context.applicationContext, this)
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            isInitialized = true
            val context = appContext
            if (context != null) {
                pendingText?.let { text ->
                    pendingLocale?.let { locale ->
                        speakInternal(context, text, locale, pendingOverride)
                    }
                }
            }
            pendingText = null
            pendingLocale = null
        }
    }

    fun speak(context: Context, text: String, languageCode: String, overrideSilentMode: Boolean) {
        val locale = Locale.forLanguageTag(languageCode)
        if (!isInitialized) {
            init(context)
            pendingText = text
            pendingLocale = locale
            pendingOverride = overrideSilentMode
            return
        }
        speakInternal(context, text, locale, overrideSilentMode)
    }

    private fun speakInternal(context: Context, text: String, locale: Locale, overrideSilentMode: Boolean) {
        // Respect silent mode if not overridden
        if (!overrideSilentMode) {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            if (audioManager.ringerMode == AudioManager.RINGER_MODE_SILENT || 
                audioManager.ringerMode == AudioManager.RINGER_MODE_VIBRATE) {
                return
            }
        }

        tts?.let { ttsInstance ->
            ttsInstance.language = locale
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build()
            ttsInstance.setAudioAttributes(audioAttributes)
            ttsInstance.speak(text, TextToSpeech.QUEUE_FLUSH, null, "RupeeRingBackgroundTTS")
        }
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.shutdown()
        tts = null
        isInitialized = false
    }
}
