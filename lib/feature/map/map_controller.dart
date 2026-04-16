import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:latlong2/latlong.dart';

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

  LatLng get targetLocation => state.targetLocation;
  LatLng? get currentLocation => state.currentLocation;
  List<LatLng> get broadcasts => state.broadcasts;
  List<LatLng> get points => state.points;

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
