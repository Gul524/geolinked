import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolinked/shared/widgets/app_messaging.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/services/notification_service.dart';

class LoginState {
  const LoginState({required this.isSubmitting, required this.rememberMe});

  final bool isSubmitting;
  final bool rememberMe;

  LoginState copyWith({bool? isSubmitting, bool? rememberMe}) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginController extends Notifier<LoginState> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  LoginState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });

    return const LoginState(isSubmitting: false, rememberMe: true);
  }

  Future<void> onLoginPressed(BuildContext context) async {
    if (state.isSubmitting) return;

    if (!formKey.currentState!.validate()) return;

    state = state.copyWith(isSubmitting: true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (context.mounted) {
        // Save FCM token to database
        NotificationService.instance.saveTokenToDatabase();
        
        AppMessaging.showSuccess(context, 'Welcome back!');
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) AppMessaging.showError(context, e.message ?? 'Login failed.');
    } catch (e) {
      if (context.mounted) AppMessaging.showError(context, 'An error occurred: $e');
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  String? validateEmail(String? value) {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value ?? '')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Password must be 6+ chars';
    return null;
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
