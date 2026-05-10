import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';

class AskState {
  const AskState({
    required this.nearbyAsks,
    required this.myAsks,
  });

  final List<AskModel> nearbyAsks;
  final List<AskModel> myAsks;

  List<AskModel> get allAsks => [...myAsks, ...nearbyAsks];

  AskState copyWith({
    List<AskModel>? nearbyAsks,
    List<AskModel>? myAsks,
  }) {
    return AskState(
      nearbyAsks: nearbyAsks ?? this.nearbyAsks,
      myAsks: myAsks ?? this.myAsks,
    );
  }
}

class AskController extends Notifier<AskState> {
  StreamSubscription? _nearbySubscription;
  StreamSubscription? _myAsksSubscription;

  @override
  AskState build() {
    ref.onDispose(() {
      _nearbySubscription?.cancel();
      _myAsksSubscription?.cancel();
    });

    // Initialize listeners
    _initListeners();

    return const AskState(nearbyAsks: [], myAsks: []);
  }

  void initialize(BuildContext context) {
    // Initial data loading is handled by build() and _initListeners()
  }

  String get subtitle => '${state.allAsks.length} queries active in your area';

  void _initListeners() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _myAsksSubscription = FirestoreService.instance.asks
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) =>
                  AskModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList())
          .listen((items) {
        state = state.copyWith(myAsks: items);
      });
    }

    // Radius search - using Karachi as default or current location if available
    _nearbySubscription = FirestoreService.instance
        .getNearbyAsks(
          latitude: 24.8607,
          longitude: 67.0011,
          radiusKm: 10,
        )
        .listen((items) {
      state = state.copyWith(nearbyAsks: items);
    });
  }

  Future<void> createAsk({
    required String title,
    required String description,
    required double lat,
    required double lng,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final ask = AskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      latitude: lat,
      longitude: lng,
      createdAt: DateTime.now(),
    );

    await FirestoreService.instance.createAsk(ask);
  }

  Future<void> addComment(String askId, String message) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirestoreService.instance.addComment('ask', askId, {
      'userId': userId,
      'message': message,
      'authorName': FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
    });
  }
}

final askControllerProvider = NotifierProvider<AskController, AskState>(
  AskController.new,
);
