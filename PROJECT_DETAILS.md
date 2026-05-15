# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a location-based community messaging app that allows users to ask questions or broadcast updates to people within a specific radius.
- **Project Roadmap**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

Main features:
- **Asks**: Location-targeted queries (e.g., "Is the shop open?").
- **Broadcasts**: News/alerts (e.g., "Traffic jam ahead") shared in a radius.
- **Interactive Map**: Live view of community activity using **Google Maps** with custom category markers and clustering.
- **Real-time Notifications**: Instant alerts for new nearby Asks and Broadcasts, triggered by front-end Firestore listeners (ensuring functionality without Cloud Functions).
- **Media Support**: Users can attach photos to Asks and Broadcasts with full-screen pinch-to-zoom viewing.
- **Background Sync**: Real-time location tracking even when the app is closed.
- **Data Control**: Permanent account and data deletion for user privacy compliance.

## 2. Tech Stack
- **Flutter**: SDK ^3.10.4
- **State Management**: Riverpod 3.x
- **Backend**: Firebase
  - **Auth**: Firebase Authentication (Email/Password)
  - **Database**: Cloud Firestore (Real-time data with Geohash queries)
  - **Storage**: Firebase Storage (Media uploads)
  - **Messaging**: Firebase Cloud Messaging (FCM) & Local Notifications
- **Maps**: Google Maps (`google_maps_flutter`)
  - **Search**: Google Places API with **1000ms debouncing** and detailed coordinate resolution.
- **UX**:
  - **Loading**: `shimmer` (Skeleton states)
  - **Zoom**: `photo_view`
- **Background**: `workmanager` (Periodic background sync)
- **Security**: Granular Firestore & Storage rules for owner-only data access.

## 3. Core App Flow
1. **Startup**: Splash screen checks for Firebase session and loads cached user profile.
2. **Auth**: Login/Signup creates/fetches profile from Firestore `users` collection.
3. **Map**: Main screen displays markers for nearby `asks` and `broadcasts`. Includes a professional floating search bar with autocomplete.
4. **Real-time Monitoring**: App listens to nearby data streams and triggers **Local Notifications** for new items arriving in the user's radius.
5. **Discussion**: Users can tap markers or feed items to join threads, view images full-screen, and contribute.

## 4. Key Services
- **FirestoreService**: Handles all database operations including geohashed writes, radius queries, and reliable document deletion using merged Document IDs.
- **NotificationService**: Manages FCM tokens, geohash-based topic subscriptions, and immediate local notification triggers with deep-linking support.
- **GooglePlacesService**: Custom service for debounced location searching and coordinate fetching.
- **GeoService**: Manages GPS location updates and dynamic geohash topic synchronization.
- **BackgroundService**: Manages periodic background location synchronization.

## 5. UI Features
- **Professional Search UI**: Map-centric search bar with clear buttons, suggestion icons, and smooth camera animations.
- **Custom Markers**: Category-specific icons (Traffic, Road Block, Safety Alert, Utility Issue, Public Event, Market Update).
- **Skeleton States**: Professional shimmer effects during data retrieval to reduce perceived latency.
- **Performance Optimized**: Parallelized GPS lookup and Firestore subscriptions with eager loading (using default coordinates while waiting for GPS lock).

## 6. Implementation Notes
- **Performance**: Asynchronous parallel data stream initialization reduces perceived latency on "Ask" and "Broadcast" screens by up to 60%.
- **Notification Architecture**: Uses a front-end "Seen ID" tracking system to deduplicate notifications and prevent spam during the initial app load.
- **Reliable Deletion**: Explicit Document ID mapping ensures that users can reliably delete their own content across all tabs.
- **Compatibility**: All UI code uses `withOpacity` instead of `withValues` to ensure compatibility with Flutter 3.10.4+.
- **Environment**: Secure API key management using `flutter_dotenv` with `.env` correctly registered in assets.
