import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_header_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_item_widget.dart';

class AskScreen extends ConsumerWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AskState state = ref.watch(askControllerProvider);
    final AskController controller = ref.read(askControllerProvider.notifier);

    final Color divider = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.08);

    return Scaffold(
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

                AppMessaging.showSuccess(
                  context,
                  'Query submitted for ${result.radiusMeters}m nearby people.',
                );
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: divider),
                itemBuilder: (BuildContext context, int index) {
                  final AskHistoryItem item = state.items[index];

                  return AskHistoryItemWidget(
                    item: item,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AskDiscussionScreen(item: item),
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
