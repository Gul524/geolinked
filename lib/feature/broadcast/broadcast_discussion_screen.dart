import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_controller.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_discussion_message_bubble_widget.dart';
import 'package:geolinked/feature/broadcast/widgets/broadcast_header_widget.dart';
import 'package:geolinked/shared/widgets/full_screen_viewer.dart';

class BroadcastDiscussionScreen extends ConsumerStatefulWidget {
  const BroadcastDiscussionScreen({required this.item, super.key});

  final BroadcastModel item;

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
          .initialize(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final BroadcastDiscussionState state =
        ref.watch(broadcastDiscussionControllerProvider);
    final BroadcastDiscussionController controller = ref.read(
      broadcastDiscussionControllerProvider.notifier,
    );

    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BroadcastHeaderWidget(
              subtitle: 'Local Broadcast Update',
              onBackTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: <Widget>[
                  // Broadcast Details Card
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (state.item?.imageUrl != null)
                            GestureDetector(
                              onTap: () => FullScreenImageViewer.show(
                                context,
                                state.item!.imageUrl!,
                                heroTag: 'broadcast_detail_${state.item!.id}',
                              ),
                              child: Hero(
                                tag: 'broadcast_detail_${state.item!.id}',
                                child: Image.network(
                                  state.item!.imageUrl!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        state.item?.category.toUpperCase() ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.item?.verifiedCount ?? 0} verified',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.item?.message ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Divider(color: Colors.white.withOpacity(0.15)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.visibility_outlined,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Seen by ${state.item?.seenCount ?? 0} people nearby',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Discussion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (state.messages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No comments yet. Be the first to reply!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ...state.messages.map(
                    (BroadcastDiscussionMessage message) =>
                        BroadcastDiscussionMessageBubbleWidget(
                      message: message,
                      onDelete: message.isCurrentUser
                          ? () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Comment?'),
                                  content: const Text(
                                      'Are you sure you want to delete this comment?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await controller.deleteComment(message.id);
                                if (context.mounted) {
                                  AppMessaging.showSuccess(
                                      context, 'Comment deleted.');
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            // Reply Input
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.replyController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: controller.sendReply,
                    icon: Icon(Icons.send_rounded, color: primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
