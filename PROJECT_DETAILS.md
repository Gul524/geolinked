# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a location-based community messaging app that allows users to ask questions or broadcast updates to people within a specific radius.
- **Project Status**: [PROJECT_STATUS.md](file:///home/sulemangul/.gemini/antigravity/brain/6e23af27-db2c-4306-a072-c0ca4be16352/project_status.md) (Task Tracking)

Main features:
- **Asks**: Location-targeted queries (e.g., "Is the shop open?").
- **Broadcasts**: News/alerts (e.g., "Traffic jam ahead") shared in a radius.
- **Interactive Map**: Live view of community activity using Open Street Map (OSM).
- **Place Search**: Global search for locations using the OSM Nominatim API.
- **Current Location Focus**: Quick-access button to center the map on the user's live position.
- **Media Support**: Users can attach photos to Asks and Broadcasts for better visual reporting.
- **Radius Notifications**: Intelligent push notifications for nearby events.

## 2. Tech Stack
- **Flutter**: SDK ^3.10.4
- **State Management**: Riverpod 3.x (Global Theme, User Session, Ask/Broadcast Streams)
- **Backend**: Firebase
  - **Auth**: Firebase Authentication (Email/Password)
  - **Database**: Cloud Firestore (Real-time data)
  - **Storage**: ✅ **Firebase Storage** (Media uploads)
  - **Messaging**: Firebase Cloud Messaging (FCM)
- **Geolocation**:
  - `geolocator`: Live tracking and permission management.
  - `flutter_map`: Open Street Map (OSM) integration (No API Key Required).
  - `geoflutterfire_plus`: Geohash-based radius queries.
- **Package Name**: `com.sulemangul.geolinked` (Updated for Release)
- **Firebase Status**: ✅ **Connected**
- **Local Cache**: Hive (Auth tokens, User ID, Profile data)

## 3. Core App Flow
1. **Startup**: Splash screen checks for Firebase session and loads the **cached user profile** for instant offline access.
2. **Auth**: Login/Signup creates/fetches profile from Firestore `users` collection.
3. **Map**: Main screen displays markers for nearby `asks` and `broadcasts` (Cached for offline viewing).
4. **Action**: Users tap the Map to select a target location for new posts.
5. **Real-time**: Posts appear instantly for nearby users via Firestore streams and Geohash topic notifications.

## 4. Key Services
- **FirestoreService**: Handles all database operations including geohashed writes and radius queries.
- **NotificationService**: Manages FCM tokens, local notifications, and geohash-based topic subscriptions.
- **GeoService**: Tracks live user location, manages the `geo_{geohash}` topic fallback, and provides OSM-based place search via Nominatim.
- **StorageService**: Manages media uploads to Firebase Storage with organized folder structures.
- **LocalStorageService**: Manages Hive-based persistence for faster offline startup.

## 5. Firebase Schema
- `users/{uid}`: `{name, email, lastLocation: {lat, lng}, fcmToken, geohash}`
- `asks/{id}`: `{userId, title, description, imageUrl, location: {geopoint, geohash}, createdAt, status}`
- `broadcasts/{id}`: `{authorId, title, message, imageUrl, location: {geopoint, geohash}, radiusKm, severity, createdAt}`
- `asks/{id}/comments`: Sub-collection for real-time discussion.

## 6. Implementation Notes
- **Real-time Discussion**: Asks and Broadcasts both feature live discussion threads. These are implemented using Firestore sub-collections (`comments`). The `AskDiscussionController` and `BroadcastDiscussionController` subscribe to these sub-collections to provide a chat-like experience.
- **Geohash Fallback**: Every user is subscribed to a topic named `geo_ABCDE` (where ABCDE is their 5-char geohash). This allows for instant area-wide broadcasts even without a backend query.
- **Cloud Functions**: A Node.js trigger `onAskCreated` sends notifications to users within the exact radius defined in the post.

## 7. Folder Structure
- `lib/configs`: App constants, theme, and providers.
- `lib/feature`: UI and Controllers grouped by feature (Auth, Home, Map, Ask, Broadcast).
- `lib/model`: Data models with JSON serialization.
- `lib/services`: External integrations (Firebase, Geo, Storage).
- `lib/shared`: Reusable design-system components.

## 8. Next Steps
1. **Background Tracking**: Implementation of `workmanager` for background location updates.
2. **Map Clustering**: Enhancing Map performance for high-density areas.
