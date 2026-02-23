import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tourist Safety App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login / Check-in'**
  String get login;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @digitalId.
  ///
  /// In en, this message translates to:
  /// **'Digital Tourist ID'**
  String get digitalId;

  /// No description provided for @safetyScore.
  ///
  /// In en, this message translates to:
  /// **'Safety Score'**
  String get safetyScore;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergency;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Interactive Map'**
  String get map;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addItinerary.
  ///
  /// In en, this message translates to:
  /// **'Add Itinerary Item'**
  String get addItinerary;

  /// No description provided for @alertHighRisk.
  ///
  /// In en, this message translates to:
  /// **'Alert: Entering high-risk zone!'**
  String get alertHighRisk;

  /// No description provided for @panicButton.
  ///
  /// In en, this message translates to:
  /// **'Panic Button'**
  String get panicButton;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language;

  /// No description provided for @companionTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Digital Safety Companion'**
  String get companionTagline;

  /// No description provided for @fullNameAadhaarLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name / Aadhaar Number'**
  String get fullNameAadhaarLabel;

  /// No description provided for @fullNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name or Aadhaar number'**
  String get fullNameValidation;

  /// No description provided for @passportOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Passport Number (Optional for Indians)'**
  String get passportOptionalLabel;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @featureDigitalIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital ID'**
  String get featureDigitalIdTitle;

  /// No description provided for @featureDigitalIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Blockchain-based verification'**
  String get featureDigitalIdDesc;

  /// No description provided for @featureLiveTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get featureLiveTrackingTitle;

  /// No description provided for @featureLiveTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time safety monitoring'**
  String get featureLiveTrackingDesc;

  /// No description provided for @featureEmergencySosTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get featureEmergencySosTitle;

  /// No description provided for @featureEmergencySosDesc.
  ///
  /// In en, this message translates to:
  /// **'One-tap help button'**
  String get featureEmergencySosDesc;

  /// No description provided for @featureSafeRoutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Routes'**
  String get featureSafeRoutesTitle;

  /// No description provided for @featureSafeRoutesDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered navigation'**
  String get featureSafeRoutesDesc;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @defaultTouristName.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get defaultTouristName;

  /// No description provided for @riskAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Alert!'**
  String get riskAlertTitle;

  /// No description provided for @riskAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'You have entered a high-risk zone. Your safety score has decreased.'**
  String get riskAlertMessage;

  /// No description provided for @riskAlertActions.
  ///
  /// In en, this message translates to:
  /// **'Suggested actions:\n• Stay in well-lit areas\n• Keep emergency contacts ready\n• Consider changing route'**
  String get riskAlertActions;

  /// No description provided for @riskAlertUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get riskAlertUnderstood;

  /// No description provided for @viewSafeRoute.
  ///
  /// In en, this message translates to:
  /// **'View Safe Route'**
  String get viewSafeRoute;

  /// No description provided for @emergencyAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert Sent!'**
  String get emergencyAlertSent;

  /// No description provided for @emergencyNotified.
  ///
  /// In en, this message translates to:
  /// **'🚨 Emergency services have been notified'**
  String get emergencyNotified;

  /// No description provided for @locationShared.
  ///
  /// In en, this message translates to:
  /// **'📍 Your location has been shared'**
  String get locationShared;

  /// No description provided for @contactsAlerted.
  ///
  /// In en, this message translates to:
  /// **'📞 Emergency contacts alerted'**
  String get contactsAlerted;

  /// No description provided for @helpOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Help is on the way!'**
  String get helpOnTheWay;

  /// No description provided for @nearbyPolice.
  ///
  /// In en, this message translates to:
  /// **'Nearby Police'**
  String get nearbyPolice;

  /// No description provided for @nearbyHospitals.
  ///
  /// In en, this message translates to:
  /// **'Nearby Hospitals'**
  String get nearbyHospitals;

  /// No description provided for @yourItinerary.
  ///
  /// In en, this message translates to:
  /// **'Your Itinerary'**
  String get yourItinerary;

  /// No description provided for @noItineraryItems.
  ///
  /// In en, this message translates to:
  /// **'No itinerary items yet'**
  String get noItineraryItems;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @itineraryAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary item added successfully!'**
  String get itineraryAddedSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
