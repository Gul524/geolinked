import 'package:geolinked/utils/app_exports.dart';

class LoginState {
  const LoginState({required this.isSubmitting});

  final bool isSubmitting;

  LoginState copyWith({bool? isSubmitting}) {
    return LoginState(isSubmitting: isSubmitting ?? this.isSubmitting);
  }
}

class LoginController extends Notifier<LoginState> {
  static const String _apiPath = '/auth/login';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  LoginState build() {
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
    });

    return const LoginState(isSubmitting: false);
  }

  Future<void> onLoginPressed(BuildContext context) async {
    if (state.isSubmitting) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      AppMessaging.showWarning(context, 'Please fix highlighted fields.');
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final ApiResult<dynamic> result = await ApiService.instance.post(
        _apiPath,
        data: <String, dynamic>{
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (!result.success) {
        AppMessaging.showError(
          context,
          result.errorMessage ?? 'Login failed. Please try again.',
        );
        return;
      }

      final String? token = _extractToken(result.data);
      if (token != null && token.isNotEmpty) {
        ApiService.instance.setAuthToken(token);
        await LocalStorageService.instance.put(
          AppConstants.authTokenKey,
          token,
        );
      }

      AppMessaging.showSuccess(context, 'Login successful. Welcome back!');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
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

  String? _extractToken(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic token =
          payload['token'] ?? payload['accessToken'] ?? payload['authToken'];
      if (token is String && token.isNotEmpty) {
        return token;
      }

      final dynamic data = payload['data'];
      if (data is Map<String, dynamic>) {
        return _extractToken(data);
      }
    }

    return null;
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
