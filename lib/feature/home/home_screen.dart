import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/home/home_controller.dart';
import 'package:geolinked/feature/profile/profile_controller.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
import 'package:geolinked/feature/home/widgets/home_map_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeControllerProvider);
    final HomeController controller = ref.read(homeControllerProvider.notifier);
    final ProfileState profileState = ref.watch(profileControllerProvider);

    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: IndexedStack(
        index: state.currentIndex,
        children: <Widget>[
          const HomeMapWidget(),
          const AskScreen(),
          const BroadcastScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: state.currentIndex == 0
          ? _FABColumn(
              profileState: profileState,
              onAskPressed: () async {
                final result = await AskSheet.showSheet(context);
                if (!context.mounted || result == null) return;
                AppMessaging.showSuccess(
                  context,
                  'Query submitted for ${result.radiusMeters}m nearby people.',
                );
              },
              onBroadcastPressed: () async {
                final result = await BroadcastSheet.showSheet(context);
                if (!context.mounted || result == null) return;
                AppMessaging.showSuccess(
                  context,
                  '${result.category} broadcast shared in ${result.radiusMeters}m radius.',
                );
              },
            )
          : null,
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

class _FABColumn extends StatelessWidget {
  const _FABColumn({
    required this.profileState,
    required this.onAskPressed,
    required this.onBroadcastPressed,
  });

  final ProfileState profileState;
  final VoidCallback onAskPressed;
  final VoidCallback onBroadcastPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _FABButton(
            onPressed: onAskPressed,
            label: 'Ask',
            subtitle: '${profileState.askRadiusMeters.toStringAsFixed(0)}m',
            icon: Icons.mode_comment_outlined,
            color: const Color(0xFF7A7F88),
          ),
          const SizedBox(width: 12),
          _FABButton(
            onPressed: onBroadcastPressed,
            label: 'Broadcast',
            subtitle: '${profileState.broadcastRadiusKm.toStringAsFixed(1)}km',
            icon: Icons.wifi_tethering_outlined,
            color: const Color(0xFF007AFF),
          ),
        ],
      ),
    );
  }
}

class _FABButton extends StatelessWidget {
  const _FABButton({
    required this.onPressed,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final VoidCallback onPressed;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      backgroundColor: color.withValues(alpha: 0.1),
      foregroundColor: color,
      icon: Icon(icon, color: color),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
