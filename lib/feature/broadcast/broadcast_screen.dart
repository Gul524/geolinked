import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_screen.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_header_widget.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_list_item_widget.dart';

class BroadcastScreen extends ConsumerWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            BroadcastHeaderWidget(subtitle: controller.subtitle),
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
