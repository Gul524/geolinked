import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/signup/otp_verification_controller.dart';
import 'package:geolinked/feature/auth/widgets/auth_header_widget.dart';

class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OtpVerificationController controller = ref.read(
      otpVerificationControllerProvider.notifier,
    );

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String email = args is String && args.isNotEmpty
        ? args
        : 'your email';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AuthHeaderWidget(
                title: 'Verify OTP',
                subtitle: 'Enter the 6-digit code sent to $email.',
              ),
              const SizedBox(height: 26),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppTextField(
                      label: 'OTP Code',
                      hintText: '000000',
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: controller.validateOtp,
                    ),
                    const SizedBox(height: 20),
                    CustomButtonWidget(
                      label: 'Verify & Create Account',
                      onPressed: () =>
                          controller.onVerifyPressed(context, email: email),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
