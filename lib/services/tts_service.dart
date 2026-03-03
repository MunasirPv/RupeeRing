import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal() {
    _initTTS();
  }

  final FlutterTts _flutterTts = FlutterTts();

  // Languages map
  static const Map<String, String> languageCodes = {
    'English': 'en-IN',
    'Malayalam': 'ml-IN',
    'Hindi': 'hi-IN',
    'Kannada': 'kn-IN',
  };

  bool _isVoiceEnabled = true;
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool _overrideSilentMode = false;
  bool get overrideSilentMode => _overrideSilentMode;
  static const MethodChannel _platform = MethodChannel(
    'com.poslyt.rupeering/settings',
  );

  String _currentLanguageCode = 'en-IN'; // Default
  String get currentLanguage => languageCodes.entries
      .firstWhere(
        (element) => element.value == _currentLanguageCode,
        orElse: () => const MapEntry('English', 'en-IN'),
      )
      .key;

  Future<void> _initTTS() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts
        .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ], IosTextToSpeechAudioMode.defaultMode);

    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString('tts_language_code') ?? 'en-IN';
    _isVoiceEnabled = prefs.getBool('tts_is_voice_enabled') ?? true;
    _overrideSilentMode = prefs.getBool('tts_override_silent_mode') ?? false;

    await _flutterTts.setLanguage(_currentLanguageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> toggleVoiceEnabled(bool enabled) async {
    _isVoiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_is_voice_enabled', enabled);
  }

  Future<void> toggleOverrideSilentMode(bool enabled) async {
    _overrideSilentMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_override_silent_mode', enabled);
  }

  Future<void> testVoice() async {
    String message = "";
    switch (_currentLanguageCode) {
      case 'ml-IN':
        message = "വോയ്‌സ് ടെസ്റ്റ് വിജയിച്ചു.";
        break;
      case 'hi-IN':
        message = "वॉयस टेस्ट सफल रहा।";
        break;
      case 'kn-IN':
        message = "ಧ್ವನಿ ಪರೀಕ್ಷೆ ಯಶಸ್ವಿಯಾಗಿದೆ.";
        break;
      default:
        message = "Voice test successful.";
    }
    await _speak(message);
  }

  Future<void> setLanguage(String languageName) async {
    final String? code = languageCodes[languageName];
    if (code != null) {
      _currentLanguageCode = code;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_language_code', code);

      await _flutterTts.setLanguage(code);
    }
  }

  Future<void> speakPaymentReceived(
    String amount, {
    String appName = 'UPI',
  }) async {
    String textToSpeak = '';

    // Clean app name for TTS (e.g., com.phonepe.app -> PhonePe)
    String cleanAppName = appName;
    if (appName.contains('paytm'))
      cleanAppName = 'Paytm';
    else if (appName.contains('phonepe'))
      cleanAppName = 'PhonePe';
    else if (appName.contains('paisa') || appName.contains('google'))
      cleanAppName = 'Google Pay';
    else if (appName.contains('bhim') || appName.contains('upiapp'))
      cleanAppName = 'BHIM UPI';
    else if (appName.contains('bharatpe'))
      cleanAppName = 'BharatPe';
    else if (appName.contains('navi'))
      cleanAppName = 'Navi';

    // Choose phrase based on language.
    switch (_currentLanguageCode) {
      case 'ml-IN':
        textToSpeak =
            '$cleanAppName ൽ നിന്ന് $amount രൂപ ലഭിച്ചിരിക്കുന്നു. നന്ദി.'; // "₹ amount received from App. Thank you."
        break;
      case 'hi-IN':
        textToSpeak =
            '$cleanAppName पर $amount रुपये प्राप्त हुए. धन्यवाद.'; // "₹ amount received on App. Thank you."
        break;
      case 'kn-IN':
        textToSpeak =
            '$cleanAppName ಮೂಲಕ $amount ರೂಪಾಯಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ. ಧನ್ಯವಾದಗಳು.'; // Kannada
        break;
      case 'en-IN':
      default:
        textToSpeak = 'Received $amount rupees on $cleanAppName. Thank you.';
        break;
    }

    if (!_isVoiceEnabled) {
      return; // Global mute toggle is enabled
    }

    if (Platform.isAndroid) {
      await _speak(textToSpeak);
    } else {
      await _flutterTts.speak(textToSpeak);
    }
  }

  Future<void> _speak(String text) async {
    if (Platform.isAndroid) {
      try {
        await _platform.invokeMethod('speakAlarm', {
          "text": text,
          "language": _currentLanguageCode,
          "overrideSilentMode": _overrideSilentMode,
        });
      } catch (e) {
        await _flutterTts.speak(text);
      }
    } else {
      await _flutterTts.speak(text);
    }
  }
}
