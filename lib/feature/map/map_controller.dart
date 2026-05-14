import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolinked/feature/ask/ask_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_controller.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/services/geo_service.dart';
import 'package:geolinked/services/google_places_service.dart';

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
      _updateCommunityMarkers();
    });

    ref.listen(broadcastControllerProvider, (previous, next) {
      _updateCommunityMarkers();
    });

    return const HomeMapState();
  }

  void _updateCommunityMarkers() {
    final asks = ref.read(askControllerProvider).nearbyAsks;
    final broadcasts = ref.read(broadcastControllerProvider).nearbyBroadcasts;

    final List<MapMarkerData> markers = [];

    for (final ask in asks) {
      if (ask.latitude != null && ask.longitude != null) {
        markers.add(MapMarkerData(
          id: 'ask_${ask.id}',
          position: LatLng(ask.latitude!, ask.longitude!),
          type: 'ask',
        ));
      }
    }

    for (final broadcast in broadcasts) {
      if (broadcast.latitude != null && broadcast.longitude != null) {
        markers.add(MapMarkerData(
          id: 'broadcast_${broadcast.id}',
          position: LatLng(broadcast.latitude!, broadcast.longitude!),
          type: 'broadcast',
          category: broadcast.category,
        ));
      }
    }

    state = state.copyWith(communityMarkers: markers);
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
      state = state.copyWith(
        targetLocation: _defaultTargetLocation,
        cameraTarget: _defaultTargetLocation,
        cameraZoom: 13,
      );
    }
    
    // Initial marker sync
    _updateCommunityMarkers();
  }

  void moveToCurrentLocation() {
    if (state.currentLocation != null) {
      state = state.copyWith(
        cameraTarget: state.currentLocation,
        cameraZoom: 16,
      );
    }
  }

  void searchPlaces(String query) {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: <SearchResult>[]);
      return;
    }

    state = state.copyWith(isLoading: true);
    
    GooglePlacesService.instance.debouncedSearch(query, (results) {
      state = state.copyWith(searchResults: results, isLoading: false);
    });
  }

  Future<void> selectSearchResult(SearchResult result) async {
    state = state.copyWith(isLoading: true);
    
    // Fetch lat/lng if not available (Google Autocomplete returns suggestions without coordinates)
    final detailedResult = await GooglePlacesService.instance.getPlaceDetails(result);
    
    if (detailedResult?.latitude != null && detailedResult?.longitude != null) {
      final point = LatLng(detailedResult!.latitude!, detailedResult.longitude!);
      state = state.copyWith(
        cameraTarget: point,
        cameraZoom: 17,
        searchResults: <SearchResult>[],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        searchResults: <SearchResult>[],
        isLoading: false,
      );
    }
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: <SearchResult>[]);
  }

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
