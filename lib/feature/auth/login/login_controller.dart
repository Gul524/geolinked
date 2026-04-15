import 'package:geolinked/utils/app_exports.dart';

class LoginState {
  const LoginState();
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

    return const LoginState();
  }

  Future<void> onLoginPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      AppMessaging.showWarning(context, 'Please fix highlighted fields.');
      return;
    }

    AppMessaging.showSuccess(context, 'Login successful. Welcome back!');
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  String? validateEmail(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Email is required';
    }

    final RegExp emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    if (!emailRegex.hasMatch(input)) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Password is required';
    }

    if (input.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
