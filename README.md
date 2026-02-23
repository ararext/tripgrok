# Tripgrok

Tripgrok is a Flutter-based tourist safety app prototype with:
- Login/check-in flow
- Digital tourist ID and QR scanning
- Safety dashboard with emergency actions
- Interactive map with risk and safety markers
- Localization support (English/Hindi)

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (as bundled with Flutter)

## Run

```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## Recent Fixes

- Fixed widget test compilation by updating `MyApp` initialization to use required named parameters (`locale`, `isDarkMode`).
- Fixed potential runtime crash in the ID screen by safely formatting short/empty tourist IDs before preview rendering.
- Migrated tourist identity data storage from `SharedPreferences` to `flutter_secure_storage` for sensitive fields.
- Added iOS camera permission usage description for QR scan support (`NSCameraUsageDescription`).
