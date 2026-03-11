package com.poslyt.rupeering

import android.service.notification.StatusBarNotification
import android.os.Build
import android.os.Bundle
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.annotation.RequiresApi
import notification.listener.service.NotificationListener

@RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
class CustomNotificationListener : NotificationListener() {

    private val TAG = "CustomNotifListener"

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun onNotificationPosted(notification: StatusBarNotification) {
        // First, allow the original plugin to handle its broadcast for the Flutter side (Foreground/Background)
        super.onNotificationPosted(notification)

        val packageName = notification.packageName
        val extras = notification.notification.extras
        val title = extras?.getCharSequence("android.title")?.toString() ?: ""
        val text = extras?.getCharSequence("android.text")?.toString() ?: ""

        if (isTargetApp(packageName)) {
            val amount = extractReceivedAmount(title, text)
            if (amount != null) {
                // 1. Announce via TTS
                announcePayment(amount, packageName)
                
                // 2. Log to Local Database
                val dbManager = DatabaseManager(applicationContext)
                dbManager.insertTransaction(packageName, amount)
            }
        }
    }

    private fun isTargetApp(packageName: String): Boolean {
        val allowedPackages = listOf(
            "net.one97.paytm",
            "com.phonepe.app",
            "com.phonepe.app.business",
            "com.google.android.apps.nbu.paisa.user",
            "com.google.android.apps.nbu.paisa.merchant",
            "in.org.npci.upiapp",
            "com.bharatpe.app",
            "com.naviapp"
        )
        return allowedPackages.contains(packageName)
    }

    private fun extractReceivedAmount(title: String, body: String): String? {
        val fullText = "$title $body"
        
        // Keywords check (matching regex_parser.dart)
        val receivedKeywords = Regex("received|paid you|payment of|credited", RegexOption.IGNORE_CASE)
        if (!receivedKeywords.containsMatchIn(fullText)) {
            return null
        }

        // Amount regex (matching regex_parser.dart)
        val amountRegex = Regex("(?:₹|Rs\\.?|INR)\\s*([0-9,]+\\.?[0-9]*)", RegexOption.IGNORE_CASE)
        val match = amountRegex.find(fullText)
        return match?.groups?.get(1)?.value?.replace(",", "")
    }

    private fun announcePayment(amount: String, packageName: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        val isVoiceEnabled = prefs.getBoolean("flutter.tts_is_voice_enabled", true)
        if (!isVoiceEnabled) return

        val languageCode = prefs.getString("flutter.tts_language_code", "en-IN") ?: "en-IN"
        val overrideSilentMode = prefs.getBoolean("flutter.tts_override_silent_mode", false)

        val appName = when {
            packageName.contains("paytm") -> "Paytm"
            packageName.contains("phonepe") -> "PhonePe"
            packageName.contains("paisa") || packageName.contains("google") -> "Google Pay"
            packageName.contains("bhim") || packageName.contains("upiapp") -> "BHIM UPI"
            packageName.contains("bharatpe") -> "BharatPe"
            packageName.contains("navi") -> "Navi"
            else -> "UPI"
        }

        val textToSpeak = when (languageCode) {
            "ml-IN" -> "$appName ൽ നിന്ന് $amount രൂപ ലഭിച്ചിരിക്കുന്നു. നന്ദി."
            "hi-IN" -> "$appName पर $amount रुपये प्राप्त हुए. धन्यवाद."
            "kn-IN" -> "$appName ಮೂಲಕ $amount ರೂಪಾಯಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ. ಧನ್ಯವಾದಗಳು."
            else -> "Received $amount rupees on $appName. Thank you."
        }

        TtsManager.speak(applicationContext, textToSpeak, languageCode, overrideSilentMode)
    }
}
