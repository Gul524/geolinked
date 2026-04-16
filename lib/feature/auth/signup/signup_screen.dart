import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/auth/signup/signup_controller.dart';
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
      body: AuthShellWidget(
        title: 'Create an account?',
        footer: AuthSwitchPromptWidget(
          prefixText: 'Already have an account?',
          actionText: 'Login',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: 'Name',
                hintText: 'Johan arindo',
                controller: controller.nameController,
                textInputAction: TextInputAction.next,
                validator: controller.validateName,
              ),
              const SizedBox(height: 14),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButtonWidget(
                label: 'Create account',
                onPressed: () => controller.onSignupPressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
