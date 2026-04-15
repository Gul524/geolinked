import 'package:geolinked/utils/app_exports.dart';

class OtpVerificationState {
  const OtpVerificationState();
}

class OtpVerificationController extends Notifier<OtpVerificationState> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  @override
  OtpVerificationState build() {
    ref.onDispose(otpController.dispose);
    return const OtpVerificationState();
  }

  Future<void> onVerifyPressed(
    BuildContext context, {
    required String email,
  }) async {
    if (!formKey.currentState!.validate()) {
      AppMessaging.showWarning(context, 'Please enter valid OTP code.');
      return;
    }

    AppMessaging.showSuccess(context, 'Account created for $email');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!context.mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
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
}

final otpVerificationControllerProvider =
    NotifierProvider<OtpVerificationController, OtpVerificationState>(
      OtpVerificationController.new,
    );
