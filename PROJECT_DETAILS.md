# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a location-based community messaging app that allows users to ask questions or broadcast updates to people within a specific radius.
- **Project Roadmap**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

Main features:
- **Asks**: Location-targeted queries (e.g., "Is the shop open?").
- **Broadcasts**: News/alerts (e.g., "Traffic jam ahead") shared in a radius.
- **Interactive Map**: Live view of community activity with custom category markers and clustering.
- **Media Support**: Users can attach photos to Asks and Broadcasts with full-screen pinch-to-zoom viewing.
- **Background Sync**: Real-time location tracking even when the app is closed.
- **Data Control**: Permanent account and data deletion for user privacy compliance.

## 2. Tech Stack
- **Flutter**: SDK ^3.10.4
- **State Management**: Riverpod 3.x
- **Backend**: Firebase
  - **Auth**: Firebase Authentication (Email/Password)
  - **Database**: Cloud Firestore (Real-time data)
  - **Storage**: Firebase Storage (Media uploads)
  - **Messaging**: Firebase Cloud Messaging (FCM)
- **Maps**: Flutter Map (OpenStreetMap)
  - **Clustering**: `flutter_map_marker_cluster`
- **UX**:
  - **Loading**: `shimmer`
  - **Zoom**: `photo_view`
- **Background**: `workmanager` (Periodic background sync)
- **Security**: Granular Firestore & Storage rules for owner-only data access.

## 3. Core App Flow
1. **Startup**: Splash screen checks for Firebase session and loads cached user profile.
2. **Auth**: Login/Signup creates/fetches profile from Firestore `users` collection.
3. **Map**: Main screen displays clustered markers for nearby `asks` and `broadcasts`.
4. **Discussion**: Users can tap markers or feed items to join threads, view images full-screen, and contribute.

## 4. Key Services
- **FirestoreService**: Handles all database operations including geohashed writes and radius queries.
- **NotificationService**: Manages FCM tokens and geohash-based topic subscriptions.
- **StorageService**: Manages media uploads with a secure path structure.
- **BackgroundService**: Manages periodic background location synchronization.
- **UserNotifier**: Centralized logic for session management, profile fetching, and account deletion.

## 5. UI Features
- **Custom Markers**: Category-specific icons (Traffic, Road Block, Safety Alert, Utility Issue, Public Event, Market Update).
- **Skeleton States**: Professional shimmer effects during data retrieval to reduce perceived latency.
- **Empty States**: Guided UI for new users when no local activity is found.

## 6. Implementation Notes
- **Clustering**: Map markers are grouped automatically when zoomed out to maintain performance.
- **Compatibility**: All UI code uses `withOpacity` instead of `withValues` to ensure compatibility with Flutter 3.10.4+.
- **Privacy Compliance**: Includes a dedicated `PrivacyPolicyScreen` and a secure account deletion flow.
