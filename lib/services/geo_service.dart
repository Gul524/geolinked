import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class GeoRadiusInfo {
  const GeoRadiusInfo({required this.centerPoint, required this.radiusMeters});

  final LatLng centerPoint;
  final double radiusMeters;

  bool isWithinRadius(LatLng point) {
    final Distance distance = const Distance();
    final double distanceInMeters = distance.as(
      LengthUnit.Meter,
      centerPoint,
      point,
    );
    return distanceInMeters <= radiusMeters;
  }

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
      return null;
    }
  }

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
      return null;
    }
  }

  Future<List<Location>?> getPlaceString({required String query}) async {
    try {
      final String normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return null;
      }

      final List<Location> locations = await locationFromAddress(
        normalizedQuery,
      );

      if (locations.isEmpty) {
        return null;
      }

      return locations;
    } catch (_) {
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
