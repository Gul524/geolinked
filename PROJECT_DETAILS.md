# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a location-based community messaging app that allows users to ask questions or broadcast updates to people within a specific radius.
- **Project Roadmap**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

Main features:
- **Asks**: Location-targeted queries (e.g., "Is the shop open?").
- **Broadcasts**: News/alerts (e.g., "Traffic jam ahead") shared in a radius.
- **Interactive Map**: Live view of community activity using Open Street Map (OSM).
- **Media Support**: Users can attach photos to Asks and Broadcasts for better visual reporting.
- **Background Sync**: Real-time location tracking even when the app is closed.
- **Data Control**: Permanent account and data deletion for user privacy compliance.

## 2. Tech Stack
- **Flutter**: SDK ^3.10.4
- **State Management**: Riverpod 3.x
- **Backend**: Firebase
  - **Auth**: Firebase Authentication (Email/Password)
  - **Database**: Cloud Firestore (Real-time data)
  - **Storage**: ✅ **Firebase Storage** (Media uploads)
  - **Messaging**: Firebase Cloud Messaging (FCM)
- **Background**: `workmanager` (Periodic background sync)
- **Security**: Granular Firestore & Storage rules for owner-only data access.

## 3. Core App Flow
1. **Startup**: Splash screen checks for Firebase session and loads cached user profile.
2. **Auth**: Login/Signup creates/fetches profile from Firestore `users` collection.
3. **Map**: Main screen displays markers for nearby `asks` and `broadcasts`.
4. **Data Deletion**: Users can permanently delete their account, which triggers a cascading deletion of their Firestore profile and Auth record.

## 4. Key Services
- **FirestoreService**: Handles all database operations including geohashed writes and radius queries.
- **NotificationService**: Manages FCM tokens and geohash-based topic subscriptions.
- **StorageService**: Manages media uploads with a secure path structure: `posts/{folder}/{userId}/{fileName}`.
- **BackgroundService**: Manages periodic background location synchronization.
- **UserNotifier**: Centralized logic for session management, profile fetching, and account deletion.

## 5. Firebase Schema
- `users/{uid}`: `{name, email, lastLocation: {lat, lng}, fcmToken, geohash}`
- `asks/{id}`: `{userId, title, description, imageUrl, location: {geopoint, geohash}, createdAt, status}`
- `broadcasts/{id}`: `{authorId, title, message, imageUrl, location: {geopoint, geohash}, radiusKm, severity, createdAt}`

## 6. Implementation Notes
- **Security Rules**: Firestore and Storage are protected by owner-uid checks. No user can modify another user's profile or delete their media.
- **Background Location Sync**: Uses `workmanager` to update `lastLocation` every 15 minutes in a separate isolate.
- **Privacy Compliance**: Includes a dedicated `PrivacyPolicyScreen` and a secure account deletion flow in the `ProfileScreen`.

## 7. Next Steps
1. **Map Clustering**: Enhancing Map performance for high-density areas.
2. **Advanced Filters**: Toggle markers by category or post type.
3. **Skeleton Loaders**: Professional shimmer effects for data fetching states.
