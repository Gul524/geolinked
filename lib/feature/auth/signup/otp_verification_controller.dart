import 'package:geolinked/utils/app_exports.dart';

class OtpVerificationState {
  const OtpVerificationState({required this.isSubmitting});

  final bool isSubmitting;

  OtpVerificationState copyWith({bool? isSubmitting}) {
    return OtpVerificationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class OtpVerificationController extends Notifier<OtpVerificationState> {
  static const String _apiPath = '/auth/otp/verify';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  @override
  OtpVerificationState build() {
    ref.onDispose(otpController.dispose);
    return const OtpVerificationState(isSubmitting: false);
  }

  Future<void> onVerifyPressed(
    BuildContext context, {
    required String email,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      AppMessaging.showWarning(context, 'Please enter valid OTP code.');
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final ApiResult<dynamic> result = await ApiService.instance.post(
        _apiPath,
        data: <String, dynamic>{
          'email': email,
          'otp': otpController.text.trim(),
        },
      );

      if (!result.success) {
        AppMessaging.showError(
          context,
          result.errorMessage ?? 'OTP verification failed.',
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

      AppMessaging.showSuccess(context, 'Account created for $email');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (Route<dynamic> route) => false,
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  String? validateOtp(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'OTP is required';
    }

    if (input.length != 6) {
      return 'OTP must be 6 digits';
    }

    final bool allDigits = RegExp(r'^\d{6}$').hasMatch(input);
    if (!allDigits) {
      return 'OTP must contain only digits';
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

final otpVerificationControllerProvider =
    NotifierProvider<OtpVerificationController, OtpVerificationState>(
      OtpVerificationController.new,
    );
