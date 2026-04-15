import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/signup/signup_controller.dart';
import 'package:geolinked/feature/auth/widgets/auth_header_widget.dart';
import 'package:geolinked/feature/auth/widgets/auth_switch_prompt_widget.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SignupController controller = ref.read(
      signupControllerProvider.notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const AuthHeaderWidget(
                title: 'Create Account',
                subtitle: 'Sign up with name, email and password.',
              ),
              const SizedBox(height: 26),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppTextField(
                      label: 'Full Name',
                      hintText: 'Enter your name',
                      controller: controller.nameController,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Gmail',
                      hintText: 'name@gmail.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Password',
                      hintText: 'Enter password',
                      controller: controller.passwordController,
                      isPasswordField: true,
                      textInputAction: TextInputAction.next,
                      validator: controller.validatePassword,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter password',
                      controller: controller.confirmPasswordController,
                      isPasswordField: true,
                      textInputAction: TextInputAction.done,
                      validator: controller.validateConfirmPassword,
                    ),
                    const SizedBox(height: 20),
                    CustomButtonWidget(
                      label: 'Continue',
                      onPressed: () => controller.onSignupPressed(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AuthSwitchPromptWidget(
                prefixText: 'Already have an account?',
                actionText: 'Login',
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
