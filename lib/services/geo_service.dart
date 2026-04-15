import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class GeoRadiusInfo {
  const GeoRadiusInfo({required this.centerPoint, required this.radiusMeters});

  final LatLng centerPoint;
  final double radiusMeters;

  /// Check if a given geopoint lies within this radius
  bool isWithinRadius(LatLng point) {
    final Distance distance = const Distance();
    final double distanceInMeters = distance.as(
      LengthUnit.Meter,
      centerPoint,
      point,
    );
    return distanceInMeters <= radiusMeters;
  }

  /// Get the distance from center to a geopoint in meters
  double getDistanceToPoint(LatLng point) {
    final Distance distance = const Distance();
    return distance.as(LengthUnit.Meter, centerPoint, point);
  }
}

class GeoService {
  GeoService._internal();

  static final GeoService _instance = GeoService._internal();

  factory GeoService() {
    return _instance;
  }

  /// Convert a LatLng geopoint to placemark
  ///
  /// Returns a Placemark containing address, city, street, etc.
  /// Returns null if geocoding fails or service is unavailable.
  Future<Placemark?> geopointToPlacemark({required LatLng point}) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      return placemarks.first;
    } catch (_) {
      // Silently fail if geocoding is unavailable or request fails
      return null;
    }
  }

  /// Get a readable location string from a LatLng geopoint
  ///
  /// Combines street, city, and country information
  /// Returns a formatted address string or null if geocoding fails
  Future<String?> getLocationString({required LatLng point}) async {
    try {
      final Placemark? placemark = await geopointToPlacemark(point: point);

      if (placemark == null) {
        return null;
      }

      final List<String> addressParts = <String>[];

      if (placemark.street != null && placemark.street!.isNotEmpty) {
        addressParts.add(placemark.street!);
      }

      if (placemark.subAdministrativeArea != null &&
          placemark.subAdministrativeArea!.isNotEmpty) {
        addressParts.add(placemark.subAdministrativeArea!);
      }

      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        addressParts.add(placemark.administrativeArea!);
      }

      if (placemark.country != null && placemark.country!.isNotEmpty) {
        addressParts.add(placemark.country!);
      }

      return addressParts.join(', ');
    } catch (_) {
      // Silently fail if geocoding is unavailable or request fails
      return null;
    }
  }

  GeoRadiusInfo createGeoRadius({
    required LatLng centerPoint,
    required double radiusMeters,
  }) {
    return GeoRadiusInfo(centerPoint: centerPoint, radiusMeters: radiusMeters);
  }

  double calculateDistance({required LatLng from, required LatLng to}) {
    final Distance distance = const Distance();
    return distance.as(LengthUnit.Meter, from, to);
  }

  static String? getPlacemarkShortName(Placemark? placemark) {
    if (placemark == null) {
      return null;
    }

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      return placemark.street;
    }

    if (placemark.subAdministrativeArea != null &&
        placemark.subAdministrativeArea!.isNotEmpty) {
      return placemark.subAdministrativeArea;
    }

    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      return placemark.administrativeArea;
    }

    return placemark.country;
  }
}
