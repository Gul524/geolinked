import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/login/login_controller.dart';
import 'package:geolinked/feature/auth/widgets/auth_header_widget.dart';
import 'package:geolinked/feature/auth/widgets/auth_switch_prompt_widget.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginController controller = ref.read(
      loginControllerProvider.notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const AuthHeaderWidget(
                title: 'Welcome Back',
                subtitle: 'Login using your email and password.',
              ),
              const SizedBox(height: 26),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppTextField(
                      label: 'Email',
                      hintText: 'name@example.com',
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
                      textInputAction: TextInputAction.done,
                      validator: controller.validatePassword,
                    ),
                    const SizedBox(height: 20),
                    CustomButtonWidget(
                      label: 'Login  ->',
                      onPressed: () => controller.onLoginPressed(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AuthSwitchPromptWidget(
                prefixText: 'Don\'t have an account?',
                actionText: 'Sign up',
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.signup);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
