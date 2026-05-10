import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';

class BroadcastState {
  const BroadcastState({required this.nearbyBroadcasts, required this.myBroadcasts});

  final List<BroadcastModel> nearbyBroadcasts;
  final List<BroadcastModel> myBroadcasts;

  BroadcastState copyWith({
    List<BroadcastModel>? nearbyBroadcasts,
    List<BroadcastModel>? myBroadcasts,
  }) {
    return BroadcastState(
      nearbyBroadcasts: nearbyBroadcasts ?? this.nearbyBroadcasts,
      myBroadcasts: myBroadcasts ?? this.myBroadcasts,
    );
  }
}

class BroadcastController extends Notifier<BroadcastState> {
  StreamSubscription? _nearbySubscription;
  StreamSubscription? _myBroadcastsSubscription;

  @override
  BroadcastState build() {
    ref.onDispose(() {
      _nearbySubscription?.cancel();
      _myBroadcastsSubscription?.cancel();
    });

    _initListeners();

    return const BroadcastState(nearbyBroadcasts: [], myBroadcasts: []);
  }

  void _initListeners() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _myBroadcastsSubscription = FirestoreService.instance.broadcasts
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => BroadcastModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList())
          .listen((items) {
        state = state.copyWith(myBroadcasts: items);
      });
    }

    _nearbySubscription = FirestoreService.instance.getNearbyBroadcasts(
      latitude: 24.8607,
      longitude: 67.0011,
      radiusKm: 10,
    ).listen((items) {
      state = state.copyWith(nearbyBroadcasts: items);
    });
  }

  Future<void> createBroadcast({
    required String title,
    required String message,
    required double lat,
    required double lng,
    double radiusKm = 10,
    BroadcastSeverity severity = BroadcastSeverity.info,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final broadcast = BroadcastModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: userId,
      title: title,
      message: message,
      latitude: lat,
      longitude: lng,
      radiusKm: radiusKm,
      severity: severity,
      createdAt: DateTime.now(),
    );

    await FirestoreService.instance.createBroadcast(broadcast);
  }
}

final broadcastControllerProvider =
    NotifierProvider<BroadcastController, BroadcastState>(
  BroadcastController.new,
);
