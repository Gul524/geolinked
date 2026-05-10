import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_discussion_controller.dart';
import 'package:geolinked/feature/ask/widgets/ask_message_bubble_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_question_card_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_reply_input_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_resolve_banner_widget.dart';
import 'package:geolinked/feature/ask/widgets/ask_thread_header_widget.dart';

class AskDiscussionScreen extends ConsumerStatefulWidget {
  const AskDiscussionScreen({required this.item, super.key});

  final AskModel item;

  @override
  ConsumerState<AskDiscussionScreen> createState() =>
      _AskDiscussionScreenState();
}

class _AskDiscussionScreenState extends ConsumerState<AskDiscussionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(askDiscussionControllerProvider.notifier)
          .initialize(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AskDiscussionState state = ref.watch(askDiscussionControllerProvider);
    final AskDiscussionController controller = ref.read(
      askDiscussionControllerProvider.notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AskThreadHeaderWidget(
              locationTitle: controller.locationTitle,
              locationSubtitle: controller.locationSubtitle,
              onBackTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: <Widget>[
                  AskQuestionCardWidget(item: widget.item),
                  ...state.messages.map(
                    (AskDiscussionMessage message) =>
                        AskMessageBubbleWidget(message: message),
                  ),
                  AskResolveBannerWidget(
                    resolved: state.isResolved,
                    onPressed: controller.markResolved,
                  ),
                ],
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
