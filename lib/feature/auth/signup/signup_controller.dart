import 'package:geolinked/utils/app_exports.dart';

class SignupState {
  const SignupState({required this.isSubmitting});

  final bool isSubmitting;

  SignupState copyWith({bool? isSubmitting}) {
    return SignupState(isSubmitting: isSubmitting ?? this.isSubmitting);
  }
}

class SignupController extends Notifier<SignupState> {
  static const String _apiPath = '/auth/signup';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  SignupState build() {
    ref.onDispose(() {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });

    return const SignupState(isSubmitting: false);
  }

  Future<void> onSignupPressed(BuildContext context) async {
    if (state.isSubmitting) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      AppMessaging.showWarning(context, 'Please complete all required fields.');
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final ApiResult<dynamic> result = await ApiService.instance.post(
        _apiPath,
        data: <String, dynamic>{
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (!result.success) {
        AppMessaging.showError(
          context,
          result.errorMessage ?? 'Signup failed. Please try again.',
        );
        return;
      }

      AppMessaging.showSuccess(
        context,
        'Signup details sent for verification.',
      );
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.otp, arguments: emailController.text.trim());
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  String? validateName(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Name is required';
    }

    if (input.length < 2) {
      return 'Name is too short';
    }

    return null;
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

  String? validateConfirmPassword(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Confirm your password';
    }

    if (input != passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }
}

final signupControllerProvider =
    NotifierProvider<SignupController, SignupState>(SignupController.new);
