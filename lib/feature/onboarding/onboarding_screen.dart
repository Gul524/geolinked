import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/onboarding/onboarding_controller.dart';
import 'package:geolinked/feature/onboarding/widgets/onboarding_hero_card_widget.dart';
import 'package:geolinked/feature/onboarding/widgets/onboarding_page_indicator_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController controller = ref.read(
      onboardingControllerProvider.notifier,
    );
    final bool isLastPage = state.currentPage == controller.slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.slides.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    final slide = controller.slides[index];
                    return Column(
                      children: <Widget>[
                        OnboardingHeroCardWidget(pageIndex: index),
                        const SizedBox(height: 28),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.55),
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              OnboardingPageIndicatorWidget(
                count: controller.slides.length,
                currentIndex: state.currentPage,
              ),
              const SizedBox(height: 16),
              CustomButtonWidget(
                label: isLastPage ? 'Get Started' : 'Continue',
                onPressed: () =>
                    controller.onContinuePressed(context, state.currentPage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
