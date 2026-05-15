import 'package:geolinked/feature/broadcast/broadcast_discussion_screen.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_header_widget.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_list_item_widget.dart';
import 'package:geolinked/shared/widgets/shimmer_loading_widget.dart';
import 'package:geolinked/shared/widgets/empty_state_widget.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(broadcastControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final BroadcastState state = ref.watch(broadcastControllerProvider);
    final BroadcastController controller = ref.read(
      broadcastControllerProvider.notifier,
    );

    final Color divider = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.08);

    if (state.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BroadcastHeaderWidget(
                subtitle: 'Finding nearby broadcasts...',
              ),
              Expanded(child: ShimmerLoadingWidget.list(itemHeight: 110)),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              BroadcastHeaderWidget(subtitle: controller.subtitle),
              TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Community'),
                  Tab(text: 'My Alerts'),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildContent(context, state.nearbyBroadcasts, divider),
                    _buildContent(context, state.myBroadcasts, divider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<BroadcastModel> broadcasts,
    Color divider,
  ) {
    if (broadcasts.isEmpty) {
      final bool isNearby =
          broadcasts == ref.read(broadcastControllerProvider).nearbyBroadcasts;
      return EmptyStateWidget(
        icon: Icons.campaign_outlined,
        title: isNearby ? 'No Broadcasts Nearby' : 'No Alerts Sent',
        message: isNearby
            ? 'Stay informed about what is happening around you. Start by sharing an update!'
            : 'You haven\'t shared any alerts yet. Keep your community safe by sharing updates!',
        actionLabel: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(broadcastControllerProvider.notifier).initialize(context);
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: broadcasts.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: divider),
        itemBuilder: (BuildContext context, int index) {
          final BroadcastModel item = broadcasts[index];
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final bool isOwner = item.authorId == currentUserId;

          return BroadcastListItemWidget(
            item: item,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BroadcastDiscussionScreen(item: item),
                ),
              );
            },
            onDelete: isOwner
                ? () async {
                    await ref
                        .read(broadcastControllerProvider.notifier)
                        .deleteBroadcast(item.id);
                    if (context.mounted) {
                      AppMessaging.showSuccess(context, 'Broadcast deleted.');
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}
