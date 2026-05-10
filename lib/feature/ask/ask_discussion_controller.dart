import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';

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
    this.item,
    required this.messages,
    required this.isResolved,
    this.isLoading = false,
  });

  final AskModel? item;
  final List<AskDiscussionMessage> messages;
  final bool isResolved;
  final bool isLoading;

  AskDiscussionState copyWith({
    AskModel? item,
    List<AskDiscussionMessage>? messages,
    bool? isResolved,
    bool? isLoading,
  }) {
    return AskDiscussionState(
      item: item ?? this.item,
      messages: messages ?? this.messages,
      isResolved: isResolved ?? this.isResolved,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AskDiscussionController extends Notifier<AskDiscussionState> {
  final TextEditingController replyController = TextEditingController();
  StreamSubscription? _commentsSubscription;

  @override
  AskDiscussionState build() {
    ref.onDispose(() {
      replyController.dispose();
      _commentsSubscription?.cancel();
    });

    return const AskDiscussionState(
      messages: [],
      isResolved: false,
    );
  }

  void initialize(AskModel item) {
    if (state.item?.id == item.id) {
      return;
    }

    state = state.copyWith(item: item, isResolved: item.status == AskStatus.resolved);
    _listenToComments(item.id);
  }

  void _listenToComments(String askId) {
    _commentsSubscription?.cancel();
    _commentsSubscription = FirestoreService.instance.getComments('ask', askId).listen((rawComments) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final List<AskDiscussionMessage> messages = rawComments.map((c) {
        return AskDiscussionMessage(
          id: '', // Firestore ID if needed
          author: c['authorName'] ?? 'Someone',
          text: c['message'] ?? '',
          distanceText: '', // Could calculate if distance is stored in comment
          timeAgo: 'Just now', // Use timeago package or similar
          isCurrentUser: c['userId'] == currentUserId,
        );
      }).toList();
      
      state = state.copyWith(messages: messages.reversed.toList());
    });
  }

  String get locationTitle => 'Nearby User';

  String get locationSubtitle {
    if (state.item == null) return '';
    return 'Active · ${state.item!.replyCount} replies';
  }

  String get userQuestion => state.item?.title ?? '';

  Future<void> sendReply() async {
    final String text = replyController.text.trim();
    if (text.isEmpty || state.item == null) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final authorName = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

    replyController.clear();
    
    await FirestoreService.instance.addComment('ask', state.item!.id, {
      'userId': userId,
      'message': text,
      'authorName': authorName,
    });
  }

  void markResolved() {
    state = state.copyWith(isResolved: true);
    // Ideally update Firestore as well
  }
}

final askDiscussionControllerProvider =
    NotifierProvider<AskDiscussionController, AskDiscussionState>(
      AskDiscussionController.new,
    );
