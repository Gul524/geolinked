import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolinked/configs/providers/user_provider.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class GeoRadiusInfo {
  const GeoRadiusInfo({required this.centerPoint, required this.radiusMeters});

  final LatLng centerPoint;
  final double radiusMeters;

  bool isWithinRadius(LatLng point) {
    final double distanceInMeters = Geolocator.distanceBetween(
      centerPoint.latitude,
      centerPoint.longitude,
      point.latitude,
      point.longitude,
    );
    return distanceInMeters <= radiusMeters;
  }

  double getDistanceToPoint(LatLng point) {
    return Geolocator.distanceBetween(
      centerPoint.latitude,
      centerPoint.longitude,
      point.latitude,
      point.longitude,
    );
  }
}

class GeoService {
  GeoService._internal();
  static final GeoService _instance = GeoService._internal();
  factory GeoService() => _instance;

  StreamSubscription<Position>? _positionSubscription;
  String? _currentGeoTopic;

  /// Gets the current position of the device.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      // Try to get current position with a timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('Error getting current location: $e. Falling back to last known.');
      // Fallback to last known position
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Starts listening to location changes and updates Firestore.
  void startLocationTracking(WidgetRef ref) async {
    final Position? position = await getCurrentLocation();
    if (position == null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      ),
    ).listen((Position position) {
      // 1. Update user location in Firestore
      ref.read(userProvider.notifier).updateLocation(
        position.latitude,
        position.longitude,
      );

      // 2. Update Geo Topic Subscription (Topic Fallback)
      _updateGeoTopicSubscription(position.latitude, position.longitude);
    });
  }

  /// Updates the geohash topic subscription based on current location.
  /// Precision 4 covers approx 20km x 20km area.
  /// Precision 5 covers approx 5km x 5km area.
  void _updateGeoTopicSubscription(double lat, double lng) async {
    final String newGeohash = GeoFirePoint(GeoPoint(lat, lng)).geohash.substring(0, 5);
    final String newTopic = 'geo_$newGeohash';

    if (_currentGeoTopic != newTopic) {
      if (_currentGeoTopic != null) {
        await NotificationService.instance.unsubscribeFromTopic(_currentGeoTopic!);
      }
      await NotificationService.instance.subscribeToTopic(newTopic);
      _currentGeoTopic = newTopic;
    }
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    if (_currentGeoTopic != null) {
      NotificationService.instance.unsubscribeFromTopic(_currentGeoTopic!);
      _currentGeoTopic = null;
    }
  }

  Future<Placemark?> geopointToPlacemark({required LatLng point}) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getLocationString({required LatLng point}) async {
    try {
      final Placemark? placemark = await geopointToPlacemark(point: point);
      if (placemark == null) return null;

      final List<String> addressParts = <String>[];
      if (placemark.street?.isNotEmpty ?? false) addressParts.add(placemark.street!);
      if (placemark.subAdministrativeArea?.isNotEmpty ?? false) addressParts.add(placemark.subAdministrativeArea!);
      if (placemark.administrativeArea?.isNotEmpty ?? false) addressParts.add(placemark.administrativeArea!);
      if (placemark.country?.isNotEmpty ?? false) addressParts.add(placemark.country!);

      return addressParts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<List<Location>?> getPlaceString({required String query}) async {
    try {
      final List<Location> locations = await locationFromAddress(query.trim());
      return locations.isNotEmpty ? locations : null;
    } catch (_) {
      return null;
    }
  }

  // Removed searchPlaces as it is now handled by GooglePlacesService
}
