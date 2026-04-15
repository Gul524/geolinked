import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolinked/configs/theme/app_theme.dart';
import 'package:geolinked/configs/providers/theme_provider.dart';
import 'package:geolinked/feature/home/home_screen.dart';
import 'package:geolinked/feature/splash/splash_screen.dart';
import 'package:geolinked/services/local_storage_service.dart';
import 'package:geolinked/services/notification_service.dart';
import 'package:geolinked/utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
