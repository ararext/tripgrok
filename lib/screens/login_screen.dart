import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripgrok/generated/app_localizations.dart';
import 'package:tripgrok/models/tourist_data.dart';
import 'package:tripgrok/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _passportController = TextEditingController();

  void _simulateCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final mockData = TouristData(
      id: 'BLOCKCHAIN_ID_123', // Mock blockchain ID
      name: _nameController.text,
      passport: _passportController.text,
      itinerary: [],
      emergencyContacts: ['+91-1234567890'],
      expiry: DateTime.now().add(const Duration(days: 7)),
    );
    await prefs.setString('tourist_name', mockData.name);
    await prefs.setString('tourist_passport', mockData.passport);
    await prefs.setString('tourist_id', mockData.id);
    await prefs.setStringList('itinerary', mockData.itinerary);
    await prefs.setStringList('emergency_contacts', mockData.emergencyContacts);
    await prefs.setString('expiry', mockData.expiry.toIso8601String());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name / Aadhaar'),
            ),
            TextField(
              controller: _passportController,
              decoration: const InputDecoration(labelText: 'Passport'),
            ),
            ElevatedButton(
              onPressed: _simulateCheckIn,
              child: Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }
}