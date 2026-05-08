import 'package:geolinked/utils/app_exports.dart';

enum BroadcastSeverity { high, medium, info, success }

class BroadcastItem {
  const BroadcastItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.seenCount,
    required this.distanceKm,
    this.verifiedCount,
    required this.emoji,
    required this.severity,
  });

  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final int seenCount;
  final double distanceKm;
  final int? verifiedCount;
  final String emoji;
  final BroadcastSeverity severity;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'timeAgo': timeAgo,
      'seenCount': seenCount,
      'distanceKm': distanceKm,
      'verifiedCount': verifiedCount,
      'emoji': emoji,
      'severity': severity.name,
    };
  }

  factory BroadcastItem.fromJson(Map<String, dynamic> json) {
    final String severityRaw = (json['severity'] as String? ?? 'info').trim();
    return BroadcastItem(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      timeAgo: (json['timeAgo'] as String? ?? '').trim(),
      seenCount: (json['seenCount'] as num? ?? 0).toInt(),
      distanceKm: (json['distanceKm'] as num? ?? 0).toDouble(),
      verifiedCount: (json['verifiedCount'] as num?)?.toInt(),
      emoji: (json['emoji'] as String? ?? '📢').trim(),
      severity: _severityFromString(severityRaw),
    );
  }

  static BroadcastSeverity _severityFromString(String raw) {
    switch (raw) {
      case 'high':
        return BroadcastSeverity.high;
      case 'medium':
        return BroadcastSeverity.medium;
      case 'success':
        return BroadcastSeverity.success;
      case 'info':
      default:
        return BroadcastSeverity.info;
    }
  }
}

class BroadcastState {
  const BroadcastState({required this.items});

  final List<BroadcastItem> items;
}

class BroadcastController extends Notifier<BroadcastState> {
  static const String _localKey = 'broadcast_items';
  static const String _apiPath = '/broadcasts';

  static const List<BroadcastItem> _fallbackItems = <BroadcastItem>[
    BroadcastItem(
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
    BroadcastItem(
      id: 'b2',
      title: 'TRAFFIC JAM',
      message:
          'Heavy traffic on Korangi Road near bridge. Estimate +25 min delay.',
      timeAgo: '11 min ago',
      seenCount: 450,
      distanceKm: 3.4,
      verifiedCount: 51,
      emoji: '🚦',
      severity: BroadcastSeverity.medium,
    ),
    BroadcastItem(
      id: 'b3',
      title: 'MARKET STATUS',
      message:
          'Sunday Bazaar at Clifton is very crowded. Parking full. Better to go after 5pm.',
      timeAgo: '18 min ago',
      seenCount: 189,
      distanceKm: 5.1,
      emoji: '🛒',
      severity: BroadcastSeverity.info,
    ),
    BroadcastItem(
      id: 'b4',
      title: 'UTILITIES',
      message:
          'Power restored in DHA Phase 4. Load shedding ended earlier than schedule.',
      timeAgo: '32 min ago',
      seenCount: 93,
      distanceKm: 7.8,
      emoji: '⚡',
      severity: BroadcastSeverity.success,
    ),
  ];

  @override
  BroadcastState build() {
    return const BroadcastState(items: _fallbackItems);
  }

  String get subtitle => 'Updated now · 10km radius';

  Future<void> initialize(BuildContext context) async {
    await _loadLocal(context);
    await _loadApi(context);
  }

  Future<void> _loadLocal(BuildContext context) async {
    final ApiResult<List<BroadcastItem>> localResult =
        DataFlowService.loadLocal<List<BroadcastItem>>(
          reader: _readLocalItems,
          emptyMessage: 'No local broadcast cache found.',
        );

    if (!localResult.success || localResult.data == null) {
      return;
    }

    state = BroadcastState(items: localResult.data!);
    AppMessaging.showInfo(context, 'Loaded broadcasts from local storage.');
  }

  Future<void> _loadApi(BuildContext context) async {
    final ApiResult<List<BroadcastItem>> apiResult =
        await DataFlowService.loadApi<List<BroadcastItem>>(
          request: () => ApiService.instance.get(_apiPath),
          parser: _parseBroadcastItems,
        );

    if (!apiResult.success || apiResult.data == null) {
      AppMessaging.showWarning(
        context,
        apiResult.errorMessage ?? 'Could not sync broadcasts from server.',
      );
      return;
    }

    state = BroadcastState(items: apiResult.data!);
    await _saveLocal(apiResult.data!);
    AppMessaging.showSuccess(context, 'Broadcasts synced from server.');
  }

  Future<void> createBroadcast({
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
        result.errorMessage ?? 'Could not create broadcast.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Broadcast created successfully.');
    await _loadApi(context);
  }

  Future<void> updateBroadcast({
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
        result.errorMessage ?? 'Could not update broadcast.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Broadcast updated successfully.');
    await _loadApi(context);
  }

  Future<void> deleteBroadcast({
    required BuildContext context,
    required String id,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.delete(
      '$_apiPath/$id',
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not delete broadcast.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Broadcast deleted successfully.');
    await _loadApi(context);
  }

  List<BroadcastItem>? _readLocalItems() {
    final List<dynamic>? rawList = LocalStorageService.instance
        .get<List<dynamic>>(_localKey);
    if (rawList == null) {
      return null;
    }

    return rawList
        .whereType<Map>()
        .map(
          (Map item) => BroadcastItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocal(List<BroadcastItem> items) async {
    final ApiResult<void> saveResult = await DataFlowService.saveLocal(
      writer: () => LocalStorageService.instance.put(
        _localKey,
        items.map((BroadcastItem item) => item.toJson()).toList(),
      ),
    );

    if (!saveResult.success) {
      // Do not block UX when cache write fails.
    }
  }

  List<BroadcastItem> _parseBroadcastItems(dynamic payload) {
    final dynamic rawItems = payload is Map<String, dynamic>
        ? payload['data']
        : payload;

    if (rawItems is! List) {
      return const <BroadcastItem>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (Map item) => BroadcastItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Color severityColor(BuildContext context, BroadcastSeverity severity) {
    switch (severity) {
      case BroadcastSeverity.high:
        return const Color(0xFFFF3B30);
      case BroadcastSeverity.medium:
        return const Color(0xFFFF8A00);
      case BroadcastSeverity.info:
        return const Color(0xFF0D47A1);
      case BroadcastSeverity.success:
        return const Color(0xFF16A34A);
    }
  }
}

final broadcastControllerProvider =
    NotifierProvider<BroadcastController, BroadcastState>(
      BroadcastController.new,
    );
