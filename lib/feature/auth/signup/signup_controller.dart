import 'package:geolinked/configs/providers/user_provider.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';

class SignupState {
  const SignupState({required this.isSubmitting});

  final bool isSubmitting;

  SignupState copyWith({bool? isSubmitting}) {
    return SignupState(isSubmitting: isSubmitting ?? this.isSubmitting);
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
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Signup failed. User could not be created.';
      }

      // Update display name
      await firebaseUser.updateDisplayName(nameController.text.trim());

      // Create user profile in Firestore
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

      // Set global user state
      ref.read(userProvider.notifier).setUser(newUser);

      if (context.mounted) {
        AppMessaging.showSuccess(context, 'Account created successfully!');

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, e.message ?? 'Signup failed.');
      }
    } catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, 'An unexpected error occurred: $e');
      }
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
