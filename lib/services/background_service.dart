import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolinked/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase for the background process
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[BackgroundService] No authenticated user found.');
        return true;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[BackgroundService] Location services are disabled.');
        return true;
      }

      // Check permissions (should be granted already)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[BackgroundService] Location permissions are denied.');
        return true;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      final GeoFirePoint geoFirePoint = GeoFirePoint(
        GeoPoint(position.latitude, position.longitude),
      );

      // Update user's lastLocation in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'lastLocation': geoFirePoint.data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[BackgroundService] Successfully synced location: ${position.latitude}, ${position.longitude}');
      
      return true;
    } catch (e) {
      debugPrint('[BackgroundService] Background location sync failed: $e');
      return false;
    }
  });
}

class BackgroundService {
  static const String syncTask = "com.sulemangul.geolinked.locationSync";

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> startLocationSync() async {
    await Workmanager().registerPeriodicTask(
      "1",
      syncTask,
      frequency: const Duration(minutes: 15), // Android minimum is 15 mins
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> stopLocationSync() async {
    await Workmanager().cancelAll();
  }
}
