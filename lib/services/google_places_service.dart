import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';

class GooglePlacesService {
  GooglePlacesService._internal();
  static final GooglePlacesService instance = GooglePlacesService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  Timer? _debounce;

  String get _apiKey => dotenv.get('GOOGLE_MAPS_API_KEY');

  /// Fetches autocomplete suggestions from Google Places API.
  Future<List<SearchResult>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          // You can add location bias here if needed
        },
      );

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'] as List;
        return predictions.map((p) => SearchResult.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Google Places Autocomplete Error: $e');
    }
    return [];
  }

  /// Fetches place details (lat/lng) for a given placeId.
  Future<SearchResult?> getPlaceDetails(SearchResult suggestion) async {
    if (suggestion.placeId == null) return suggestion;

    try {
      final response = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': suggestion.placeId,
          'fields': 'geometry',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final geometry = response.data['result']['geometry']['location'];
        return SearchResult(
          displayName: suggestion.displayName,
          latitude: geometry['lat'],
          longitude: geometry['lng'],
          placeId: suggestion.placeId,
        );
      }
    } catch (e) {
      debugPrint('Google Places Details Error: $e');
    }
    return suggestion;
  }

  /// Debounced search wrapper.
  void debouncedSearch(String query, Function(List<SearchResult>) onResults) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      final results = await getSuggestions(query);
      onResults(results);
    });
  }
}
