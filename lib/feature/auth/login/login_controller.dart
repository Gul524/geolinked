import 'package:geolinked/configs/providers/user_provider.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';

class LoginState {
  const LoginState({required this.isSubmitting, required this.rememberMe});

  final bool isSubmitting;
  final bool rememberMe;

  LoginState copyWith({bool? isSubmitting, bool? rememberMe}) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
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

    return const LoginState(isSubmitting: false, rememberMe: true);
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
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Login failed. User not found.';
      }

      // Fetch user details from Firestore
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        final UserModel newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());
        ref.read(userProvider.notifier).setUser(newUser);
      } else {
        final UserModel user =
            UserModel.fromJson(doc.data() as Map<String, dynamic>);
        ref.read(userProvider.notifier).setUser(user);
      }

      if (context.mounted) {
        AppMessaging.showSuccess(context, 'Login successful. Welcome back!');
      }

      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, e.message ?? 'Authentication failed.');
      }
    } catch (e) {
      if (context.mounted) {
        AppMessaging.showError(context, 'An unexpected error occurred: $e');
      }
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

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
