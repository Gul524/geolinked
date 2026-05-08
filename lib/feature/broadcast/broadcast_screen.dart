import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_header_widget.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_list_item_widget.dart';

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
      ref.read(broadcastControllerProvider.notifier).initialize(context);
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
    ).colorScheme.onSurface.withValues(alpha: 0.08);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BroadcastHeaderWidget(
              subtitle: controller.subtitle,
              onCreatePressed: () async {
                final result = await BroadcastSheet.showSheet(context);
                if (!context.mounted || result == null) {
                  return;
                }

                AppMessaging.showSuccess(
                  context,
                  '${result.category} broadcast shared in ${result.radiusMeters}m radius.',
                );
              },
            ),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: divider),
                itemBuilder: (BuildContext context, int index) {
                  final item = state.items[index];
                  return BroadcastListItemWidget(
                    item: item,
                    titleColor: controller.severityColor(
                      context,
                      item.severity,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BroadcastDiscussionScreen(item: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
