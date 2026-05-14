import 'package:geolinked/services/geo_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/services/firestore_service.dart';
import 'dart:async';

class BroadcastState {
  const BroadcastState({
    this.nearbyBroadcasts = const [],
    this.myBroadcasts = const [],
    this.isLoading = true,
  });

  final List<BroadcastModel> nearbyBroadcasts;
  final List<BroadcastModel> myBroadcasts;
  final bool isLoading;

  List<BroadcastModel> get allBroadcasts => [...myBroadcasts, ...nearbyBroadcasts];

  BroadcastState copyWith({
    List<BroadcastModel>? nearbyBroadcasts,
    List<BroadcastModel>? myBroadcasts,
    bool? isLoading,
  }) {
    return BroadcastState(
      nearbyBroadcasts: nearbyBroadcasts ?? this.nearbyBroadcasts,
      myBroadcasts: myBroadcasts ?? this.myBroadcasts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BroadcastController extends Notifier<BroadcastState> {
  StreamSubscription? _nearbySubscription;
  StreamSubscription? _myBroadcastsSubscription;
  Timer? _loadingTimeout;

  @override
  BroadcastState build() {
    ref.onDispose(() {
      _nearbySubscription?.cancel();
      _myBroadcastsSubscription?.cancel();
      _loadingTimeout?.cancel();
    });

    _initListeners();

    return const BroadcastState();
  }

  void initialize(BuildContext context) {
    // Initialization logic if needed
  }

  String get subtitle => '${state.allBroadcasts.length} alerts active in your area';

  Future<void> _initListeners() async {
    // Start timeout immediately
    _loadingTimeout = Timer(const Duration(seconds: 30), () {
      if (state.isLoading) {
        debugPrint('Broadcast loading timed out');
        state = state.copyWith(isLoading: false);
      }
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Start fetching location in background
    GeoService().getCurrentLocation().then((position) {
      if (position != null) {
        final double lat = position.latitude;
        final double lng = position.longitude;

        // Update nearby subscription with real location
        _nearbySubscription?.cancel();
        _nearbySubscription = FirestoreService.instance
            .getNearbyBroadcasts(
          latitude: lat,
          longitude: lng,
          radiusKm: 10,
        )
            .listen(
          (items) {
            _loadingTimeout?.cancel();
            final filtered = items.where((item) => item.authorId != userId).toList();
            state = state.copyWith(nearbyBroadcasts: filtered, isLoading: false);
          },
          onError: (error) {
            _loadingTimeout?.cancel();
            debugPrint('Nearby broadcasts stream error: $error');
            state = state.copyWith(isLoading: false);
          },
        );
      }
    });

    // My Broadcasts listener (does not depend on location)
    if (userId != null) {
      _myBroadcastsSubscription = FirestoreService.instance.broadcasts
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snap) {
          try {
            final items = snap.docs
                .map((doc) => BroadcastModel.fromJson(<String, dynamic>{
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList();
            state = state.copyWith(myBroadcasts: items, isLoading: false);
          } catch (e) {
            debugPrint('Error parsing my broadcasts: $e');
            state = state.copyWith(isLoading: false);
          }
        },
        onError: (error) {
          debugPrint('My broadcasts stream error: $error');
          state = state.copyWith(isLoading: false);
        },
      );
    }

    // Initial load for nearby broadcasts using a default location while waiting for GPS
    _nearbySubscription = FirestoreService.instance
        .getNearbyBroadcasts(
      latitude: 24.8607,
      longitude: 67.0011,
      radiusKm: 10,
    )
        .listen(
      (items) {
        final filtered = items.where((item) => item.authorId != userId).toList();
        if (state.nearbyBroadcasts.isEmpty) {
          state = state.copyWith(nearbyBroadcasts: filtered, isLoading: false);
        }
      },
    );

  }

  Future<void> createBroadcast({
    required String category,
    required String message,
    required double lat,
    required double lng,
    double radiusKm = 10,
    BroadcastSeverity severity = BroadcastSeverity.info,
    String? imageUrl,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Get actual location if not provided
    double actualLat = lat;
    double actualLng = lng;

    if (actualLat == 0 || actualLng == 0) {
      final pos = await GeoService().getCurrentLocation();
      actualLat = pos?.latitude ?? 24.8607;
      actualLng = pos?.longitude ?? 67.0011;
    }

    final broadcast = BroadcastModel(
      id: '',
      authorId: userId,
      category: category,
      message: message,
      latitude: actualLat,
      longitude: actualLng,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      severity: BroadcastSeverity.info,
      radiusKm: radiusKm,
      seenCount: 0,
      verifiedCount: 0,
    );

    await FirestoreService.instance.createBroadcast(broadcast);
  }

  Future<void> deleteBroadcast(String broadcastId) async {
    try {
      await FirestoreService.instance.deleteBroadcast(broadcastId);
    } catch (e) {
      debugPrint('Error deleting broadcast: $e');
      rethrow;
    }
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
