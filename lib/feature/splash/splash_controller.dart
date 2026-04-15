import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/onboarding/onboarding_controller.dart';

class SplashState {
  const SplashState({required this.initialized});

  final bool initialized;

  SplashState copyWith({bool? initialized}) {
    return SplashState(initialized: initialized ?? this.initialized);
  }
}

class SplashController extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState(initialized: false);
  }

  Future<void> initialize(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));

    final bool hasCompletedOnboarding =
        LocalStorageService.instance.get<bool>(
          OnboardingController.onboardingCompletedKey,
        ) ??
        false;

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      hasCompletedOnboarding ? AppRoutes.login : AppRoutes.onboarding,
    );

    state = state.copyWith(initialized: true);
  }
}

final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);
