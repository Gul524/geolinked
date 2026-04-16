import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/login/login_controller.dart';
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
      body: AuthShellWidget(
        title: 'Welcome back\nLogin now!',
        footer: AuthSwitchPromptWidget(
          prefixText: 'Don\'t have an account?',
          actionText: 'Sign up',
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.signup);
          },
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: 'Email',
                hintText: 'johndoe@gmail.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                hintText: '********',
                controller: controller.passwordController,
                isPasswordField: true,
                textInputAction: TextInputAction.done,
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: false,
                    onChanged: (_) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Remember me',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButtonWidget(
                label: 'Login',
                onPressed: () => controller.onLoginPressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
