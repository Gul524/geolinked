import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';

class BroadcastDiscussionMessage {
  const BroadcastDiscussionMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.distanceText,
    required this.timeAgo,
    required this.isCurrentUser,
  });

  final String id;
  final String author;
  final String text;
  final String distanceText;
  final String timeAgo;
  final bool isCurrentUser;
}

class BroadcastDiscussionState {
  const BroadcastDiscussionState({required this.item, required this.messages});

  final BroadcastItem item;
  final List<BroadcastDiscussionMessage> messages;

  BroadcastDiscussionState copyWith({
    BroadcastItem? item,
    List<BroadcastDiscussionMessage>? messages,
  }) {
    return BroadcastDiscussionState(
      item: item ?? this.item,
      messages: messages ?? this.messages,
    );
  }
}

class BroadcastDiscussionController extends Notifier<BroadcastDiscussionState> {
  final TextEditingController replyController = TextEditingController();

  @override
  BroadcastDiscussionState build() {
    ref.onDispose(replyController.dispose);

    return BroadcastDiscussionState(
      item: const BroadcastItem(
        id: 'b1',
        title: 'ROAD BLOCK',
        message:
            'Main Shahrah-e-Faisal is blocked near Nursery. Police activity. Take alternate route.',
        timeAgo: '2 min ago',
        seenCount: 312,
        distanceKm: 1.2,
        verifiedCount: 28,
        emoji: '🚧',
        severity: BroadcastSeverity.high,
      ),
      messages: const <BroadcastDiscussionMessage>[
        BroadcastDiscussionMessage(
          id: 'bd1',
          author: 'Hassan',
          text:
              'Can confirm this update. Traffic police are still managing flow.',
          distanceText: '400m away',
          timeAgo: '1 min ago',
          isCurrentUser: false,
        ),
        BroadcastDiscussionMessage(
          id: 'bd2',
          author: 'You',
          text: 'Thanks for confirmation. Sharing with others nearby.',
          distanceText: '',
          timeAgo: 'Just now',
          isCurrentUser: true,
        ),
      ],
    );
  }

  void initialize(BroadcastItem item) {
    if (state.item.id == item.id) {
      return;
    }

    state = state.copyWith(item: item);
  }

  String get locationTitle => 'Nearby Discussion';

  String get locationSubtitle =>
      '${state.item.distanceKm.toStringAsFixed(1)} km away · ${state.item.timeAgo}';

  void sendReply() {
    final String text = replyController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final List<BroadcastDiscussionMessage> updatedMessages =
        <BroadcastDiscussionMessage>[
          ...state.messages,
          BroadcastDiscussionMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            author: 'You',
            text: text,
            distanceText: '',
            timeAgo: 'Just now',
            isCurrentUser: true,
          ),
        ];

    replyController.clear();
    state = state.copyWith(messages: updatedMessages);
  }
}

final broadcastDiscussionControllerProvider =
    NotifierProvider<BroadcastDiscussionController, BroadcastDiscussionState>(
      BroadcastDiscussionController.new,
    );
