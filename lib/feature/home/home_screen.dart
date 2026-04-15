import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_screen.dart';
import 'package:geolinked/feature/broadcast/broadcast_screen.dart';
import 'package:geolinked/feature/home/home_controller.dart';
import 'package:geolinked/feature/profile/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeControllerProvider);
    final HomeController controller = ref.read(homeControllerProvider.notifier);

    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: IndexedStack(
        index: state.currentIndex,
        children: <Widget>[
          _TabPlaceholder(title: 'Map', primary: primary, onSurface: onSurface),
          const AskScreen(),
          const BroadcastScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        items: _items,
        currentIndex: state.currentIndex,
        onTap: controller.setCurrentIndex,
      ),
    );
  }

  static const List<CustomBottomNavigationItem> _items =
      <CustomBottomNavigationItem>[
        CustomBottomNavigationItem(
          icon: Icons.map_outlined,
          label: 'Map',
          activeColor: Color(0xFF12B3B6),
        ),
        CustomBottomNavigationItem(
          icon: Icons.mode_comment_outlined,
          label: 'Ask History',
          activeColor: Color(0xFF7A7F88),
        ),
        CustomBottomNavigationItem(
          icon: Icons.wifi_tethering_outlined,
          label: 'Broadcasts',
          activeColor: Color(0xFF007AFF),
        ),
        CustomBottomNavigationItem(
          icon: Icons.person_outline,
          label: 'Profile',
          activeColor: Color(0xFF2F80ED),
        ),
      ];
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.primary,
    required this.onSurface,
  });

  final String title;
  final Color primary;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.radio_button_checked, color: primary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
