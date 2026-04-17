import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:latlong2/latlong.dart';

class ConfirmedMapTarget {
  const ConfirmedMapTarget({required this.point, this.locationName});

  final LatLng point;
  final String? locationName;
}

class HomeMapController extends Notifier<HomeMapState> {
  static const LatLng _defaultTargetLocation = LatLng(24.8607, 67.0011);

  @override
  HomeMapState build() {
    return const HomeMapState(
      targetLocation: _defaultTargetLocation,
      currentLocation: null,
      broadcasts: <LatLng>[],
      points: <LatLng>[],
    );
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

  void setTargetLocation(LatLng value) {
    state = state.copyWith(targetLocation: value);
  }

  void setCurrentLocation(LatLng? value) {
    state = value == null
        ? state.copyWith(clearCurrentLocation: true)
        : state.copyWith(currentLocation: value);
  }

  void setBroadcasts(List<LatLng> value) {
    state = state.copyWith(broadcasts: List<LatLng>.unmodifiable(value));
  }

  void setPoints(List<LatLng> value) {
    state = state.copyWith(points: List<LatLng>.unmodifiable(value));
  }
}

final homeMapControllerProvider =
    NotifierProvider<HomeMapController, HomeMapState>(HomeMapController.new);
