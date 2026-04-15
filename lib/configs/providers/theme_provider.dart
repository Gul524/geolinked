import 'package:geolinked/utils/app_exports.dart';

/// Manages the app's theme mode state.
/// Supports light, dark, and system modes.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Switch to light theme
  void setLight() => state = ThemeMode.light;

  /// Switch to dark theme
  void setDark() => state = ThemeMode.dark;

  /// Switch to system theme
  void setSystem() => state = ThemeMode.system;

  /// Toggle between light and dark (useful for quick switches)
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
