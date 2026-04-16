import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/home/home_controller.dart';
import 'package:geolinked/feature/profile/profile_controller.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
import 'package:geolinked/feature/map/map_widget.dart';

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
        CustomBottomNavigationItem(icon: AppIcons.home, label: 'Home'),
        CustomBottomNavigationItem(icon: AppIcons.chat, label: 'Ask History'),
        CustomBottomNavigationItem(
          icon: AppIcons.broadcast,
          label: 'Broadcasts',
        ),
        CustomBottomNavigationItem(icon: AppIcons.profile, label: 'Profile'),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _FABButton(
            onPressed: onAskPressed,
            label: 'Ask',
            subtitle: '${profileState.askRadiusMeters.toStringAsFixed(0)}m',
            icon: AppIcons.ask,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _FABButton(
            onPressed: onBroadcastPressed,
            label: 'Broadcast',
            subtitle: '${profileState.broadcastRadiusKm.toStringAsFixed(1)}km',
            icon: AppIcons.broadcast,
            color: Colors.blue,
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
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: 70,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: AppIconSizes.medium, color: color),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
