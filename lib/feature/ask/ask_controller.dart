import 'package:geolinked/utils/app_exports.dart';

enum AskThreadStatus { active, resolved }

class AskHistoryItem {
  const AskHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeAgo,
    required this.distanceKm,
    required this.repliesCount,
    required this.status,
  });

  final String id;
  final String title;
  final String preview;
  final String timeAgo;
  final double distanceKm;
  final int repliesCount;
  final AskThreadStatus status;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'preview': preview,
      'timeAgo': timeAgo,
      'distanceKm': distanceKm,
      'repliesCount': repliesCount,
      'status': status.name,
    };
  }

  factory AskHistoryItem.fromJson(Map<String, dynamic> json) {
    final String statusRaw = (json['status'] as String? ?? 'active').trim();
    return AskHistoryItem(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      preview: (json['preview'] as String? ?? '').trim(),
      timeAgo: (json['timeAgo'] as String? ?? '').trim(),
      distanceKm: (json['distanceKm'] as num? ?? 0).toDouble(),
      repliesCount: (json['repliesCount'] as num? ?? 0).toInt(),
      status: statusRaw == AskThreadStatus.resolved.name
          ? AskThreadStatus.resolved
          : AskThreadStatus.active,
    );
  }
}

class AskState {
  const AskState({required this.items});

  final List<AskHistoryItem> items;
}

class AskController extends Notifier<AskState> {
  static const String _localKey = 'ask_items';
  static const String _apiPath = '/asks';

  static const List<AskHistoryItem> _fallbackItems = <AskHistoryItem>[
    AskHistoryItem(
      id: 'a1',
      title: 'Road open near Nursery chowk?',
      preview: 'I heard there\'s some police activity. Is route clear now?',
      timeAgo: '2 min ago',
      distanceKm: 1.2,
      repliesCount: 2,
      status: AskThreadStatus.active,
    ),
    AskHistoryItem(
      id: 'a2',
      title: 'Water available in Block 7 market?',
      preview: 'Need quick update before heading out. Any live status?',
      timeAgo: '14 min ago',
      distanceKm: 2.6,
      repliesCount: 4,
      status: AskThreadStatus.active,
    ),
    AskHistoryItem(
      id: 'a3',
      title: 'Is sea view side road crowded today?',
      preview: 'Planning family visit after Maghrib. Need traffic update.',
      timeAgo: '38 min ago',
      distanceKm: 4.1,
      repliesCount: 6,
      status: AskThreadStatus.resolved,
    ),
  ];

  @override
  AskState build() {
    return const AskState(items: _fallbackItems);
  }

  String get subtitle => 'Recent questions in your nearby radius';

  Future<void> initialize(BuildContext context) async {
    await _loadLocal(context);
    await _loadApi(context);
  }

  Future<void> _loadLocal(BuildContext context) async {
    final ApiResult<List<AskHistoryItem>> localResult =
        DataFlowService.loadLocal<List<AskHistoryItem>>(
          reader: _readLocalItems,
          emptyMessage: 'No local ask cache found.',
        );

    if (!localResult.success || localResult.data == null) {
      return;
    }

    state = AskState(items: localResult.data!);
    AppMessaging.showInfo(context, 'Loaded ask data from local storage.');
  }

  Future<void> _loadApi(BuildContext context) async {
    final ApiResult<List<AskHistoryItem>> apiResult =
        await DataFlowService.loadApi<List<AskHistoryItem>>(
          request: () => ApiService.instance.get(_apiPath),
          parser: _parseAskItems,
        );

    if (!apiResult.success || apiResult.data == null) {
      AppMessaging.showWarning(
        context,
        apiResult.errorMessage ?? 'Could not sync ask data from server.',
      );
      return;
    }

    state = AskState(items: apiResult.data!);
    await _saveLocal(apiResult.data!);
    AppMessaging.showSuccess(context, 'Ask data synced from server.');
  }

  Future<void> createAsk({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.post(
      _apiPath,
      data: payload,
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not create ask.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Ask created successfully.');
    await _loadApi(context);
  }

  Future<void> updateAsk({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.put(
      '$_apiPath/$id',
      data: payload,
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not update ask.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Ask updated successfully.');
    await _loadApi(context);
  }

  Future<void> deleteAsk({
    required BuildContext context,
    required String id,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.delete(
      '$_apiPath/$id',
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not delete ask.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Ask deleted successfully.');
    await _loadApi(context);
  }

  List<AskHistoryItem>? _readLocalItems() {
    final List<dynamic>? rawList = LocalStorageService.instance
        .get<List<dynamic>>(_localKey);
    if (rawList == null) {
      return null;
    }

    return rawList
        .whereType<Map>()
        .map(
          (Map item) =>
              AskHistoryItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocal(List<AskHistoryItem> items) async {
    final ApiResult<void> saveResult = await DataFlowService.saveLocal(
      writer: () => LocalStorageService.instance.put(
        _localKey,
        items.map((AskHistoryItem item) => item.toJson()).toList(),
      ),
    );

    if (!saveResult.success) {
      // Do not block UX when cache write fails.
    }
  }

  List<AskHistoryItem> _parseAskItems(dynamic payload) {
    final dynamic rawItems = payload is Map<String, dynamic>
        ? payload['data']
        : payload;

    if (rawItems is! List) {
      return const <AskHistoryItem>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (Map item) =>
              AskHistoryItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}

final askControllerProvider = NotifierProvider<AskController, AskState>(
  AskController.new,
);
