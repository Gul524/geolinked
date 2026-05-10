import 'package:latlong2/latlong.dart';

class SearchResult {
  const SearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
    );
  }
}

class HomeMapState {
  const HomeMapState({
    required this.targetLocation,
    this.targetLocationName,
    this.currentLocation,
    required this.broadcasts,
    required this.points,
    this.cameraTarget,
    this.cameraZoom,
    this.errorMessage,
    this.isLoading = false,
    this.isTargetSlecting = false,
    this.isConfirmingLocation = false,
    this.searchResults = const <SearchResult>[],
  });

  final LatLng? targetLocation;
  final String? targetLocationName;
  final LatLng? currentLocation;
  final List<LatLng> broadcasts;
  final List<LatLng> points;
  final LatLng? cameraTarget;
  final double? cameraZoom;
  final bool isLoading;
  final String? errorMessage;
  final bool isTargetSlecting;
  final bool isConfirmingLocation;
  final List<SearchResult> searchResults;

  HomeMapState copyWith({
    LatLng? targetLocation,
    bool clearTargetLocation = false,
    LatLng? currentLocation,
    bool clearCurrentLocation = false,
    List<LatLng>? broadcasts,
    List<LatLng>? points,
    LatLng? cameraTarget,
    bool clearCameraTarget = false,
    double? cameraZoom,
    bool clearCameraZoom = false,
    bool? isLoading,
    String? errorMessage,
    bool? isTargetSlecting,
    bool? isConfirmingLocation,
    bool clearErrorMessage = false,
    String? targetLocationName,
    List<SearchResult>? searchResults,
  }) {
    return HomeMapState(
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      currentLocation: clearCurrentLocation
          ? null
          : (currentLocation ?? this.currentLocation),
      broadcasts: broadcasts ?? this.broadcasts,
      points: points ?? this.points,
      cameraTarget: clearCameraTarget
          ? null
          : (cameraTarget ?? this.cameraTarget),
      cameraZoom: clearCameraZoom ? null : (cameraZoom ?? this.cameraZoom),
      isLoading: isLoading ?? this.isLoading,
      isTargetSlecting: isTargetSlecting ?? this.isTargetSlecting,
      isConfirmingLocation: isConfirmingLocation ?? this.isConfirmingLocation,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      targetLocationName: clearTargetLocation
          ? null
          : (targetLocationName ?? this.targetLocationName),
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
