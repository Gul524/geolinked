import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/profile/profile_controller.dart';
import 'package:geolinked/feature/profile/widgets/helpfulness_score_card_widget.dart';
import 'package:geolinked/feature/profile/widgets/profile_header_widget.dart';
import 'package:geolinked/feature/profile/widgets/profile_section_card_widget.dart';
import 'package:geolinked/feature/profile/widgets/profile_setting_rows_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProfileState state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );

    final Color background = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.06);

    return ColoredBox(
      color: background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              ProfileHeaderWidget(
                name: state.userName,
                handle: state.handle,
                city: state.city,
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: -66,
                child: HelpfulnessScoreCardWidget(
                  score: state.helpfulnessScore,
                  votesThisMonth: state.helpfulVotesThisMonth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 78),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: <Widget>[
                ProfileSectionCardWidget(
                  title: 'RADIUS TUNING',
                  children: <Widget>[
                    RadiusSettingRowWidget(
                      label: 'Ask Radius',
                      displayValue:
                          '${state.askRadiusMeters.toStringAsFixed(0)}m',
                      value: state.askRadiusMeters,
                      min: 100,
                      max: 1000,
                      onChanged: controller.setAskRadiusMeters,
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.09),
                    ),
                    RadiusSettingRowWidget(
                      label: 'Broadcast Radius',
                      displayValue:
                          '${state.broadcastRadiusKm.toStringAsFixed(0)}km',
                      value: state.broadcastRadiusKm,
                      min: 1,
                      max: 30,
                      onChanged: controller.setBroadcastRadiusKm,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ProfileSectionCardWidget(
                  title: 'NOTIFICATIONS',
                  children: <Widget>[
                    ToggleSettingRowWidget(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Alerts for broadcasts nearby',
                      value: state.pushNotificationsEnabled,
                      onChanged: controller.togglePushNotifications,
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.09),
                    ),
                    ActionSettingRowWidget(
                      leading: '🌙',
                      title: 'Quiet Hours',
                      subtitle: state.quietHours,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ProfileSectionCardWidget(
                  title: 'SAFETY',
                  children: <Widget>[
                    ActionSettingRowWidget(
                      leading: '🆘',
                      title: 'Emergency Contacts',
                      subtitle: '${state.emergencyContactCount} contacts added',
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.09),
                    ),
                    ToggleSettingRowWidget(
                      icon: Icons.lock_outline,
                      title: 'Anonymous Mode',
                      subtitle: 'Hide name from responses',
                      value: state.anonymousModeEnabled,
                      onChanged: controller.toggleAnonymousMode,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
