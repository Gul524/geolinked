import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/services/background_service.dart';

/// Global provider to manage the current user's state and session via Firebase.
/// Implements offline-first caching for a seamless persistent login experience.
final userProvider = NotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});

class UserNotifier extends Notifier<UserModel?> {
  static const String _userCacheKey = 'cached_user_profile';

  @override
  UserModel? build() {
    // 1. Try to load from local cache first for instant UI response
    _loadFromCache();
    
    // 2. Initialize real-time auth listener
    _initAuthListener();
    
    return null;
  }

  void _loadFromCache() {
    final String? jsonStr = LocalStorageService.instance.get<String>(_userCacheKey);
    if (jsonStr != null) {
      try {
        state = UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error loading user cache: $e');
      }
    }
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = null;
        await LocalStorageService.instance.delete(_userCacheKey);
        await BackgroundService.stopLocationSync();
      } else {
        await fetchProfile();
        // Start background location sync
        await BackgroundService.startLocationSync();
      }
    });
  }

  /// Fetches fresh profile data and updates the local cache.
  Future<void> fetchProfile() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final UserModel user = UserModel.fromJson(data);
        
        // Update state and cache
        state = user;
        await LocalStorageService.instance.put(_userCacheKey, jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  /// Explicit Logout: Clears Firebase session and local cache.
  Future<void> logout() async {
    await BackgroundService.stopLocationSync();
    await FirebaseAuth.instance.signOut();
    await LocalStorageService.instance.delete(_userCacheKey);
    state = null;
  }

  Future<bool> updateLocation(double latitude, double longitude) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lastLocation': {'latitude': latitude, 'longitude': longitude},
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
