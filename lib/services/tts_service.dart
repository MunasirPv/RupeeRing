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
  };

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

    await _flutterTts.setLanguage(_currentLanguageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
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

  Future<void> speakPaymentReceived(String amount) async {
    String textToSpeak = '';

    // Choose phrase based on language. You can expand this for translation files later.
    switch (_currentLanguageCode) {
      case 'ml-IN':
        textToSpeak =
            '$amount രൂപ ലഭിച്ചിരിക്കുന്നു'; // "₹ amount received" in Malayalam
        break;
      case 'hi-IN':
        textToSpeak = '$amount रुपये प्राप्त हुए'; // Hindi
        break;
      case 'en-IN':
      default:
        textToSpeak = 'Received $amount rupees securely.'; // English
        break;
    }

    await _flutterTts.speak(textToSpeak);
  }
}
