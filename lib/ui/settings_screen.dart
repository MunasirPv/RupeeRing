import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TTSService _ttsService = TTSService();
  late String _selectedLanguage;
  late bool _isVoiceEnabled;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _ttsService.currentLanguage;
    _isVoiceEnabled = _ttsService.isVoiceEnabled;
  }

  final List<String> _languages = TTSService.languageCodes.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Voice Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Enable Voice Announcements'),
            subtitle: const Text('Turn off to mute all payment alerts'),
            value: _isVoiceEnabled,
            activeColor: Colors.blue.shade700,
            onChanged: (bool value) {
              setState(() {
                _isVoiceEnabled = value;
              });
              _ttsService.toggleVoiceEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Announcement Language'),
            subtitle: Text(_selectedLanguage),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: _languages.map((String lang) {
                return DropdownMenuItem<String>(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _ttsService.setLanguage(newValue);

                  // Test the new language
                  _ttsService.speakPaymentReceived("100");
                }
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About RupeeRing'),
            subtitle: const Text('Open Source UPI Soundbox v1.0.0'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                    'RupeeRing is an open-source alternative to hardware soundboxes. It works by securely listening to incoming notifications of UPI apps running on your device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
