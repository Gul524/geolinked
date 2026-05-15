import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResult {
  const SearchResult({
    required this.displayName,
    this.secondaryText,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  final String displayName;
  final String? secondaryText;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Check if it's the New Places API format
    if (json.containsKey('placePrediction')) {
      final prediction = json['placePrediction'];
      final structured = prediction['structuredFormat'];
      return SearchResult(
        displayName: structured?['mainText']?['text'] ?? prediction['text']?['text'] ?? '',
        secondaryText: structured?['secondaryText']?['text'],
        placeId: prediction['placeId'] ?? (prediction['place'] as String).replaceFirst('places/', ''),
      );
    }
    
    // Legacy support for Nominatim or Old Places API
    return SearchResult(
      displayName: json['display_name'] ?? json['description'] ?? '',
      latitude: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      longitude: json['lon'] != null ? double.tryParse(json['lon'].toString()) : null,
      placeId: json['place_id'] as String?,
    );
  }
}

class MapMarkerData {
  final String id;
  final LatLng position;
  final String type; // 'ask' or 'broadcast'
  final String? category;
  
  const MapMarkerData({
    required this.id,
    required this.position,
    required this.type,
    this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapMarkerData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class HomeMapState {
  const HomeMapState({
    this.targetLocation,
    this.targetLocationName,
    this.currentLocation,
    this.communityMarkers = const <MapMarkerData>[],
    this.points = const <LatLng>[], // Legacy support if needed
    this.cameraTarget,
    this.cameraZoom,
    this.errorMessage,
    this.isLoading = false,
    this.isTargetSlecting = false,
    this.isConfirmingLocation = false,
    this.searchResults = const <SearchResult>[],
    this.markerIcons = const <String, BitmapDescriptor>{},
  });

  final LatLng? targetLocation;
  final String? targetLocationName;
  final LatLng? currentLocation;
  final List<MapMarkerData> communityMarkers;
  final List<LatLng> points;
  final LatLng? cameraTarget;
  final double? cameraZoom;
  final bool isLoading;
  final String? errorMessage;
  final bool isTargetSlecting;
  final bool isConfirmingLocation;
  final List<SearchResult> searchResults;
  final Map<String, BitmapDescriptor> markerIcons;

  HomeMapState copyWith({
    LatLng? targetLocation,
    bool clearTargetLocation = false,
    LatLng? currentLocation,
    bool clearCurrentLocation = false,
    List<MapMarkerData>? communityMarkers,
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
    Map<String, BitmapDescriptor>? markerIcons,
  }) {
    return HomeMapState(
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      currentLocation: clearCurrentLocation
          ? null
          : (currentLocation ?? this.currentLocation),
      communityMarkers: communityMarkers ?? this.communityMarkers,
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
      markerIcons: markerIcons ?? this.markerIcons,
    );
  }
}
