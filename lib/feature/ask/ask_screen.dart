import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_header_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_history_item_widget.dart';

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

                await controller.createAsk(
                  title: result.subject,
                  description: result.question,
                  lat: 24.8607,
                  lng: 67.0011,
                );

                AppMessaging.showSuccess(
                  context,
                  'Query submitted successfully.',
                );
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: state.allAsks.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: divider),
                itemBuilder: (BuildContext context, int index) {
                  final AskModel item = state.allAsks[index];

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
