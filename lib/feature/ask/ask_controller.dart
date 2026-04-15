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
}

class AskState {
  const AskState({required this.items});

  final List<AskHistoryItem> items;
}

class AskController extends Notifier<AskState> {
  @override
  AskState build() {
    return const AskState(
      items: <AskHistoryItem>[
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
      ],
    );
  }

  String get subtitle => 'Recent questions in your nearby radius';
}

final askControllerProvider = NotifierProvider<AskController, AskState>(
  AskController.new,
);
