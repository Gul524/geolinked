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
}

class BroadcastState {
  const BroadcastState({required this.items});

  final List<BroadcastItem> items;
}

class BroadcastController extends Notifier<BroadcastState> {
  @override
  BroadcastState build() {
    return const BroadcastState(
      items: <BroadcastItem>[
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
      ],
    );
  }

  String get subtitle => 'Updated now · 10km radius';

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
