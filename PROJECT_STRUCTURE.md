# GeoLinked Project Structure

This document provides a detailed breakdown of the project's folder structure and the purpose of each key file.

## 📁 Root Directories
- **android/**: Android-specific configurations, including permissions and package name (`com.sulemangul.geolinked`).
- **assets/**: (Optional) Images, icons, and fonts used in the app.
- **lib/**: The core Flutter source code.
- **test/**: Unit and widget tests.

## 📂 lib/ - Source Code
The `lib` folder is organized by feature and service following a modular architecture.

### ⚙️ lib/configs/
- **app_constants.dart**: Global constants like API endpoints and storage keys.
- **app_routes.dart**: Definition of all navigation routes in the app.
- **app_theme.dart**: Light and Dark mode design system (colors, typography).
- **providers/**:
    - **user_provider.dart**: Manages global session with **Offline-First caching** (instantly loads profile from local storage).
    - **theme_provider.dart**: Controls the app's theme mode (Light/Dark/System).

### 🚀 lib/feature/ - Feature Modules
Each feature contains its own UI (Screens), logic (Controllers), and local components.

#### 📍 lib/feature/map/
- **map_screen.dart**: The main interactive map interface (Open Street Map).
- **map_controller.dart**: Reactive logic for rendering nearby Asks and Broadcasts as markers.

#### ❓ lib/feature/ask/
- **ask_screen.dart**: List of nearby and personal queries.
- **ask_controller.dart**: Handles fetching and submitting Asks to Firestore.
- **ask_discussion_screen.dart**: Real-time chat interface for a specific query.
- **ask_discussion_controller.dart**: Manages the live stream of comments for an Ask.

#### 📢 lib/feature/broadcast/
- **broadcast_screen.dart**: List of nearby alerts and news.
- **broadcast_controller.dart**: Handles the creation and radius-streaming of broadcasts.
- **broadcast_discussion_screen.dart**: Live update thread for a broadcast.

#### 🔑 lib/feature/auth/
- **login/ & signup/**: Screens and controllers for Firebase Authentication.

### 📦 lib/model/
- **models.dart**: Definitions for `UserModel`, `AskModel`, `BroadcastModel`, and `AppSettingsModel`.
- **models.g.dart**: Auto-generated JSON serialization code.

### 🛠️ lib/services/
- **firestore_service.dart**: Core logic for Firestore CRUD and Geohash-based radius queries.
- **geo_service.dart**: Manages live GPS tracking, geohash topic subscriptions, and permissions.
- **notification_service.dart**: Handles Firebase Cloud Messaging (FCM) and local push notifications.
- **local_storage_service.dart**: Generic Hive wrapper for persistent key-value caching (e.g., user profile, settings).

### 🔗 lib/utils/
- **app_exports.dart**: Centralized barrel file for common imports to keep code clean.
- **app_messaging.dart**: UI utilities for showing SnackBar alerts and toast messages.

---

## 🛠️ Key Configuration Files
- **main.dart**: The entry point of the app. Initializes Firebase and global providers.
- **firebase_options.dart**: Auto-generated file containing Firebase project credentials.
- **pubspec.yaml**: Project dependencies and asset definitions.
- **PROJECT_DETAILS.md**: High-level technical overview of the project.
- **PROJECT_STATUS.md**: Real-time tracker for implementation progress.
