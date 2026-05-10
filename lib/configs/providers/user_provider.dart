import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';

/// Global provider to manage the current user's state and session via Firebase.
final userProvider = NotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    // Listen to Auth state changes to keep the user session in sync
    _initAuthListener();
    return null;
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = null;
      } else {
        await fetchProfile();
      }
    });
  }

  /// Sets the current user and persists the ID locally for faster lookups.
  void setUser(UserModel user) {
    state = user;
    LocalStorageService.instance.saveUserId(user.id);
  }

  /// Clears the user session (Logout).
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = null;
    LocalStorageService.instance.delete('current_user_id');
  }

  /// Fetches the latest profile data from Firestore.
  Future<void> fetchProfile() async {
    final String? userId =
        FirebaseAuth.instance.currentUser?.uid ??
        LocalStorageService.instance.getUserId();
        
    if (userId == null) return;

    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final UserModel user =
            UserModel.fromJson(doc.data() as Map<String, dynamic>);
        state = user;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  /// Updates the user's current coordinates in Firestore.
  Future<bool> updateLocation(double latitude, double longitude) async {
    final String? userId = state?.id ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lastLocation': {'latitude': latitude, 'longitude': longitude},
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  /// Sets or clears the Firebase messaging token in Firestore.
  Future<bool> updateNotificationId(String? firebaseNotificationId) async {
    final String? userId = state?.id ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': firebaseNotificationId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating notification ID: $e');
      return false;
    }
  }
}
