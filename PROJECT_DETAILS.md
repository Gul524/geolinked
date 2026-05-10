# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a Flutter app currently set up with:
- Riverpod-based app state management for global theme mode and user session
- Custom light and dark themes (iOS blue brand direction)
- Animated splash flow
- Home shell with a custom iOS-style bottom navigation bar
- Secure Authentication flow (Login/Signup)
- Global User state management
- **Project Status**: [PROJECT_STATUS.md](file:///home/sulemangul/.gemini/antigravity/brain/6e23af27-db2c-4306-a072-c0ca4be16352/project_status.md) (Task Tracking)

Main entry point: [lib/main.dart](lib/main.dart)

## 2. Tech Stack
- **Flutter**: SDK constraint in [pubspec.yaml](pubspec.yaml)
- **Riverpod 3.x**:
  - Global Theme: [lib/configs/providers/theme_provider.dart](lib/configs/providers/theme_provider.dart)
  - Global User: [lib/configs/providers/user_provider.dart](lib/configs/providers/user_provider.dart)
- **Dio**: API communication in [lib/services/api_service.dart](lib/services/api_service.dart)
- **Hive**: Local storage in [lib/services/local_storage_service.dart](lib/services/local_storage_service.dart)
- **JSON Serializable**: Data models in [lib/model/models.dart](lib/model/models.dart)

## 3. Current App Flow
1. App starts in [lib/main.dart](lib/main.dart)
2. Initial route is splash via [lib/utils/routes.dart](lib/utils/routes.dart)
3. Splash controller waits 2400ms then navigates to home (or onboarding if needed)
4. Home shows a tab shell with custom bottom navigation

Route definitions:
- Splash: [lib/feature/splash/splash_screen.dart](lib/feature/splash/splash_screen.dart)
- Login: [lib/feature/auth/login/login_screen.dart](lib/feature/auth/login/login_screen.dart)
- Signup: [lib/feature/auth/signup/signup_screen.dart](lib/feature/auth/signup/signup_screen.dart)
- Home: [lib/feature/home/home_screen.dart](lib/feature/home/home_screen.dart)

## 4. Authentication Feature
Implemented in `lib/feature/auth`:
- **Login**: [lib/feature/auth/login/login_controller.dart](lib/feature/auth/login/login_controller.dart)
- **Signup**: [lib/feature/auth/signup/signup_controller.dart](lib/feature/auth/signup/signup_controller.dart)
- Uses `AuthResponse` model to handle JWT tokens and basic user info.
- Automatically persists tokens using `LocalStorageService`.

## 5. User Management
Implemented globally via `UserProvider`:
- **Global User State**: Holds the current `UserModel`.
- **API Endpoints**:
  - `GET /api/users/{id}`: Fetch full user profile.
  - `PUT /api/users/{id}/location`: Update user's lat/lng.
  - `PUT /api/users/{id}/notification-id`: Update Firebase Messaging token.
- **Persistence**: User ID and Profile are cached locally for offline support.

## 6. State Management
### Theme Mode
Managed by `themeModeProvider` in [lib/configs/providers/theme_provider.dart](lib/configs/providers/theme_provider.dart).

### User Session
Managed by `userProvider` in [lib/configs/providers/user_provider.dart](lib/configs/providers/user_provider.dart).
- `updateLocation()`: Updates latitude and longitude.
- `updateNotificationId()`: Syncs FCM token to backend.

## 7. Theming System
Centralized in [lib/configs/theme/app_theme.dart](lib/configs/theme/app_theme.dart).
- Primary: iOS blue family.
- Design tokens for icons, radius, and images.

## 8. Shared Components
- **Bottom Navigation**: [lib/shared/widgets/custom_bottom_navigation_bar.dart](lib/shared/widgets/custom_bottom_navigation_bar.dart)
- **App Messaging**: [lib/shared/widgets/app_messaging.dart](lib/shared/widgets/app_messaging.dart) (Toasts/Snackbars)
- **Custom Buttons/Fields**: Standardized UI components.

## 9. Services
- **ApiService**: Dio wrapper with interceptors and error mapping.
- **LocalStorageService**: Hive wrapper for persistent data.
- **NotificationService**: Firebase Messaging integration.
- **GeoService**: Location tracking and geocoding.

## 10. Folder Structure
- `lib/configs`: App configurations, theme, and providers.
- `lib/feature`: Feature-based modules (auth, home, profile, etc.).
- `lib/model`: Data models with JSON serialization.
- `lib/services`: External service integrations.
- `lib/shared`: Reusable widgets.
- `lib/utils`: Helpers, extensions, and route constants.

## 11. Quality Status
- Static analysis: Clean (`flutter analyze lib`).
- Code Generation: Uses `json_serializable` and `build_runner`.

## 12. Firebase Migration Strategy (Fast Track)
To meet the rapid development timeline, the project is migrating from a custom .NET backend to Firebase:
- **Auth**: Firebase Authentication (Email/Password).
- **Database**: Cloud Firestore for real-time geolocation data.
- **Search**: `geoflutterfire2` for radius-based queries.
- **Notifications**: Cloud Functions for triggering radius-based push notifications.

## 13. Next Steps
1. **Infrastructure**: Add `firebase_auth`, `cloud_firestore`, and `geoflutterfire2` dependencies.
2. **Auth**: Migrate `LoginController` and `SignupController` to Firebase Auth.
3. **Data**: Implement Firestore repositories for Asks, Broadcasts, and Comments.
4. **Geo**: Update `GeoService` to sync user location with geohashes to Firestore.
5. **Map**: Implement real-time radius-based querying for map markers.
