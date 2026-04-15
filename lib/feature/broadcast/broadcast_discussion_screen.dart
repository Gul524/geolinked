import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/widgets/ask_reply_input_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_thread_header_widget.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_controller.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_discussion_message_bubble_widget.dart';

class BroadcastDiscussionScreen extends ConsumerWidget {
  const BroadcastDiscussionScreen({required this.item, super.key});

  final BroadcastItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BroadcastDiscussionState state = ref.watch(
      broadcastDiscussionControllerProvider,
    );
    final BroadcastDiscussionController controller = ref.read(
      broadcastDiscussionControllerProvider.notifier,
    );
    controller.initialize(item);

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
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
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
