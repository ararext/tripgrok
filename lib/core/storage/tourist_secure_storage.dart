import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/tourist_data.dart';

class TouristSecureStorage {
  TouristSecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyName = 'tourist_name';
  static const String _keyPassport = 'tourist_passport';
  static const String _keyId = 'tourist_id';
  static const String _keyItinerary = 'tourist_itinerary';
  static const String _keyEmergencyContacts = 'tourist_emergency_contacts';
  static const String _keyExpiry = 'tourist_expiry';

  static Future<void> saveTouristData(TouristData data) async {
    await _storage.write(key: _keyName, value: data.name);
    await _storage.write(key: _keyPassport, value: data.passport);
    await _storage.write(key: _keyId, value: data.id);
    await _storage.write(key: _keyItinerary, value: jsonEncode(data.itinerary));
    await _storage.write(
      key: _keyEmergencyContacts,
      value: jsonEncode(data.emergencyContacts),
    );
    await _storage.write(key: _keyExpiry, value: data.expiry.toIso8601String());
  }

  static Future<TouristData> loadTouristData() async {
    final name = await _storage.read(key: _keyName) ?? '';
    final passport = await _storage.read(key: _keyPassport) ?? '';
    final id = await _storage.read(key: _keyId) ?? '';
    final itineraryRaw = await _storage.read(key: _keyItinerary);
    final emergencyRaw = await _storage.read(key: _keyEmergencyContacts);
    final expiryRaw = await _storage.read(key: _keyExpiry);

    final secureData = TouristData(
      id: id,
      name: name,
      passport: passport,
      itinerary: _decodeStringList(itineraryRaw),
      emergencyContacts: _decodeStringList(emergencyRaw),
      expiry: DateTime.tryParse(expiryRaw ?? '') ?? DateTime.now(),
    );

    if (secureData.id.isNotEmpty || secureData.name.isNotEmpty) {
      return secureData;
    }

    final migratedData = await _loadLegacyFromSharedPreferences();
    if (migratedData.id.isNotEmpty || migratedData.name.isNotEmpty) {
      await saveTouristData(migratedData);
    }
    return migratedData;
  }

  static Future<void> saveItinerary(List<String> itinerary) async {
    await _storage.write(key: _keyItinerary, value: jsonEncode(itinerary));
  }

  static Future<void> clearTouristData() async {
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyPassport);
    await _storage.delete(key: _keyId);
    await _storage.delete(key: _keyItinerary);
    await _storage.delete(key: _keyEmergencyContacts);
    await _storage.delete(key: _keyExpiry);
  }

  static List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) return <String>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((item) => item.toString()).toList();
    }
    return <String>[];
  }

  static Future<TouristData> _loadLegacyFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return TouristData(
      id: prefs.getString('tourist_id') ?? '',
      name: prefs.getString('tourist_name') ?? '',
      passport: prefs.getString('tourist_passport') ?? '',
      itinerary: prefs.getStringList('itinerary') ?? <String>[],
      emergencyContacts:
          prefs.getStringList('emergency_contacts') ?? <String>[],
      expiry: DateTime.tryParse(prefs.getString('expiry') ?? '') ??
          DateTime.now(),
    );
  }
}
