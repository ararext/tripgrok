class TouristData {
  final String id;
  final String name;
  final String passport;
  final List<String> itinerary;
  final List<String> emergencyContacts;
  final DateTime expiry;

  TouristData({
    required this.id,
    required this.name,
    required this.passport,
    required this.itinerary,
    required this.emergencyContacts,
    required this.expiry,
  });
}