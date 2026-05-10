# GeoLinked 🌍

GeoLinked is a location-aware community engagement platform. It allows users to connect with their immediate physical surroundings by asking questions to nearby residents or broadcasting real-time updates (like traffic or safety alerts) to a specific radius.

## 🚀 Key Features
- **Radius-Based Queries**: Ask "Is the market open?" and only people in that radius get notified.
- **Background Location Sync**: Stay updated and receive alerts even when the app is closed.
- **Media Integration**: Attach photos to your posts to provide visual context for community updates.
- **Privacy & Data Control**: Integrated Privacy Policy and permanent Account Deletion options for user safety.

## 🛠️ Tech Stack
- **Frontend**: Flutter (Riverpod State Management)
- **Background**: Workmanager (Periodic background sync)
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Maps**: Google Maps & OpenStreetMap integration.
- **Location**: High-precision geolocator with geohash-based radius searching.

## 📁 Documentation
- **[Project Details](PROJECT_DETAILS.md)**: Deep dive into architecture and services.
- **[Production Checklist](PRODUCTION_CHECKLIST.md)**: Roadmap to release.
- **[User Guide](USER_GUIDE.md)**: Instructions for community members.

## 🚦 Getting Started
1. Clone the repository.
2. Run `flutter pub get`.
3. Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
4. Run `flutter run`.
