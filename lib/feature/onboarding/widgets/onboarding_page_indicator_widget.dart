import 'package:geolinked/utils/app_exports.dart';

class OnboardingPageIndicatorWidget extends StatelessWidget {
  const OnboardingPageIndicatorWidget({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: active ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active
                ? primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
