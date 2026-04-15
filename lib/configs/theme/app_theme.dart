import 'package:geolinked/utils/app_exports.dart';

class AppIconSizes {
  static const double small = 14;
  static const double medium = 18;
  static const double large = 22;

  const AppIconSizes._();
}

class AppCardRadiusSizes {
  static const double small = 12;
  static const double medium = 18;
  static const double large = 22;

  const AppCardRadiusSizes._();
}

class AppImageSizes {
  static const double small = 48;
  static const double medium = 72;
  static const double large = 96;

  const AppImageSizes._();
}

class AppTheme {
  // iOS system blue as the main app identity color.
  static const Color _lightPrimary = Color(0xFF007AFF);
  static const Color _darkPrimary = Color(0xFF0A84FF);

  static const Color _lightSecondary = Color(0xFF30B0C7);
  static const Color _darkSecondary = Color(0xFF64D2FF);

  static const Color _lightSurface = Color(0xFFF5F7FB);
  static const Color _darkSurface = Color(0xFF12161E);

  static const Color _lightOnSurface = Color(0xFF111827);
  static const Color _darkOnSurface = Color(0xFFF3F4F6);

  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _darkCard = Color(0xFF1B2330);

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      card: _lightCard,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      card: _darkCard,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color onSurface,
    required Color card,
  }) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      cardColor: card,
      textTheme: _textTheme(onSurface),
      iconTheme: const IconThemeData(size: AppIconSizes.medium),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        foregroundColor: onSurface,
        centerTitle: false,
        titleTextStyle: _textTheme(onSurface).titleMedium,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
        titleTextStyle: _textTheme(onSurface).bodyMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      // Compact typography to avoid bold/heavy UI feeling.
      labelSmall: TextStyle(
        fontSize: 8,
        color: color,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: color,
        fontWeight: FontWeight.w400,
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        color: color,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  const AppTheme._();
}
