// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tourist Safety App';

  @override
  String get login => 'Login / Check-in';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get digitalId => 'Digital Tourist ID';

  @override
  String get safetyScore => 'Safety Score';

  @override
  String get emergency => 'Emergency SOS';

  @override
  String get map => 'Interactive Map';

  @override
  String get settings => 'Settings';

  @override
  String get addItinerary => 'Add Itinerary Item';

  @override
  String get alertHighRisk => 'Alert: Entering high-risk zone!';

  @override
  String get panicButton => 'Panic Button';

  @override
  String get language => 'Select Language';
}
