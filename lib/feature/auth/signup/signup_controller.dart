import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';

class SignupState {
  const SignupState({required this.isSubmitting, required this.termsAccepted});

  final bool isSubmitting;
  final bool termsAccepted;

  SignupState copyWith({bool? isSubmitting, bool? termsAccepted}) {
    return SignupState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}

class SignupController extends Notifier<SignupState> {
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

    return const SignupState(isSubmitting: false, termsAccepted: false);
  }

  void toggleTerms(bool? value) {
    state = state.copyWith(termsAccepted: value ?? false);
  }

  Future<void> onSignupPressed(BuildContext context) async {
    if (state.isSubmitting) return;

    if (!state.termsAccepted) {
      AppMessaging.showWarning(context, 'You must agree to the Terms & Conditions.');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    state = state.copyWith(isSubmitting: true);

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) throw 'Signup failed.';

      await firebaseUser.updateDisplayName(nameController.text.trim());

      // Create profile in Firestore
      final UserModel newUser = UserModel(
        id: firebaseUser.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toJson());

      // Send Email Verification
      await firebaseUser.sendEmailVerification();

      if (context.mounted) {
        AppMessaging.showSuccess(
          context,
          'Account created! Please check your email to verify.',
        );
        Navigator.of(context).pushNamed(
          AppRoutes.otp,
          arguments: emailController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, e.message ?? 'Signup failed.');
      }
    } catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, 'An error occurred: $e');
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  String? validateName(String? value) {
    if ((value ?? '').trim().length < 2) return 'Name is too short';
    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }
}

final signupControllerProvider =
    NotifierProvider<SignupController, SignupState>(SignupController.new);
