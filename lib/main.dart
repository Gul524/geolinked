import 'package:geolinked/utils/app_exports.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolinked/firebase_options.dart';
import 'package:geolinked/feature/splash/splash_screen.dart';
import 'package:geolinked/feature/onboarding/onboarding_screen.dart';
import 'package:geolinked/feature/auth/login/login_screen.dart';
import 'package:geolinked/feature/auth/signup/signup_screen.dart';
import 'package:geolinked/feature/auth/signup/otp_verification_screen.dart';
import 'package:geolinked/feature/auth/signup/terms_conditions_screen.dart';
import 'package:geolinked/feature/home/home_screen.dart';
import 'package:geolinked/services/background_service.dart';
import 'package:geolinked/feature/profile/privacy_policy_screen.dart';
import 'package:geolinked/utils/app_navigator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalStorageService.instance.init();
  ApiService.instance.setAuthToken(
    LocalStorageService.instance.get<String>(AppConstants.authTokenKey),
  );
  
  // Initialize Notifications
  await NotificationService.instance.initialize();

  // Initialize Background Service
  await BackgroundService.initialize();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'GeoLinked',
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
        AppRoutes.terms: (_) => const TermsConditionsScreen(),
        AppRoutes.privacy: (_) => const PrivacyPolicyScreen(),
      },
    );
  }
}
