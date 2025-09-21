import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripgrok/generated/app_localizations.dart';
import 'package:tripgrok/models/tourist_data.dart';
import 'package:tripgrok/screens/id_screen.dart';
import 'package:tripgrok/screens/login_screen.dart';
import 'package:tripgrok/screens/map_screen.dart';
import 'package:tripgrok/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TouristData? _data;
  double _safetyScore = 85.0; // Mock AI-calculated score
  List<String> _itinerary = [];
  final _itineraryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _data = TouristData(
        id: prefs.getString('tourist_id') ?? '',
        name: prefs.getString('tourist_name') ?? '',
        passport: prefs.getString('tourist_passport') ?? '',
        itinerary: prefs.getStringList('itinerary') ?? [],
        emergencyContacts: prefs.getStringList('emergency_contacts') ?? [],
        expiry: DateTime.parse(prefs.getString('expiry') ?? DateTime.now().toIso8601String()),
      );
      _itinerary = _data!.itinerary;
    });
  }

  void _addItinerary() async {
    if (_itineraryController.text.isNotEmpty) {
      setState(() {
        _itinerary.add(_itineraryController.text);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('itinerary', _itinerary);
      _itineraryController.clear();
    }
  }

  void _simulatePanic() {
    print('Panic button pressed! Sending location to contacts and police.');
    launchUrl(Uri.parse('tel:+91100')); // Simulate call to police
  }

  void _checkExpiry() {
    if (_data != null && DateTime.now().isAfter(_data!.expiry)) {
      SharedPreferences.getInstance().then((prefs) => prefs.clear());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Fixed
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkExpiry(); // Auto-expiry check
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.safetyScore}: $_safetyScore', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(l10n.digitalId),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IdScreen())),
              child: Text(l10n.digitalId),
            ),
            const SizedBox(height: 20),
            Text(l10n.emergency),
            ElevatedButton(
              onPressed: _simulatePanic,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.panicButton),
            ),
            const SizedBox(height: 20),
            Text('Itinerary:'),
            ..._itinerary.map((item) => ListTile(title: Text(item))),
            TextField(
              controller: _itineraryController,
              decoration: InputDecoration(labelText: l10n.addItinerary),
            ),
            ElevatedButton(onPressed: _addItinerary, child: Text(l10n.addItinerary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
              child: Text(l10n.map),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              child: Text(l10n.settings),
            ),
          ],
        ),
      ),
    );
  }
}