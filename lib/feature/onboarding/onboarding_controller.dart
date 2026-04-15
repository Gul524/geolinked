import 'package:geolinked/utils/app_exports.dart';

class OnboardingState {
  const OnboardingState({required this.currentPage});

  final int currentPage;

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }
}

class OnboardingSlideData {
  const OnboardingSlideData({required this.title, required this.description});

  final String title;
  final String description;
}

class OnboardingController extends Notifier<OnboardingState> {
  static const String onboardingCompletedKey = 'onboarding_completed';

  final PageController pageController = PageController();

  @override
  OnboardingState build() {
    ref.onDispose(pageController.dispose);
    return const OnboardingState(currentPage: 0);
  }

  List<OnboardingSlideData> get slides => const <OnboardingSlideData>[
    OnboardingSlideData(
      title: "Know what's happening around you, instantly.",
      description:
          'See live traffic, road blocks, market conditions, and safety alerts shared by real people nearby.',
    ),
    OnboardingSlideData(
      title: 'Ask, report, and stay connected with your city.',
      description:
          'Post local updates, ask for help, and get trusted location-based responses in real time.',
    ),
  ];

  void onPageChanged(int index) {
    if (index == state.currentPage) {
      return;
    }

    state = state.copyWith(currentPage: index);
  }

  Future<void> onContinuePressed(BuildContext context, int currentPage) async {
    final bool isLastPage = currentPage == slides.length - 1;
    if (isLastPage) {
      await LocalStorageService.instance.put(onboardingCompletedKey, true);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
