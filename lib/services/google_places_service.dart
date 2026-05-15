import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolinked/feature/map/map_state.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:uuid/uuid.dart';

class GooglePlacesService {
  GooglePlacesService._internal();
  static final GooglePlacesService instance = GooglePlacesService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://places.googleapis.com/v1';
  
  String? _sessionToken;
  final _uuid = const Uuid();
  Timer? _debounce;

  String get _apiKey => dotenv.get('GOOGLE_MAPS_API_KEY');

  /// Generates or returns the current session token for autocomplete.
  String get _token {
    _sessionToken ??= _uuid.v4();
    return _sessionToken!;
  }

  /// Resets the session token after a place is selected.
  void resetSession() {
    _sessionToken = null;
  }

  /// Fetches autocomplete suggestions from Google Places API (New - v1).
  Future<List<SearchResult>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.post(
        '$_baseUrl/places:autocomplete',
        data: {
          'input': query,
          'sessionToken': _token,
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final suggestions = response.data['suggestions'] as List?;
        if (suggestions == null) return [];
        return suggestions.map((p) => SearchResult.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Google Places Autocomplete Error: $e');
    }
    return [];
  }

  /// Fetches place details (lat/lng) for a given placeId (New - v1).
  Future<SearchResult?> getPlaceDetails(SearchResult suggestion) async {
    if (suggestion.placeId == null) return suggestion;

    try {
      final response = await _dio.get(
        '$_baseUrl/places/${suggestion.placeId}',
        queryParameters: {
          'sessionToken': _token,
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'location,displayName,id',
          },
        ),
      );

      if (response.statusCode == 200) {
        final location = response.data['location'];
        
        // After successfully fetching details, we reset the session token
        resetSession();

        return SearchResult(
          displayName: suggestion.displayName,
          secondaryText: suggestion.secondaryText,
          latitude: location['latitude'],
          longitude: location['longitude'],
          placeId: response.data['id'],
        );
      }
    } catch (e) {
      debugPrint('Google Places Details Error: $e');
    }
    return suggestion;
  }

  /// Debounced search wrapper to reduce API calls.
  void searchWithDebounce(String query, Function(List<SearchResult>) onResults) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final results = await getSuggestions(query);
      onResults(results);
    });
  }
}
