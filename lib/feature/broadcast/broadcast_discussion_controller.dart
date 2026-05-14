import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';

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
  const BroadcastDiscussionState({
    this.item,
    required this.messages,
    this.isLoading = false,
  });

  final BroadcastModel? item;
  final List<BroadcastDiscussionMessage> messages;
  final bool isLoading;

  BroadcastDiscussionState copyWith({
    BroadcastModel? item,
    List<BroadcastDiscussionMessage>? messages,
    bool? isLoading,
  }) {
    return BroadcastDiscussionState(
      item: item ?? this.item,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BroadcastDiscussionController extends Notifier<BroadcastDiscussionState> {
  final TextEditingController replyController = TextEditingController();
  StreamSubscription? _commentsSubscription;

  @override
  BroadcastDiscussionState build() {
    ref.onDispose(() {
      replyController.dispose();
      _commentsSubscription?.cancel();
    });

    return const BroadcastDiscussionState(
      messages: [],
    );
  }

  void initialize(BroadcastModel item) {
    if (state.item?.id == item.id) {
      return;
    }

    state = state.copyWith(item: item);
    
    // Increment view count
    FirestoreService.instance.incrementViewCount('broadcast', item.id);
    
    _listenToComments(item.id);
  }

  void _listenToComments(String broadcastId) {
    _commentsSubscription?.cancel();
    _commentsSubscription = FirestoreService.instance.getComments('broadcast', broadcastId).listen((rawComments) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final List<BroadcastDiscussionMessage> messages = rawComments.map((c) {
        return BroadcastDiscussionMessage(
          id: c['id'] ?? '',
          author: c['authorName'] ?? 'Someone',
          text: c['message'] ?? '',
          distanceText: '',
          timeAgo: 'Just now',
          isCurrentUser: c['userId'] == currentUserId,
        );
      }).toList();
      
      state = state.copyWith(messages: messages.reversed.toList());
    });
  }

  String get locationTitle => 'Broadcast Update';

  String get locationSubtitle {
    if (state.item == null) return '';
    return 'Nearby · ${state.item!.seenCount} seen';
  }

  Future<void> sendReply() async {
    final String text = replyController.text.trim();
    if (text.isEmpty || state.item == null) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final authorName = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

    replyController.clear();
    
    await FirestoreService.instance.addComment('broadcast', state.item!.id, {
      'userId': userId,
      'message': text,
      'authorName': authorName,
    });
  }

  Future<void> deleteComment(String commentId) async {
    if (state.item == null) return;
    await FirestoreService.instance
        .deleteComment('broadcast', state.item!.id, commentId);
  }
}

final broadcastDiscussionControllerProvider =
    NotifierProvider<BroadcastDiscussionController, BroadcastDiscussionState>(
      BroadcastDiscussionController.new,
    );
