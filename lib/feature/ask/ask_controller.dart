import 'dart:async';
import 'package:geolinked/services/firestore_service.dart';
import 'package:geolinked/services/geo_service.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolocator/geolocator.dart';

class AskState {
  const AskState({
    this.nearbyAsks = const [],
    this.myAsks = const [],
    this.isLoading = true,
  });

  final List<AskModel> nearbyAsks;
  final List<AskModel> myAsks;
  final bool isLoading;

  List<AskModel> get allAsks => [...myAsks, ...nearbyAsks];

  AskState copyWith({
    List<AskModel>? nearbyAsks,
    List<AskModel>? myAsks,
    bool? isLoading,
  }) {
    return AskState(
      nearbyAsks: nearbyAsks ?? this.nearbyAsks,
      myAsks: myAsks ?? this.myAsks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AskController extends Notifier<AskState> {
  StreamSubscription? _nearbySubscription;
  StreamSubscription? _myAsksSubscription;
  Timer? _loadingTimeout;

  @override
  AskState build() {
    ref.onDispose(() {
      _nearbySubscription?.cancel();
      _myAsksSubscription?.cancel();
      _loadingTimeout?.cancel();
    });

    // Initialize listeners
    _initListeners();

    return const AskState();
  }

  void initialize(BuildContext context) {
    // Initial data loading is handled by build() and _initListeners()
  }

  String get subtitle => '${state.allAsks.length} queries active in your area';

  Future<void> _initListeners() async {
    // Start timeout immediately
    _loadingTimeout = Timer(const Duration(seconds: 30), () {
      if (state.isLoading) {
        debugPrint('Ask loading timed out');
        state = state.copyWith(isLoading: false);
      }
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Get real location for nearby queries
    final position = await GeoService().getCurrentLocation();
    final double lat = position?.latitude ?? 24.8607;
    final double lng = position?.longitude ?? 67.0011;

    // My Asks listener
    if (userId != null) {
      _myAsksSubscription = FirestoreService.instance.asks
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snap) {
          try {
            final asks = snap.docs
                .map((doc) =>
                    AskModel.fromJson(doc.data() as Map<String, dynamic>))
                .toList();
            state = state.copyWith(myAsks: asks, isLoading: false);
          } catch (e) {
            debugPrint('Error parsing my asks: $e');
            state = state.copyWith(isLoading: false);
          }
        },
        onError: (error) {
          debugPrint('My asks stream error: $error');
          state = state.copyWith(isLoading: false);
        },
      );
    }

    // Nearby Asks listener (GeoQuery)
    _nearbySubscription = FirestoreService.instance
        .getNearbyAsks(
      latitude: lat,
      longitude: lng,
      radiusKm: 15,
    )
        .listen(
      (asks) {
        _loadingTimeout?.cancel();
        final filteredAsks = asks.where((ask) => ask.userId != userId).toList();
        state = state.copyWith(nearbyAsks: filteredAsks, isLoading: false);
      },
      onError: (error) {
        _loadingTimeout?.cancel();
        debugPrint('Nearby asks stream error: $error');
        state = state.copyWith(isLoading: false);
      },
    );

  }

  Future<void> createAsk({
    required String title,
    required String description,
    required double lat,
    required double lng,
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

    final ask = AskModel(
      id: '',
      userId: userId,
      title: title,
      description: description,
      latitude: actualLat,
      longitude: actualLng,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      status: AskStatus.active,
      replyCount: 0,
    );
    await FirestoreService.instance.createAsk(ask);
  }

  Future<void> deleteAsk(String askId) async {
    await FirestoreService.instance.deleteAsk(askId);
  }
}

final askControllerProvider =
    NotifierProvider<AskController, AskState>(AskController.new);
