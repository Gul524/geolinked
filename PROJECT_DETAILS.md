# GeoLinked Project Details

## 1. Project Overview
GeoLinked is a Flutter app currently set up with:
- Riverpod-based app state management for global theme mode
- Custom light and dark themes (iOS blue brand direction)
- Animated splash flow
- Home shell with a custom iOS-style bottom navigation bar

Main entry point: [lib/main.dart](lib/main.dart)

## 2. Tech Stack
- Flutter (SDK constraint in [pubspec.yaml](pubspec.yaml))
- Riverpod 3.x:
  - [pubspec.yaml](pubspec.yaml)
  - [lib/configs/providers/theme_provider.dart](lib/configs/providers/theme_provider.dart)
- Material 3 theme setup:
  - [lib/configs/theme/app_theme.dart](lib/configs/theme/app_theme.dart)

## 3. Current App Flow
1. App starts in [lib/main.dart](lib/main.dart)
2. Initial route is splash via [lib/utils/routes.dart](lib/utils/routes.dart)
3. Splash controller waits 2400ms then navigates to home
4. Home shows a tab shell with custom bottom navigation

Route definitions:
- Splash route: [lib/feature/splash/splash_screen.dart](lib/feature/splash/splash_screen.dart)
- Home route: [lib/feature/home/home_screen.dart](lib/feature/home/home_screen.dart)
- Route constants: [lib/utils/routes.dart](lib/utils/routes.dart)

## 4. State Management
### Theme Mode
Theme mode is managed globally by Riverpod:
- Provider: [lib/configs/providers/theme_provider.dart](lib/configs/providers/theme_provider.dart)
- Exposed API:
  - setLight()
  - setDark()
  - setSystem()
  - toggle()

App root reads this provider in [lib/main.dart](lib/main.dart) and applies:
- theme
- darkTheme
- themeMode

## 5. Theming System
Theme implementation is centralized in [lib/configs/theme/app_theme.dart](lib/configs/theme/app_theme.dart).

### Color strategy
- Primary: iOS blue family
- Secondary, Surface, OnSurface, Card colors for both light and dark modes

### Design tokens
- Icon size tokens: AppIconSizes
- Card radius tokens: AppCardRadiusSizes
- Image size tokens: AppImageSizes

### Typography
Compact text scale is used to keep visual weight light:
- 8 to 24 size range across label/body/title/headline styles

## 6. Splash Feature
Files:
- Screen: [lib/feature/splash/splash_screen.dart](lib/feature/splash/splash_screen.dart)
- Controller: [lib/feature/splash/splash_controller.dart](lib/feature/splash/splash_controller.dart)
- Animation widget: [lib/feature/splash/widgets/splash_brand_animation_widget.dart](lib/feature/splash/widgets/splash_brand_animation_widget.dart)

What it does:
- Uses theme colors inside build method (primary/surface/onSurface)
- Runs entrance animation (fade, slide, scale)
- Shows animated linear loading progress
- Controller handles delayed navigation to home

## 7. Home + Bottom Navigation
### Home shell
Implemented in [lib/feature/home/home_screen.dart](lib/feature/home/home_screen.dart):
- Uses IndexedStack for tab body switching
- Tracks selected tab index locally
- Uses custom shared bottom navigation component

### Shared bottom navigation
Implemented in [lib/shared/widgets/custom_bottom_navigation_bar.dart](lib/shared/widgets/custom_bottom_navigation_bar.dart):
- iOS-style bottom bar visual treatment
- Supports active/inactive icon colors per item
- Uses modularized components:
  - CustomBottomNavigationItem (item model)
  - BottomNavRoundIcon (icon rendering)
  - CustomBottomNavigationBar (navigation behavior and tap callback)

Current tabs:
- Map
- Ask History
- Broadcasts
- Profile

## 8. Shared Exports
Barrel exports are defined in [lib/utils/exports.dart](lib/utils/exports.dart) for easier imports.

## 9. Current Folder Status
Core implemented areas:
- App bootstrap and routing
- Theme system
- Splash flow
- Home shell + custom bottom nav

Feature folders exist but are not yet implemented in depth:
- [lib/feature/ask](lib/feature/ask)
- [lib/feature/auth](lib/feature/auth)
- [lib/feature/broadcast](lib/feature/broadcast)
- [lib/feature/chat](lib/feature/chat)
- [lib/feature/map](lib/feature/map)
- [lib/feature/profile](lib/feature/profile)

## 10. Build and Quality Status
Most recent static analysis status is clean:
- flutter analyze lib -> No issues found

## 11. Suggested Next Steps
1. Replace placeholder tab bodies with real feature screens
2. Move tab index state to Riverpod if cross-screen persistence is needed
3. Add named route map for each feature module
4. Add test coverage for:
   - Splash navigation timing behavior
   - Theme mode provider transitions
   - Bottom navigation tab switch behavior
5. Expand README summary with setup/run instructions and architecture snapshot
