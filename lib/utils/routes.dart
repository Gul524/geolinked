import 'package:flutter/material.dart';
import 'package:geolinked/feature/auth/login/login_screen.dart';
import 'package:geolinked/feature/auth/signup/otp_verification_screen.dart';
import 'package:geolinked/feature/auth/signup/signup_screen.dart';
import 'package:geolinked/feature/auth/signup/terms_conditions_screen.dart';
import 'package:geolinked/feature/home/home_screen.dart';
import 'package:geolinked/feature/onboarding/onboarding_screen.dart';
import 'package:geolinked/feature/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = SplashScreen.routeName;
  static const String onboarding = OnboardingScreen.routeName;
  static const String login = LoginScreen.routeName;
  static const String signup = SignupScreen.routeName;
  static const String otp = OtpVerificationScreen.routeName;
  static const String home = HomeScreen.routeName;
  static const String terms = TermsConditionsScreen.routeName;

  const AppRoutes._();
}
