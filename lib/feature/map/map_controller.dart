import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolinked/services/geo_service.dart';

class ConfirmedMapTarget {
  const ConfirmedMapTarget({required this.point, this.locationName});

  final LatLng point;
  final String? locationName;
}

class HomeMapController extends Notifier<HomeMapState> {
  static const LatLng _defaultTargetLocation = LatLng(24.8607, 67.0011);

  @override
  HomeMapState build() {
    // Listen to changes in Asks and Broadcasts to update map markers
    ref.listen(askControllerProvider, (previous, next) {
      final List<LatLng> points = next.nearbyAsks
          .where((a) => a.latitude != null && a.longitude != null)
          .map((a) => LatLng(a.latitude!, a.longitude!))
          .toList();
      state = state.copyWith(points: points);
    });

    ref.listen(broadcastControllerProvider, (previous, next) {
      final List<LatLng> broadcastPoints = next.nearbyBroadcasts
          .where((b) => b.latitude != null && b.longitude != null)
          .map((b) => LatLng(b.latitude!, b.longitude!))
          .toList();
      state = state.copyWith(broadcasts: broadcastPoints);
    });

    return const HomeMapState(
      targetLocation: null,
      currentLocation: null,
      broadcasts: <LatLng>[],
      points: <LatLng>[],
    );
  }

  Future<void> initialize() async {
    final position = await GeoService().getCurrentLocation();
    if (position != null) {
      final point = LatLng(position.latitude, position.longitude);
      state = state.copyWith(
        currentLocation: point,
        targetLocation: point,
        cameraTarget: point,
        cameraZoom: 15,
      );
    } else {
      // Fallback to default if location is denied
      state = state.copyWith(
        targetLocation: _defaultTargetLocation,
        cameraTarget: _defaultTargetLocation,
        cameraZoom: 13,
      );
    }
  }

  void moveToCurrentLocation() {
    if (state.currentLocation != null) {
      state = state.copyWith(
        cameraTarget: state.currentLocation,
        cameraZoom: 16,
      );
    }
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: <SearchResult>[]);
      return;
    }

    state = state.copyWith(isLoading: true);
    final results = await GeoService().searchPlaces(query);
    state = state.copyWith(searchResults: results, isLoading: false);
  }

  void selectSearchResult(SearchResult result) {
    final point = LatLng(result.latitude, result.longitude);
    state = state.copyWith(
      cameraTarget: point,
      cameraZoom: 17,
      searchResults: <SearchResult>[], // Clear results after selection
    );
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: <SearchResult>[]);
  }

  LatLng? get targetLocation => state.targetLocation;
  LatLng? get currentLocation => state.currentLocation;
  List<LatLng> get broadcasts => state.broadcasts;
  List<LatLng> get points => state.points;
  bool get isTargetSelecting => state.isTargetSlecting;

  void enterTargetSelectionMode() {
    state = state.copyWith(isTargetSlecting: true);
  }

  void clearTargetSelectionMode() {
    state = state.copyWith(clearTargetLocation: true, isTargetSlecting: false);
  }

  void selectTargetLocation(LatLng value) {
    state = state.copyWith(
      targetLocation: value,
      isTargetSlecting: false,
      isConfirmingLocation: true,
      cameraTarget: value,
      cameraZoom: 20,
    );
  }

  Future<ConfirmedMapTarget?> confirmLocationSelection() async {
    final LatLng? point = state.targetLocation;
    if (point == null) {
      return null;
    }

    state = state.copyWith(isConfirmingLocation: false);
    final String? locationName = await _fetchGeoPoints(point);
    return ConfirmedMapTarget(point: point, locationName: locationName);
  }

  void cancelLocationConfirmation() {
    state = state.copyWith(
      clearTargetLocation: true,
      isConfirmingLocation: false,
      clearCameraTarget: true,
      clearCameraZoom: true,
    );
  }

  Future<String?> _fetchGeoPoints(LatLng point) async {
    state = state.copyWith(isLoading: true);
    try {
      final String? locationName = await GeoService().getLocationString(
        point: point,
      );
      state = state.copyWith(
        targetLocationName: locationName,
        isLoading: false,
      );
      return locationName;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  void moveCameraTo(LatLng target, {double? zoom}) {
    state = state.copyWith(
      cameraTarget: target,
      clearCameraZoom: zoom == null,
      cameraZoom: zoom,
    );
  }

  void clearCameraRequest() {
    state = state.copyWith(clearCameraTarget: true, clearCameraZoom: true);
  }

  void setCurrentLocation(LatLng? value) {
    state = value == null
        ? state.copyWith(clearCurrentLocation: true)
        : state.copyWith(currentLocation: value);
  }
}

final homeMapControllerProvider =
    NotifierProvider<HomeMapController, HomeMapState>(HomeMapController.new);
