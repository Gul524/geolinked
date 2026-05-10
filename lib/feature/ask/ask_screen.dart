import 'package:geolinked/feature/ask/ask_discussion_screen.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_header_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_item_widget.dart';
import 'package:geolinked/shared/widgets/shimmer_loading_widget.dart';
import 'package:geolinked/shared/widgets/empty_state_widget.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(askControllerProvider.notifier).initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AskState state = ref.watch(askControllerProvider);
    final AskController controller = ref.read(askControllerProvider.notifier);

    final Color divider = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.08);

    if (state.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AskHistoryHeaderWidget(
                subtitle: 'Finding nearby queries...',
              ),
              Expanded(child: ShimmerLoadingWidget.list(itemHeight: 120)),
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
              AskHistoryHeaderWidget(
                subtitle: controller.subtitle,
                onCreatePressed: () async {
                  final result = await AskSheet.showSheet(context);
                  if (!context.mounted || result == null) {
                    return;
                  }

                  await controller.createAsk(
                    title: result.subject,
                    description: result.question,
                    lat: 24.8607,
                    lng: 67.0011,
                    imageUrl: result.imageUrl,
                  );

                  AppMessaging.showSuccess(
                    context,
                    'Query submitted successfully.',
                  );
                },
              ),
              TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Community'),
                  Tab(text: 'My Asks'),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildContent(context, state.nearbyAsks, divider),
                    _buildContent(context, state.myAsks, divider),
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
      BuildContext context, List<AskModel> asks, Color divider) {
    if (asks.isEmpty) {
      final bool isNearby = asks == ref.read(askControllerProvider).nearbyAsks;
      return EmptyStateWidget(
        icon: Icons.help_outline_rounded,
        title: isNearby ? 'No Asks Nearby' : 'No Asks Sent',
        message: isNearby
            ? 'Nobody around you has asked anything yet. Be the first!'
            : 'You haven\'t asked any questions yet. Tap the button to start!',
        actionLabel: isNearby ? null : 'Ask Now',
        onAction: isNearby
            ? null
            : () async {
                final result = await AskSheet.showSheet(context);
                if (result != null) {
                  ref.read(askControllerProvider.notifier).createAsk(
                        title: result.subject,
                        description: result.question,
                        lat: 24.8607,
                        lng: 67.0011,
                        imageUrl: result.imageUrl,
                      );
                }
              },
      );
    }

    return RefreshIndicator(
      onRefresh: () async{
          ref.read(askControllerProvider.notifier).initialize(context);},
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: asks.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: divider),
        itemBuilder: (BuildContext context, int index) {
          final AskModel item = asks[index];

          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final bool isOwner = item.userId == currentUserId;

          return AskHistoryItemWidget(
            item: item,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AskDiscussionScreen(item: item),
                ),
              );
            },
            onDelete: isOwner
                ? () async {
                    await ref
                        .read(askControllerProvider.notifier)
                        .deleteAsk(item.id);
                    if (context.mounted) {
                      AppMessaging.showSuccess(context, 'Post deleted.');
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}
