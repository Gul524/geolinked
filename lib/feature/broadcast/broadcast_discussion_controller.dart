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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author,
      'text': text,
      'distanceText': distanceText,
      'timeAgo': timeAgo,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory BroadcastDiscussionMessage.fromJson(Map<String, dynamic> json) {
    return BroadcastDiscussionMessage(
      id: (json['id'] as String? ?? '').trim(),
      author: (json['author'] as String? ?? '').trim(),
      text: (json['text'] as String? ?? '').trim(),
      distanceText: (json['distanceText'] as String? ?? '').trim(),
      timeAgo: (json['timeAgo'] as String? ?? '').trim(),
      isCurrentUser: (json['isCurrentUser'] as bool?) ?? false,
    );
  }
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
  static const String _localPrefix = 'broadcast_discussion_';
  static const String _messagesPath = '/broadcasts';
  static const String _repliesPath = '/replies';

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

  Future<void> initialize(BuildContext context, BroadcastItem item) async {
    state = state.copyWith(item: item);
    await _loadLocal(context);
    await _loadApi(context);
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
    _saveLocal();
    _sendReplyToApi(text);
  }

  String get _localKey => '$_localPrefix${state.item.id}';

  Future<void> _loadLocal(BuildContext context) async {
    final ApiResult<Map<String, dynamic>> localResult =
        DataFlowService.loadLocal<Map<String, dynamic>>(
          reader: _readLocalThread,
          emptyMessage: 'No local broadcast thread cache found.',
        );

    if (!localResult.success || localResult.data == null) {
      return;
    }

    final Map<String, dynamic> data = localResult.data!;
    final List<BroadcastDiscussionMessage> messages = _parseMessages(
      data['messages'],
    );

    state = state.copyWith(
      messages: messages.isNotEmpty ? messages : state.messages,
    );
    AppMessaging.showInfo(
      context,
      'Loaded broadcast thread from local storage.',
    );
  }

  Future<void> _loadApi(BuildContext context) async {
    final ApiResult<Map<String, dynamic>> apiResult =
        await DataFlowService.loadApi<Map<String, dynamic>>(
          request: () => ApiService.instance.get(
            '$_messagesPath/${state.item.id}/messages',
          ),
          parser: _parseThreadPayload,
        );

    if (!apiResult.success || apiResult.data == null) {
      AppMessaging.showWarning(
        context,
        apiResult.errorMessage ?? 'Could not sync broadcast thread.',
      );
      return;
    }

    final Map<String, dynamic> data = apiResult.data!;
    state = state.copyWith(messages: _parseMessages(data['messages']));
    _saveLocal();
    AppMessaging.showSuccess(context, 'Broadcast thread synced from server.');
  }

  Future<void> _sendReplyToApi(String text) async {
    await ApiService.instance.post(
      '$_messagesPath/${state.item.id}$_repliesPath',
      data: <String, dynamic>{'text': text},
    );
  }

  Map<String, dynamic>? _readLocalThread() {
    final Map<dynamic, dynamic>? raw = LocalStorageService.instance
        .get<Map<dynamic, dynamic>>(_localKey);
    if (raw == null) {
      return null;
    }

    return Map<String, dynamic>.from(raw);
  }

  Future<void> _saveLocal() async {
    await DataFlowService.saveLocal(
      writer: () =>
          LocalStorageService.instance.put(_localKey, <String, dynamic>{
            'messages': state.messages
                .map((BroadcastDiscussionMessage message) => message.toJson())
                .toList(),
          }),
    );
  }

  Map<String, dynamic> _parseThreadPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }

    return <String, dynamic>{'messages': payload};
  }

  List<BroadcastDiscussionMessage> _parseMessages(dynamic payload) {
    if (payload is! List) {
      return const <BroadcastDiscussionMessage>[];
    }

    return payload
        .whereType<Map>()
        .map(
          (Map item) => BroadcastDiscussionMessage.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }
}

final broadcastDiscussionControllerProvider =
    NotifierProvider<BroadcastDiscussionController, BroadcastDiscussionState>(
      BroadcastDiscussionController.new,
    );
