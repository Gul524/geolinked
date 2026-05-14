import 'dart:async';
import 'package:geolinked/utils/app_exports.dart';

class OtpVerificationState {
  const OtpVerificationState({
    required this.isSubmitting,
    required this.isResending,
  });

  final bool isSubmitting;
  final bool isResending;

  OtpVerificationState copyWith({bool? isSubmitting, bool? isResending}) {
    return OtpVerificationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
    );
  }
}

class OtpVerificationController extends Notifier<OtpVerificationState> {
  Timer? _timer;

  @override
  OtpVerificationState build() {
    ref.onDispose(() => _timer?.cancel());
    return const OtpVerificationState(isSubmitting: false, isResending: false);
  }

  /// Refreshes the user state to check if email is verified.
  Future<void> onCheckStatusPressed(BuildContext context) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User session lost. Please login again.';

      await user.reload();
      final User? updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.emailVerified ?? false) {
        if (context.mounted) {
          AppMessaging.showSuccess(context, 'Email verified! Welcome to GeoLinked.');
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (context.mounted) {
          AppMessaging.showWarning(context, 'Email not yet verified. Please check your inbox.');
        }
      }
    } catch (e) {
      if (context.mounted) AppMessaging.showError(context, e.toString());
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// Resends the verification email.
  Future<void> onResendPressed(BuildContext context) async {
    state = state.copyWith(isResending: true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Session lost.';

      await user.sendEmailVerification();
      if (context.mounted) {
        AppMessaging.showSuccess(context, 'Verification email resent!');
      }
    } catch (e) {
      if (context.mounted) AppMessaging.showError(context, 'Failed to resend: $e');
    } finally {
      state = state.copyWith(isResending: false);
    }
  }
}

final otpVerificationControllerProvider =
    NotifierProvider<OtpVerificationController, OtpVerificationState>(
  OtpVerificationController.new,
);
