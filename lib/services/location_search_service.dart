import 'package:dio/dio.dart';
import 'package:geolinked/feature/map/map_state.dart';

class LocationSearchService {
  LocationSearchService._internal();
  static final LocationSearchService instance = LocationSearchService._internal();

  final Dio _dio = Dio();

  Future<List<SearchResult>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'GeoLinked_App', // Nominatim requires a user-agent
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => SearchResult.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<SearchResult?> getPlaceDetails(SearchResult result) async {
    // Nominatim already returns lat/lon in the search results,
    // so we don't strictly need a separate details call,
    // but we return the result as is or fetch more if needed.
    return result;
  }
}
