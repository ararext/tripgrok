import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripgrok/generated/app_localizations.dart';
import 'package:tripgrok/models/tourist_data.dart';

class IdScreen extends StatefulWidget {
  const IdScreen({super.key});

  @override
  State<IdScreen> createState() => _IdScreenState();
}

class _IdScreenState extends State<IdScreen> {
  TouristData? _data;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.digitalId)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _data == null
            ? const CircularProgressIndicator()
            : Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${_data!.id}'),
                      Text('Name: ${_data!.name}'),
                      Text('Passport: ${_data!.passport}'),
                      Text('Expiry: ${_data!.expiry.toString()}'),
                      Text('Emergency Contacts: ${_data!.emergencyContacts.join(', ')}'),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}