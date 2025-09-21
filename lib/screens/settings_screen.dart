import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripgrok/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('locale') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', lang);
    // Restart app to apply (in real app, use provider or similar for hot reload)
    Navigator.pop(context); // For prototype, just go back
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restart app to apply language')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(l10n.language),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                // Add more
              ],
              onChanged: (value) => _changeLanguage(value!),
            ),
            // Add accessibility toggles if needed (e.g., large text)
          ],
        ),
      ),
    );
  }
}