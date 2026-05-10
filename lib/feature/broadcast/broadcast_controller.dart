import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';

class BroadcastState {
  const BroadcastState({
    required this.nearbyBroadcasts,
    required this.myBroadcasts,
  });

  final List<BroadcastModel> nearbyBroadcasts;
  final List<BroadcastModel> myBroadcasts;

  List<BroadcastModel> get allBroadcasts => [...myBroadcasts, ...nearbyBroadcasts];

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

  void initialize(BuildContext context) {
    // Initialization logic if needed
  }

  String get subtitle => '${state.allBroadcasts.length} alerts active in your area';

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
    String? imageUrl,
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
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await FirestoreService.instance.createBroadcast(broadcast);
  }

  Future<void> addComment(String broadcastId, String message) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirestoreService.instance.addComment('broadcast', broadcastId, {
      'userId': userId,
      'message': message,
      'authorName': FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
    });
  }
}

final broadcastControllerProvider =
    NotifierProvider<BroadcastController, BroadcastState>(
  BroadcastController.new,
);
