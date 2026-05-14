import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/signup/otp_verification_controller.dart';
import 'package:geolinked/feature/auth/widgets/auth_header_widget.dart';

class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OtpVerificationState state = ref.watch(
      otpVerificationControllerProvider,
    );
    final OtpVerificationController controller = ref.read(
      otpVerificationControllerProvider.notifier,
    );

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String email = args is String && args.isNotEmpty ? args : 'your email';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              AuthHeaderWidget(
                title: 'Verify your email',
                subtitle:
                    'We\'ve sent a verification link to $email. Please click the link to continue.',
              ),
              const SizedBox(height: 40),
              _SpamWarningBox(),
              const SizedBox(height: 24),
              CustomButtonWidget(
                label: state.isSubmitting ? 'Checking...' : 'Check Verification Status',
                onPressed: state.isSubmitting
                    ? null
                    : () => controller.onCheckStatusPressed(context),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: state.isResending
                    ? null
                    : () => controller.onResendPressed(context),
                child: Text(
                  state.isResending ? 'Resending...' : 'Resend Verification Email',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Once you have verified your email, click the button above to start using GeoLinked.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _SpamWarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pro Tip: If you don\'t see the email, please check your Spam or Junk folder.',
              style: TextStyle(
                color: Colors.amber[900],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
