import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'dart:async';

class NotificationState {
  const NotificationState({
    this.hasUnreadAsks = false,
    this.hasUnreadBroadcasts = false,
    this.lastReceivedAskId,
    this.lastReceivedBroadcastId,
  });

  final bool hasUnreadAsks;
  final bool hasUnreadBroadcasts;
  final String? lastReceivedAskId;
  final String? lastReceivedBroadcastId;

  NotificationState copyWith({
    bool? hasUnreadAsks,
    bool? hasUnreadBroadcasts,
    String? lastReceivedAskId,
    String? lastReceivedBroadcastId,
  }) {
    return NotificationState(
      hasUnreadAsks: hasUnreadAsks ?? this.hasUnreadAsks,
      hasUnreadBroadcasts: hasUnreadBroadcasts ?? this.hasUnreadBroadcasts,
      lastReceivedAskId: lastReceivedAskId ?? this.lastReceivedAskId,
      lastReceivedBroadcastId:
          lastReceivedBroadcastId ?? this.lastReceivedBroadcastId,
    );
  }
}

class AppNotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    // Listen to Asks
    ref.listen(askControllerProvider, (previous, next) {
      if (next.nearbyAsks.isNotEmpty) {
        final latestAsk = next.nearbyAsks.first;
        if (state.lastReceivedAskId != latestAsk.id &&
            previous != null &&
            previous.nearbyAsks.isNotEmpty) {
          
          state = state.copyWith(
            hasUnreadAsks: true,
            lastReceivedAskId: latestAsk.id,
          );
          
          // Trigger in-app notification event
          _triggerNewAskEvent(latestAsk.title);
        } else if (state.lastReceivedAskId == null) {
          state = state.copyWith(lastReceivedAskId: latestAsk.id);
        }
      }
    });

    // Listen to Broadcasts
    ref.listen(broadcastControllerProvider, (previous, next) {
      if (next.nearbyBroadcasts.isNotEmpty) {
        final latestBroadcast = next.nearbyBroadcasts.first;
        if (state.lastReceivedBroadcastId != latestBroadcast.id &&
            previous != null &&
            previous.nearbyBroadcasts.isNotEmpty) {
          
          state = state.copyWith(
            hasUnreadBroadcasts: true,
            lastReceivedBroadcastId: latestBroadcast.id,
          );
          
          _triggerNewBroadcastEvent(latestBroadcast.category);
        } else if (state.lastReceivedBroadcastId == null) {
          state = state.copyWith(lastReceivedBroadcastId: latestBroadcast.id);
        }
      }
    });

    return const NotificationState();
  }

  final _eventController = StreamController<String>.broadcast();
  Stream<String> get notificationEvents => _eventController.stream;

  void _triggerNewAskEvent(String title) {
    _eventController.add('New Ask: $title');
  }

  void _triggerNewBroadcastEvent(String category) {
    _eventController.add('New Alert: $category');
  }

  void markAsksRead() {
    state = state.copyWith(hasUnreadAsks: false);
  }

  void markBroadcastsRead() {
    state = state.copyWith(hasUnreadBroadcasts: false);
  }
}

final notificationControllerProvider =
    NotifierProvider<AppNotificationController, NotificationState>(
  AppNotificationController.new,
);
