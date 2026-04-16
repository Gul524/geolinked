import 'package:latlong2/latlong.dart';

class HomeMapState {
  const HomeMapState({
    required this.targetLocation,
    this.currentLocation,
    required this.broadcasts,
    required this.points,
  });

  final LatLng targetLocation;
  final LatLng? currentLocation;
  final List<LatLng> broadcasts;
  final List<LatLng> points;

  HomeMapState copyWith({
    LatLng? targetLocation,
    LatLng? currentLocation,
    bool clearCurrentLocation = false,
    List<LatLng>? broadcasts,
    List<LatLng>? points,
  }) {
    return HomeMapState(
      targetLocation: targetLocation ?? this.targetLocation,
      currentLocation: clearCurrentLocation
          ? null
          : (currentLocation ?? this.currentLocation),
      broadcasts: broadcasts ?? this.broadcasts,
      points: points ?? this.points,
    );
  }
}
