import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';

class AskDiscussionMessage {
  const AskDiscussionMessage({
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

class AskDiscussionState {
  const AskDiscussionState({
    required this.item,
    required this.messages,
    required this.isResolved,
  });

  final AskHistoryItem item;
  final List<AskDiscussionMessage> messages;
  final bool isResolved;

  AskDiscussionState copyWith({
    AskHistoryItem? item,
    List<AskDiscussionMessage>? messages,
    bool? isResolved,
  }) {
    return AskDiscussionState(
      item: item ?? this.item,
      messages: messages ?? this.messages,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class AskDiscussionController extends Notifier<AskDiscussionState> {
  final TextEditingController replyController = TextEditingController();

  @override
  AskDiscussionState build() {
    ref.onDispose(replyController.dispose);

    return AskDiscussionState(
      item: const AskHistoryItem(
        id: 'a1',
        title: 'Road open near Nursery chowk?',
        preview: 'I heard there\'s some police activity. Is route clear now?',
        timeAgo: '2 min ago',
        distanceKm: 1.2,
        repliesCount: 2,
        status: AskThreadStatus.active,
      ),
      messages: const <AskDiscussionMessage>[
        AskDiscussionMessage(
          id: 'm1',
          author: 'Ali R.',
          text:
              'Yes, there\'s a blockade near the petrol pump. Police set up a check post. You can divert from old Sabzi Mandi road.',
          distanceText: '250m away',
          timeAgo: '2 min ago',
          isCurrentUser: false,
        ),
        AskDiscussionMessage(
          id: 'm2',
          author: 'Sara M.',
          text:
              'Can confirm. Was there 5 mins ago. Alternate route via Old Sabzi Mandi is clear.',
          distanceText: '180m away',
          timeAgo: '1 min ago',
          isCurrentUser: false,
        ),
      ],
      isResolved: false,
    );
  }

  void initialize(AskHistoryItem item) {
    if (state.item.id == item.id) {
      return;
    }

    state = state.copyWith(item: item, isResolved: false);
  }

  String get locationTitle => 'Nursery, Shahrah-e-Faisal';

  String get locationSubtitle =>
      '${state.item.distanceKm.toStringAsFixed(1)} km away · 300m radius · Active';

  String get userQuestion => state.item.title;

  void sendReply() {
    final String text = replyController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final List<AskDiscussionMessage> updatedMessages = <AskDiscussionMessage>[
      ...state.messages,
      AskDiscussionMessage(
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

  void markResolved() {
    state = state.copyWith(isResolved: true);
  }
}

final askDiscussionControllerProvider =
    NotifierProvider<AskDiscussionController, AskDiscussionState>(
      AskDiscussionController.new,
    );
