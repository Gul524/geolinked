import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/login/login_screen.dart';
import 'package:geolinked/feature/auth/signup/otp_verification_screen.dart';
import 'package:geolinked/feature/auth/signup/signup_screen.dart';
import 'package:geolinked/feature/home/home_screen.dart';
import 'package:geolinked/feature/onboarding/onboarding_screen.dart';
import 'package:geolinked/feature/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  // await NotificationService.instance.initialize();

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
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.otp: (_) => const OtpVerificationScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
