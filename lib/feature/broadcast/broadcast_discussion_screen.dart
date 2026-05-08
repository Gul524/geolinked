import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/widgets/ask_reply_input_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_thread_header_widget.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_controller.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_discussion_message_bubble_widget.dart';

class BroadcastDiscussionScreen extends ConsumerStatefulWidget {
  const BroadcastDiscussionScreen({required this.item, super.key});

  final BroadcastItem item;

  @override
  ConsumerState<BroadcastDiscussionScreen> createState() =>
      _BroadcastDiscussionScreenState();
}

class _BroadcastDiscussionScreenState
    extends ConsumerState<BroadcastDiscussionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(broadcastDiscussionControllerProvider.notifier)
          .initialize(context, widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final BroadcastDiscussionState state = ref.watch(
      broadcastDiscussionControllerProvider,
    );
    final BroadcastDiscussionController controller = ref.read(
      broadcastDiscussionControllerProvider.notifier,
    );

    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AskThreadHeaderWidget(
              locationTitle: controller.locationTitle,
              locationSubtitle: controller.locationSubtitle,
              onBackTap: () => Navigator.of(context).pop(),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[primary, const Color(0xFF0B4AA9)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    state.item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.item.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: state.messages
                    .map(
                      (BroadcastDiscussionMessage message) =>
                          BroadcastDiscussionMessageBubbleWidget(
                            message: message,
                          ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AskReplyInputWidget(
        controller: controller.replyController,
        onSend: controller.sendReply,
      ),
    );
  }
}
