import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/splash/splash_controller.dart';
import 'package:geolinked/feature/splash/widgets/splash_brand_animation_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: surface,
      body: Center(
        child: SplashBrandAnimationWidget(
          primary: primary,
          onSurface: onSurface,
        ),
      ),
    );
  }
}
